#!/usr/bin/env Rscript
#
# fwa_extract_flood.R
#
# 1. Generate sub-basin polygons from break_points.csv via frs_watershed_split()
# 2. Extract coho stream network and waterbodies via frs_network()
# 3. Generate floodplain AOI(s) using flooded VCA
#
# All columns in break_points.csv (name_basin, description, fisheries_value)
# are carried through to subbasins.gpkg automatically.
#
# Reads scenario parameters from data/lulc/flood_scenarios.csv:
#   - min_order: stream order filter for flood model streams
#   - anchor_order: stream order for patch connectivity (TODO: wire into flooded)
#   - flood_factor: VCA flood depth multiplier
#
# Usage:
#   Rscript scripts/fwa_extract_flood.R           # runs co_ff045
#   Rscript scripts/fwa_extract_flood.R co_ff04   # runs specific scenario
#   Rscript scripts/fwa_extract_flood.R all        # runs all scenarios
#
# Requires:
#   - SSH tunnel: ssh -L 63333:<db_host>:5432 <ssh_host>
#   - R packages: flooded, fresh, sf, terra, readr
#   - DEM/slope from bcfishpass habitat_lateral model
#
# Outputs:
#   data/lulc/subbasins.gpkg                          (sub-basin polygons)
#   data/lulc/floodplain_neexdzii_{scenario_id}.tif   (raster)
#   data/lulc/floodplain_neexdzii_{scenario_id}.gpkg  (vector)
#   data/lulc/streams_neexdzii_{scenario_id}.gpkg     (stream network)
#
# Relates to #67, #123, #135

library(flooded)
library(fresh)
library(sf)
library(terra)
library(readr)

sf_use_s2(FALSE)
terra::terraOptions(threads = 12)

# --- DB connection (fresh conn-first API) ---
conn <- frs_db_conn()

# --- Step 1: Generate sub-basins from break_points.csv ---
message("=== Generating sub-basins ===")
bp <- readr::read_csv(
  here::here("data", "lulc", "break_points.csv"),
  show_col_types = FALSE
)
subbasins <- frs_watershed_split(conn, bp)
sb_path <- here::here("data", "lulc", "subbasins.gpkg")
sf::st_write(subbasins, sb_path, layer = "subbasins", delete_dsn = TRUE, quiet = TRUE)
message("  ", nrow(subbasins), " sub-basins → ", basename(sb_path))

# --- Boundary: Neexdzii Kwa / Wedzin Kwa confluence on Bulkley mainstem ---
blk <- 360873822
drm <- 166030.4
buf <- 2000

# Source rasters from bcfishpass habitat_lateral model
dem_path <- "/Users/airvine/Projects/repo/bcfishpass/model/habitat_lateral/data/temp/BULK/dem.tif"
slope_path <- "/Users/airvine/Projects/repo/bcfishpass/model/habitat_lateral/data/temp/BULK/slope.tif"

out_dir <- here::here("data", "lulc")
fs::dir_create(out_dir)

# --- Load scenarios ---
scenarios <- readr::read_csv(file.path(out_dir, "flood_scenarios.csv"), show_col_types = FALSE)

arg <- commandArgs(trailingOnly = TRUE)[1]
if (!is.na(arg) && arg == "all") {
  run_scenarios <- scenarios
} else {
  sid <- if (is.na(arg) || !arg %in% scenarios$scenario_id) "co_ff045" else arg
  run_scenarios <- scenarios[scenarios$scenario_id == sid, ]
}

message("Scenarios to run: ", paste(run_scenarios$scenario_id, collapse = ", "))

# --- Load DEM/slope once (shared across scenarios) ---
message("Loading DEM and slope...")
dem_full <- terra::rast(dem_path)
slope_full <- terra::rast(slope_path)

