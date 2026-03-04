# fwa_query.R
#
# Query fish observations upstream of Bulkley Falls and Buck Falls
# via fwa_upstream(). Produces an interactive leaflet map with species layers.
#
# Prerequisites: SSH tunnel to DB on port 63333
# Usage: Rscript scripts/fwa_query.R

library(sf)
library(DBI)
library(RPostgres)
library(dplyr)
library(leaflet)
library(htmlwidgets)

sf_use_s2(FALSE)

conn <- dbConnect(
  Postgres(),
  host = "localhost", port = 63333,
  dbname = "bcfishpass", user = "newgraph"
)

# --- Falls positions ----------------------------------------------------------
# Bulkley Falls: price_2014 waypoint 121, indexed via fwapgr
# Buck Falls: from bcfishpass.falls_vw (falls_id e59c47b5-...)

falls <- list(
  bulkley = list(
    name = "Bulkley Falls",
    blk = 360873822L, drm = 233617,
    ws = "400.431358", lc = "400.431358.991041",
    lon = -126.2492, lat = 54.46086
  ),
  buck = list(
    name = "Buck Falls",
    blk = 360886221L, drm = 46656,
    ws = "400.431358.623573", lc = "400.431358.623573.546806",
    lon = NA, lat = NA  # populated from DB below
  )
)

# Get Buck Falls coordinates from DB
buck_coords <- dbGetQuery(conn, "
  SELECT
    ST_X(ST_Transform(geom, 4326)) AS lon,
    ST_Y(ST_Transform(geom, 4326)) AS lat
  FROM bcfishpass.falls_vw
  WHERE falls_id = 'e59c47b5-db49-4929-838a-06bbf1e5d8de'
")
falls$buck$lon <- buck_coords$lon
falls$buck$lat <- buck_coords$lat

# --- Query fish obs upstream of each falls ------------------------------------

query_upstream <- function(f, conn) {
  sql <- glue::glue_sql("
    SELECT
      e.fish_observation_point_id,
      e.species_code,
      s.gnis_name,
      e.observation_date,
      e.life_stage,
      e.source,
      e.source_ref,
      ST_X(ST_Transform(e.geom, 4326)) AS lon,
      ST_Y(ST_Transform(e.geom, 4326)) AS lat
    FROM bcfishobs.fiss_fish_obsrvtn_events_vw e
    JOIN whse_basemapping.fwa_stream_networks_sp s
      ON e.linear_feature_id = s.linear_feature_id
    WHERE e.species_code IN ('CH', 'CO', 'SK')
      AND fwa_upstream(
        {f$blk}::integer, {f$drm}::double precision,
        {f$ws}::ltree, {f$lc}::ltree,
        e.blue_line_key, e.downstream_route_measure,
        e.wscode_ltree, e.localcode_ltree
      )
    ORDER BY e.species_code, e.observation_date DESC
  ", .con = conn)
  dbGetQuery(conn, sql)
}

obs_bulkley <- query_upstream(falls$bulkley, conn)
obs_buck    <- query_upstream(falls$buck, conn)
dbDisconnect(conn)

# --- Print summaries ----------------------------------------------------------

print_summary <- function(obs, name) {
  cat("\n===", name, "===\n")
  cat("Total observations upstream:\n")
  print(obs |> count(species_code, name = "n"))
  cat("\nBy species and stream:\n")
  print(
    obs |>
      group_by(species_code, gnis_name) |>
      summarise(
        n = n(),
        earliest = min(observation_date, na.rm = TRUE),
        latest = max(observation_date, na.rm = TRUE),
        life_stages = paste(unique(na.omit(life_stage)), collapse = ", "),
        .groups = "drop"
      ) |>
      arrange(species_code, desc(latest))
  )
}

print_summary(obs_bulkley, "Bulkley Falls")
print_summary(obs_buck, "Buck Falls")

# --- Leaflet map --------------------------------------------------------------

species_pal <- colorFactor(
  palette = c(CH = "#e41a1c", CO = "#377eb8", SK = "#4daf4a"),
  domain = c("CH", "CO", "SK")
)

obs_all <- bind_rows(
  obs_bulkley |> mutate(upstream_of = "Bulkley Falls"),
  obs_buck    |> mutate(upstream_of = "Buck Falls")
)
obs_sf <- st_as_sf(obs_all, coords = c("lon", "lat"), crs = 4326)

m <- leaflet() |>
  addProviderTiles("Esri.WorldTopoMap") |>
  addMarkers(
    lng = falls$bulkley$lon, lat = falls$bulkley$lat,
    popup = "Bulkley Falls", label = "Bulkley Falls"
  ) |>
  addMarkers(
    lng = falls$buck$lon, lat = falls$buck$lat,
    popup = "Buck Falls", label = "Buck Falls"
  )

# Add each species as a toggleable layer
for (sp in c("CH", "CO", "SK")) {
  sp_label <- c(CH = "Chinook", CO = "Coho", SK = "Sockeye")[[sp]]
  sp_data <- obs_sf |> filter(species_code == sp)
  if (nrow(sp_data) > 0) {
    m <- m |>
      addCircleMarkers(
        data = sp_data,
        color = species_pal(sp),
        radius = 5,
        fillOpacity = 0.7,
        stroke = TRUE,
        weight = 1,
        popup = ~paste0(
          "<b>", species_code, "</b> — ", gnis_name, "<br>",
          "Upstream of: ", upstream_of, "<br>",
          "Date: ", observation_date, "<br>",
          "Life stage: ", life_stage, "<br>",
          "Source: ", source_ref
        ),
        label = ~paste(species_code, gnis_name, observation_date),
        group = sp_label
      )
  }
}

m <- m |>
  addLayersControl(
    overlayGroups = c("Chinook", "Coho", "Sockeye"),
    options = layersControlOptions(collapsed = FALSE)
  ) |>
  addLegend(
    pal = species_pal,
    values = c("CH", "CO", "SK"),
    labels = c("Chinook", "Coho", "Sockeye"),
    title = "Species"
  )

out_path <- "fig/map_fish-obs-above-falls.html"
saveWidget(m, file = normalizePath(out_path, mustWork = FALSE), selfcontained = TRUE)
cat("\nSaved to", out_path, "\n")
