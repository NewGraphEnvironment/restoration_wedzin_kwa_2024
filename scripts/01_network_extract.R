#!/usr/bin/env Rscript
#
# fwa_extract_co_habitat.R
#
# Extract the coho habitat network for the Neexdzii Kwa study area using
# fresh's DB-side pipeline. Scopes waterbodies to accessible order 3+
# streams — no headwater wetlands on tiny tributaries.
#
# Steps:
#   1. Extract FWA base stream network to a working table on the DB
#   2. Enrich with channel_width, upstream_area_ha, map_upstream (for flooded)
#   3. Identify access barriers: gradient >= 15% + barrier falls
#   4. Classify accessible reaches
#   5. Pull streams (accessible, order 3+) and waterbodies to R
#   6. Save GeoPackage + QA map
#
# The network is constant across flood scenarios — only flood_factor changes.
# fwa_extract_flood.R reads the saved GeoPackage for each scenario.
#
# Requires:
#   - SSH tunnel to db_newgraph
#   - fresh >= 0.4.0
#
# Fixes #139
#
# Usage:
#   Rscript scripts/fwa_extract_co_habitat.R

library(fresh)
library(sf)

sf_use_s2(FALSE)

conn <- frs_db_conn()

# --- Study area ---
# Toggle test_mode to run on a small area first (McKilligan to Bulkley Falls)
test_mode <- FALSE

blk <- 360873822
if (test_mode) {
  drm <- 188452             # McKilligan bridge (downstream)
  upstream_measure <- 233564 # Bulkley Falls (upstream)
} else {
  drm <- 166030.4           # Bulkley/Wedzin Kwa confluence (full Neexdzii)
  upstream_measure <- NULL
}

# --- Parameters ---
# Project-local CSVs — edit these to tweak thresholds for this study area.
# Habitat thresholds (gradient, channel width, MAD per species)
params_all <- frs_params(csv = here::here("data", "lulc",
  "parameters_habitat_thresholds.csv"))
params_co <- params_all$CO

# Access gradient + spawn gradient min
params_fresh <- read.csv(here::here("data", "lulc", "parameters_fresh.csv"))
co_fresh <- params_fresh[params_fresh$species_code == "CO", ]

# Minimum stream order for flood modelling
min_order <- 3

# Project default spawn gradient min (used for canonical co_spawning column)
spawn_gradient_min_default <- co_fresh$spawn_gradient_min

out_dir <- here::here("data", "lulc")
fs::dir_create(out_dir)

# Watershed polygon for AOI scoping (falls query, waterbody clipping)
message("Delineating study area watershed...")
aoi <- frs_watershed_at_measure(conn, blk, drm,
  upstream_measure = upstream_measure)

# --- Step 1: Extract FWA base streams to working table ---
# frs_network(to=) keeps data on PostgreSQL. We use the FWA base table
# (whse_basemapping.fwa_stream_networks_sp) not bcfishpass — fresh handles
# the habitat classification.
message("Extracting stream network to working table...")
conn |>
  frs_network(blk, drm, upstream_measure = upstream_measure,
    to = "working.neexdzii")

# --- Step 2: Enrich with attributes flooded needs ---
# Channel width — from fwapg regression model, keyed by linear_feature_id
message("Joining channel_width...")
conn |>
  frs_col_join("working.neexdzii",
    from = "fwa_stream_networks_channel_width",
    cols = c("channel_width", "channel_width_source"),
    by = "linear_feature_id")

# Upstream area (ha) — flooded uses this for bankfull width regression.
# Two-hop join: streams → watersheds lookup → upstream area table.
message("Joining upstream_area_ha...")
conn |>
  frs_col_join("working.neexdzii",
    from = "(SELECT l.linear_feature_id, ua.upstream_area_ha
             FROM fwa_streams_watersheds_lut l
             JOIN fwa_watersheds_upstream_area ua
               ON l.watershed_feature_id = ua.watershed_feature_id)",
    cols = "upstream_area_ha",
    by = "linear_feature_id")