# --- Loop scenarios ---
for (i in seq_len(nrow(run_scenarios))) {
  sc <- run_scenarios[i, ]
  message("\n=== Scenario: ", sc$scenario_id, " (ff=", sc$flood_factor,
          ", order>=", sc$min_order, ") ===")
  message("  ", sc$description)

  # --- Extract streams + waterbodies via fresh ---
  message("Querying co habitat (order ", sc$min_order, "+) and waterbodies...")

  results <- frs_network(
    conn,
    blue_line_key = blk,
    downstream_route_measure = drm,
    tables = list(
      streams = list(
        table = "bcfishpass.streams_co_vw",
        cols = c(
          "segmented_stream_id", "blue_line_key", "waterbody_key",
          "downstream_route_measure", "upstream_area_ha",
          "map_upstream", "gnis_name",
          "stream_order", "channel_width", "mapping_code",
          "rearing", "spawning", "access", "geom"
        ),
        wscode_col = "wscode",
        localcode_col = "localcode",
        extra_where = paste0("stream_order >= ", sc$min_order)
      ),
      lakes = "whse_basemapping.fwa_lakes_poly",
      wetlands = "whse_basemapping.fwa_wetlands_poly"
    )
  ) |>
    lapply(sf::st_zm, drop = TRUE)

  streams <- results$streams
  waterbodies <- rbind(
    results$lakes[, c("waterbody_key", "waterbody_type", "area_ha", "geom")],
    results$wetlands[, c("waterbody_key", "waterbody_type", "area_ha", "geom")]
  )

  message("  Streams: ", nrow(streams), " segments")
  message("  Orders: ", paste(sort(unique(streams$stream_order)), collapse = ", "))
  message("  Waterbodies: ", nrow(waterbodies), " features")

  # Save streams
  out_streams <- file.path(out_dir, paste0("streams_neexdzii_", sc$scenario_id, ".gpkg"))
  sf::st_write(streams, out_streams, delete_dsn = TRUE, quiet = TRUE)
  message("  Saved: ", basename(out_streams))

  # --- Crop DEM/slope to stream extent ---
  stream_ext <- terra::ext(terra::vect(streams)) + buf
  dem <- terra::crop(dem_full, stream_ext)
  slope <- terra::crop(slope_full, stream_ext)
  message("  Cropped DEM: ", terra::ncol(dem), " x ", terra::nrow(dem), " pixels")

  # --- Rasterize streams and precipitation ---
  message("  Rasterizing streams...")
  precip_r <- fl_stream_rasterize(streams, dem, field = "map_upstream")

  # --- Run Valley Confinement Algorithm ---
  # TODO: when flooded supports separate anchor_order, pass order 1+ streams
  # for fl_patch_conn() connectivity. For now, same streams for both.
  message("  Running VCA (flood_factor=", sc$flood_factor, ")...")
  valleys <- fl_valley_confine(
    dem, streams,
    field = "upstream_area_ha",
    slope = slope,
    slope_threshold = 9,
    max_width = 2000,
    cost_threshold = 2500,
    flood_factor = sc$flood_factor,
    precip = precip_r,
    waterbodies = waterbodies,
    size_threshold = 5000,
    hole_threshold = 2500
  )

  n_valley <- sum(terra::values(valleys) == 1, na.rm = TRUE)
  message("  Valley cells: ", n_valley, " / ", terra::ncell(valleys),
          " (", round(100 * n_valley / terra::ncell(valleys), 1), "%)")

  # --- Polygonize ---
  message("  Converting to polygons...")
  valleys_poly <- fl_valley_poly(valleys)
  message("  ", nrow(valleys_poly), " polygon features")

  # --- Write outputs ---
  out_raster <- file.path(out_dir, paste0("floodplain_neexdzii_", sc$scenario_id, ".tif"))
  out_vector <- file.path(out_dir, paste0("floodplain_neexdzii_", sc$scenario_id, ".gpkg"))

  terra::writeRaster(valleys, out_raster, overwrite = TRUE)
  sf::st_write(valleys_poly, out_vector, delete_dsn = TRUE, quiet = TRUE)
  message("  Saved: ", basename(out_raster), ", ", basename(out_vector))
}

DBI::dbDisconnect(conn)
message("\nDone. Floodplain AOI(s) ready for drift pipeline (lulc_classify.R).")
