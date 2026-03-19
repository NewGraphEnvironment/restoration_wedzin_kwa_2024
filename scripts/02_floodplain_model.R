#!/usr/bin/env Rscript
#
# 02_floodplain_model.R
#
# 1. Generate sub-basin polygons from break_points.csv via frs_watershed_split()
# 2. Run flooded VCA for each scenario in flood_scenarios.csv
#
# Stream network and waterbodies are pre-built by 01_network_extract.R:
#   data/lulc/fresh_streams_co3.gpkg      (coho-accessible, order 3+)
#   data/lulc/fresh_waterbodies_co3.gpkg   (lakes/wetlands on accessible network)
#
# VCA parameters (flood_factor, slope_threshold, etc.) are read from
# flood_scenarios.csv — each row is a fully specified scenario.
# Only rows with run=TRUE are executed.
#
# Usage:
#   Rscript scripts/02_floodplain_model.R           # runs scenarios where run=TRUE
#   Rscript scripts/02_floodplain_model.R co_ff04   # runs specific scenario
#   Rscript scripts/02_floodplain_model.R all        # runs ALL scenarios (ignores run column)
#
# Requires:
#   - SSH tunnel for sub-basin generation (frs_watershed_split)
#   - DEM/slope from bcfishpass habitat_lateral model
#   - Output from 01_network_extract.R
#
# Outputs:
#   data/lulc/subbasins.gpkg                  (sub-basin polygons)
#   data/lulc/floodplain_{scenario_id}.tif (raster)
#   data/lulc/floodplain_{scenario_id}.gpkg (vector)
#
# Relates to #67, #123, #138

library(flooded)
library(fresh)
library(sf)
library(terra)
library(readr)

sf_use_s2(FALSE)
terra::terraOptions(threads = 12)

out_dir <- here::here("data", "lulc")
buf <- 2000

# --- DB connection (needed for sub-basin generation only) ---
conn <- frs_db_conn()

# --- Step 1: Generate sub-basins from break_points.csv ---
message("=== Generating sub-basins ===")
bp <- readr::read_csv(
  file.path(out_dir, "break_points.csv"),
  show_col_types = FALSE
)
subbasins <- frs_watershed_split(conn, bp)
sb_path <- file.path(out_dir, "subbasins.gpkg")
sf::st_write(subbasins, sb_path, layer = "subbasins", delete_dsn = TRUE, quiet = TRUE)
message("  ", nrow(subbasins), " sub-basins -> ", basename(sb_path))

DBI::dbDisconnect(conn)

# --- Step 2: Load streams and waterbodies from 01_network_extract.R ---
streams_path <- file.path(out_dir, "fresh_streams_co3.gpkg")
wb_path <- file.path(out_dir, "fresh_waterbodies_co3.gpkg")

if (!file.exists(streams_path)) stop("Run 01_network_extract.R first: ", streams_path)
if (!file.exists(wb_path)) stop("Run 01_network_extract.R first: ", wb_path)

message("Loading streams from ", basename(streams_path))
streams <- sf::st_read(streams_path, quiet = TRUE) |> sf::st_zm(drop = TRUE)
# Ensure numeric columns (gpkg can store as character)
for (col in c("upstream_area_ha", "map_upstream", "channel_width", "stream_order")) {
  if (col %in% names(streams)) streams[[col]] <- as.numeric(streams[[col]])
}
message("  ", nrow(streams), " segments, orders: ",
        paste(sort(unique(streams$stream_order)), collapse = ", "))

message("Loading waterbodies from ", basename(wb_path))
waterbodies <- sf::st_read(wb_path, quiet = TRUE) |> sf::st_zm(drop = TRUE)
message("  ", nrow(waterbodies), " features")

# --- DEM/slope ---
dem_path <- "/Users/airvine/Projects/repo/bcfishpass/model/habitat_lateral/data/temp/BULK/dem.tif"
slope_path <- "/Users/airvine/Projects/repo/bcfishpass/model/habitat_lateral/data/temp/BULK/slope.tif"

message("Loading DEM and slope...")
dem_full <- terra::rast(dem_path)
slope_full <- terra::rast(slope_path)

# --- Crop DEM/slope to stream extent (shared across scenarios) ---
stream_ext <- terra::ext(terra::vect(streams)) + buf
dem <- terra::crop(dem_full, stream_ext)
slope <- terra::crop(slope_full, stream_ext)
message("  Cropped DEM: ", terra::ncol(dem), " x ", terra::nrow(dem), " pixels")

# --- Rasterize precipitation (shared across scenarios) ---
message("  Rasterizing precipitation...")
precip_r <- fl_stream_rasterize(streams, dem, field = "map_upstream")

# --- Load scenarios ---
scenarios <- readr::read_csv(file.path(out_dir, "flood_scenarios.csv"), show_col_types = FALSE)

arg <- commandArgs(trailingOnly = TRUE)[1]
if (!is.na(arg) && arg == "all") {
  run_scenarios <- scenarios
} else if (!is.na(arg) && arg %in% scenarios$scenario_id) {
  run_scenarios <- scenarios[scenarios$scenario_id == arg, ]
} else {
  run_scenarios <- scenarios[scenarios$run == TRUE, ]
}

message("Scenarios to run: ", paste(run_scenarios$scenario_id, collapse = ", "))

# --- Loop scenarios ---
for (i in seq_len(nrow(run_scenarios))) {
  sc <- run_scenarios[i, ]
  message("\n=== Scenario: ", sc$scenario_id, " (ff=", sc$flood_factor, ") ===")
  message("  ", sc$description)

  # --- Run Valley Confinement Algorithm ---
  message("  Running VCA (flood_factor=", sc$flood_factor,
          ", slope=", sc$slope_threshold,
          ", max_width=", sc$max_width, ")...")
  valleys <- fl_valley_confine(
    dem, streams,
    field = "upstream_area_ha",
    slope = slope,
    slope_threshold = sc$slope_threshold,
    max_width = sc$max_width,
    cost_threshold = sc$cost_threshold,
    flood_factor = sc$flood_factor,
    precip = precip_r,
    waterbodies = waterbodies,
    size_threshold = sc$size_threshold,
    hole_threshold = sc$hole_threshold
  )

  n_valley <- sum(terra::values(valleys) == 1, na.rm = TRUE)
  message("  Valley cells: ", n_valley, " / ", terra::ncell(valleys),
          " (", round(100 * n_valley / terra::ncell(valleys), 1), "%)")

  # --- Polygonize ---
  message("  Converting to polygons...")
  valleys_poly <- fl_valley_poly(valleys)
  message("  ", nrow(valleys_poly), " polygon features")

  # --- Write outputs ---
  out_raster <- file.path(out_dir, paste0("floodplain_", sc$scenario_id, ".tif"))
  out_vector <- file.path(out_dir, paste0("floodplain_", sc$scenario_id, ".gpkg"))

  terra::writeRaster(valleys, out_raster, overwrite = TRUE)
  sf::st_write(valleys_poly, out_vector, delete_dsn = TRUE, quiet = TRUE)
  message("  Saved: ", basename(out_raster), ", ", basename(out_vector))
}

message("\nDone. Floodplain AOI(s) ready for drift pipeline (03_lulc_classify.R).")