# Mean annual precipitation (mm) — flooded uses this for bankfull regression.
# Joins on wscode_ltree + localcode_ltree (composite key).
message("Joining map_upstream...")
conn |>
  frs_col_join("working.neexdzii",
    from = "fwa_stream_networks_mean_annual_precip",
    cols = "map_upstream",
    by = c("wscode_ltree", "localcode_ltree"))

# --- Step 3: Access barriers ---
# Coho access gradient threshold is 15% — from bcfishpass
# model_access_ch_cm_co_pk_sk.sql (gradients >= 15% are impassable).
message("Finding access barriers (gradient >= 15% + barrier falls)...")

# Gradient barriers
frs_break_find(conn, "working.neexdzii",
  attribute = "gradient", threshold = co_fresh$access_gradient_max,
  to = "working.breaks_access_neexdzii")

# Barrier falls from bcfishpass falls table
# Scope to study area so we don't insert every barrier fall in BC
frs_break_find(conn, "working.neexdzii",
  points_table = "bcfishpass.falls_vw",
  where = "barrier_ind = TRUE",
  aoi = aoi,
  to = "working.breaks_access_neexdzii", append = TRUE)

# Split geometry at barrier locations
frs_break_apply(conn, "working.neexdzii",
  breaks = "working.breaks_access_neexdzii")

# --- Step 4: Classify accessible ---
# Segments upstream of any access barrier are inaccessible to coho
message("Classifying accessible reaches...")
conn |>
  frs_classify("working.neexdzii", label = "accessible",
    breaks = "working.breaks_access_neexdzii")

# --- Step 5: Classify habitat within accessible reaches ---
{
  # Break at habitat gradient threshold — splits segments at gradient
  # transitions so classification is precise
  message("Breaking at habitat gradient threshold (",
          params_co$spawn_gradient_max * 100, "%)...")
  conn |>
    frs_break("working.neexdzii",
      attribute = "gradient",
      threshold = params_co$spawn_gradient_max,
      to = "working.breaks_habitat_neexdzii")

  rear_ranges <- params_co$ranges$rear[c("gradient", "channel_width")]

  # Rearing and lake rearing (single classification, no threshold variants)
  message("Classifying rearing habitat...")
  conn |>
    frs_classify("working.neexdzii", label = "co_rearing",
      ranges = rear_ranges,
      where = "accessible IS TRUE") |>
    frs_classify("working.neexdzii", label = "co_lake_rearing",
      ranges = list(channel_width = params_co$ranges$rear$channel_width),
      where = "accessible IS TRUE AND waterbody_key IN (SELECT waterbody_key FROM whse_basemapping.fwa_lakes_poly)")

  # Spawning at multiple gradient minimums — same segments, different columns.
  # Compares effect of excluding flat water (wetlands, dead channels) from
  # spawning habitat. Segments are already broken at spawn_gradient_max.
  spawn_mins <- c(0, 0.0025, 0.005, 0.0075)
  spawn_labels <- paste0("co_spawning_",
    gsub("\\.", "", format(spawn_mins * 100, nsmall = 1)))

  spawn_ranges_base <- params_co$ranges$spawn[c("gradient", "channel_width")]

  message("Classifying spawning at ", length(spawn_mins), " gradient minimums...")
  for (j in seq_along(spawn_mins)) {
    sr <- spawn_ranges_base
    sr$gradient[1] <- spawn_mins[j]
    conn |>
      frs_classify("working.neexdzii", label = spawn_labels[j],
        ranges = sr,
        where = "accessible IS TRUE")
    message("  ", spawn_labels[j], " (gradient >= ", spawn_mins[j] * 100, "%)")
  }

  # Keep the project default as the canonical co_spawning column
  default_label <- spawn_labels[which(spawn_mins == co_fresh$spawn_gradient_min)]
  message("Setting co_spawning = ", default_label)
  DBI::dbExecute(conn,
    "ALTER TABLE working.neexdzii ADD COLUMN IF NOT EXISTS co_spawning BOOLEAN")
  DBI::dbExecute(conn, sprintf(
    "UPDATE working.neexdzii SET co_spawning = %s", default_label))
}

# --- Step 6: Pull streams and waterbodies ---
# Full network (all orders, for mapping)
message("Reading full network...")
streams_all <- frs_db_query(conn, "SELECT * FROM working.neexdzii")
streams_all <- sf::st_zm(streams_all, drop = TRUE)

# Order 3+ accessible for flooded input
streams <- streams_all[streams_all$accessible %in% TRUE &
  !is.na(streams_all$stream_order) & streams_all$stream_order >= min_order, ]

# Waterbodies: only those connected to accessible order 3+ streams.
# frs_network() uses waterbody_key bridging through the stream network.
# from + extra_where scopes to our classified working table.
message("Reading waterbodies on accessible order ", min_order, "+ streams...")
waterbodies_list <- frs_network(conn, blk, drm,
  upstream_measure = upstream_measure,
  clip = aoi,
  tables = list(
    lakes = list(
      table = "whse_basemapping.fwa_lakes_poly",
      from = "working.neexdzii",
      extra_where = sprintf("accessible IS TRUE AND stream_order >= %s", min_order)),
    wetlands = list(
      table = "whse_basemapping.fwa_wetlands_poly",
      from = "working.neexdzii",
      extra_where = sprintf("accessible IS TRUE AND stream_order >= %s", min_order))
  ))

waterbodies <- rbind(
  waterbodies_list$lakes[, c("waterbody_key", "waterbody_type", "area_ha", "geom")],
  waterbodies_list$wetlands[, c("waterbody_key", "waterbody_type", "area_ha", "geom")]
)

message("  Streams: ", nrow(streams), " segments")
message("  Orders: ", paste(sort(unique(streams$stream_order)), collapse = ", "))
message("  Lakes: ", nrow(waterbodies_list$lakes))
message("  Wetlands: ", nrow(waterbodies_list$wetlands))
message("  Waterbodies total: ", nrow(waterbodies))

# --- Step 7: Summary ---
len_km <- function(x) round(as.numeric(sum(sf::st_length(x))) / 1000, 1)

metrics <- c("Total network", "Accessible",
             "Order 3+ accessible (flooded input)",
             "Lakes on order 3+ accessible", "Wetlands on order 3+ accessible")
values <- c(len_km(streams_all),
            len_km(streams_all[streams_all$accessible %in% TRUE, ]),
            len_km(streams),
            nrow(waterbodies_list$lakes),
            nrow(waterbodies_list$wetlands))

if ("co_spawning" %in% names(streams_all)) {
  metrics <- c(metrics[1:2],
    "CO spawning (accessible)", "CO rearing (accessible)",
    "CO lake rearing (accessible)", metrics[3:5])
  values <- c(values[1:2],
    len_km(streams_all[streams_all$co_spawning %in% TRUE, ]),
    len_km(streams_all[streams_all$co_rearing %in% TRUE, ]),
    len_km(streams_all[streams_all$co_lake_rearing %in% TRUE, ]),
    values[3:5])
}

summary_df <- data.frame(Metric = metrics, km_or_count = values)
message("\n=== Summary ===")
print(summary_df, row.names = FALSE)

# --- Step 8: Save ---
out_classified <- file.path(out_dir, "fresh_streams_classified.gpkg")
out_streams <- file.path(out_dir, "fresh_streams_co3.gpkg")
out_wb <- file.path(out_dir, "fresh_waterbodies_co3.gpkg")

sf::st_write(streams_all, out_classified, delete_dsn = TRUE, quiet = TRUE)
sf::st_write(streams, out_streams, delete_dsn = TRUE, quiet = TRUE)
sf::st_write(waterbodies, out_wb, delete_dsn = TRUE, quiet = TRUE)
message("Saved: ", basename(out_classified), ", ", basename(out_streams), ", ", basename(out_wb))

# --- Copy to QGIS project for field/team use ---
qgis_dir <- "/Users/airvine/Projects/gis/restoration_wedzin_kwa"
if (dir.exists(qgis_dir)) {
  file.copy(out_classified, file.path(qgis_dir, "fresh_streams_classified.gpkg"),
            overwrite = TRUE)
  file.copy(out_wb, file.path(qgis_dir, "fresh_waterbodies_co3.gpkg"),
            overwrite = TRUE)
  message("Copied to QGIS project: ", qgis_dir)
}

# --- Leave working tables for QA (uncomment to clean up) ---
# for (tbl in c("working.neexdzii", "working.breaks_access_neexdzii",
#                "working.breaks_habitat_neexdzii")) {
#   DBI::dbExecute(conn, sprintf("DROP TABLE IF EXISTS %s", tbl))
# }
DBI::dbDisconnect(conn)

# --- QA map ---
message("Generating QA map...")
qa_path <- file.path(out_dir, "fresh_map_co3.png")
png(qa_path, width = 2400, height = 3000, res = 200)

# Classify streams for plotting
streams_all$habitat <- ifelse(
  streams_all$co_spawning %in% TRUE, "Spawning",
  ifelse(streams_all$co_rearing %in% TRUE, "Rearing",
    ifelse(streams_all$co_lake_rearing %in% TRUE, "Lake rearing",
      ifelse(streams_all$accessible %in% TRUE, "Accessible", "Inaccessible"))))

cols_hab <- c(Spawning = "#129bdb", Rearing = "#ff9f85",
  "Lake rearing" = "#41AB5D", Accessible = "grey60", Inaccessible = "grey85")

plot(sf::st_geometry(aoi), border = "grey40", lwd = 1.5,
     main = paste0("Coho habitat — ",
       len_km(streams_all[streams_all$co_spawning %in% TRUE, ]), " km spawning, ",
       len_km(streams_all[streams_all$co_rearing %in% TRUE, ]), " km rearing\n",
       nrow(waterbodies_list$lakes), " lakes, ",
       nrow(waterbodies_list$wetlands), " wetlands on order ", min_order, "+"))

# Waterbodies
if (nrow(waterbodies_list$wetlands) > 0) {
  plot(sf::st_geometry(waterbodies_list$wetlands), col = "#a3cdb966",
       border = "#238B4544", add = TRUE)
}
if (nrow(waterbodies_list$lakes) > 0) {
  plot(sf::st_geometry(waterbodies_list$lakes), col = "#dcecf4",
       border = "#2171B5", add = TRUE)
}

# Streams by habitat — draw in order so spawning is on top
for (h in c("Inaccessible", "Accessible", "Lake rearing", "Rearing", "Spawning")) {
  sub <- streams_all[streams_all$habitat == h, ]
  if (nrow(sub) > 0) {
    lw <- if (h %in% c("Inaccessible", "Accessible")) 0.2 else 1.2
    plot(sf::st_geometry(sub), col = cols_hab[h], lwd = lw, add = TRUE)
  }
}

legend("topright",
  legend = c("Spawning", "Rearing", "Lake rearing", "Accessible", "Inaccessible",
             "Lake", "Wetland"),
  col = c(cols_hab[c("Spawning", "Rearing", "Lake rearing", "Accessible", "Inaccessible")],
          "#2171B5", "#238B45"),
  lwd = c(1.2, 1.2, 1.2, 0.5, 0.2, 0.5, 0.5),
  fill = c(NA, NA, NA, NA, NA, "#dcecf4", "#a3cdb966"),
  border = c(NA, NA, NA, NA, NA, "#2171B5", "#238B45"))

# Parameter stamp
param_text <- paste0(
  "Spawn: gradient ", co_fresh$spawn_gradient_min * 100, "-",
  params_co$spawn_gradient_max * 100, "%, width >= ",
  params_co$ranges$spawn$channel_width[1], "m",
  "  |  Rear: gradient 0-", params_co$ranges$rear$gradient[2] * 100,
  "%, width >= ", params_co$ranges$rear$channel_width[1], "m",
  "  |  Access barrier: >= ", co_fresh$access_gradient_max * 100,
  "% + barrier falls  |  Order >= ", min_order)
mtext(param_text, side = 1, line = 0, cex = 0.9, col = "grey40")

dev.off()
message("QA map: ", qa_path)
message("Done.")
