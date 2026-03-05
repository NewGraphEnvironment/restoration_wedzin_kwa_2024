#!/usr/bin/env Rscript
#
# lulc_network-extract.R
#
# Extract coho rearing/spawning stream network for the full Neexdzii Kwa
# (Upper Bulkley) and generate a floodplain AOI using the flooded package.
#
# The floodplain polygon is then used by lulc_classify.R (drift pipeline)
# to quantify land cover change across the floodplain.
#
# Stream network scoping:
#   - Coho (co) rearing and spawning habitat
#   - Stream order >= 4 (4th order and above — streams with floodplains)
#   - Upstream of Neexdzii Kwa / Wedzin Kwa confluence
#
# Requires:
#   - SSH tunnel: ssh -L 63333:<db_host>:5432 <ssh_host>
#   - R packages: flooded, sf, terra, DBI, RPostgres, glue
#   - DEM/slope from bcfishpass habitat_lateral model
#
# Pattern adapted from airbc/data-raw/floodplain_neexdzii_co.R
#
# Output:
#   data/lulc/floodplain_neexdzii_co.tif   (raster)
#   data/lulc/floodplain_neexdzii_co.gpkg  (vector)
#   data/lulc/streams_neexdzii_co.gpkg     (stream network used)
#
# Relates to #67

library(flooded)
library(sf)
library(terra)
library(DBI)
library(RPostgres)
library(glue)

sf_use_s2(FALSE)
terra::terraOptions(threads = 12)

# --- Parameters ---
# Neexdzii Kwa / Wedzin Kwa confluence on the Bulkley mainstem
blk <- 360873822
drm <- 166030.4
min_order <- 4
buf <- 2000 # buffer around streams for DEM crop (metres)

# Source rasters from bcfishpass habitat_lateral model
dem_path <- "/Users/airvine/Projects/repo/bcfishpass/model/habitat_lateral/data/temp/BULK/dem.tif"
slope_path <- "/Users/airvine/Projects/repo/bcfishpass/model/habitat_lateral/data/temp/BULK/slope.tif"

# Output directory
out_dir <- here::here("data", "lulc")
fs::dir_create(out_dir)

out_raster <- file.path(out_dir, "floodplain_neexdzii_co.tif")
out_vector <- file.path(out_dir, "floodplain_neexdzii_co.gpkg")
out_streams <- file.path(out_dir, "streams_neexdzii_co.gpkg")

# --- Connect to bcfishpass DB ---
message("Connecting to bcfishpass DB on localhost:63333...")
conn <- DBI::dbConnect(
  RPostgres::Postgres(),
  host = "localhost", port = 63333,
  dbname = "bcfishpass", user = "newgraph"
)

# --- Query coho rearing/spawning streams upstream of confluence ---
# Stream order >= min_order to get streams large enough to have floodplains.
# Uses FWA_Upstream() to get all streams upstream of the Neexdzii Kwa mouth.
sql <- glue::glue("
  WITH mouth AS (
    SELECT wscode, localcode
    FROM bcfishpass.streams_co_vw
    WHERE blue_line_key = {blk}
      AND downstream_route_measure <= {drm}
    ORDER BY downstream_route_measure DESC
    LIMIT 1
  )
  SELECT s.segmented_stream_id, s.blue_line_key, s.waterbody_key,
         s.downstream_route_measure, s.upstream_area_ha,
         s.map_upstream, s.gnis_name,
         s.stream_order, s.channel_width, s.mapping_code,
         s.rearing, s.spawning, s.access, s.geom
  FROM bcfishpass.streams_co_vw s, mouth m
  WHERE s.watershed_group_code = 'BULK'
    AND s.stream_order >= {min_order}
    AND (s.rearing > 0 OR s.spawning > 0)
    AND FWA_Upstream(
      m.wscode, m.localcode,
      s.wscode, s.localcode
    )
")

message(
  "Querying coho rearing/spawning streams upstream of blk ", blk,
  " drm ", drm, " (order >= ", min_order, ")..."
)
streams <- sf::st_read(conn, query = sql) |>
  sf::st_zm(drop = TRUE)

DBI::dbDisconnect(conn)

message("  ", nrow(streams), " segments")
message("  Streams: ", paste(unique(na.omit(streams$gnis_name)), collapse = ", "))
message("  Orders: ", paste(sort(unique(streams$stream_order)), collapse = ", "))
message(
  "  Upstream area range: ",
  paste(range(streams$upstream_area_ha, na.rm = TRUE), collapse = " - "), " ha"
)

# Save stream network for reference and sub-basin slicing
sf::st_write(streams, out_streams, delete_dsn = TRUE, quiet = TRUE)
message("Saved streams: ", out_streams)

# --- Load and crop DEM/slope to stream extent ---
message("Loading DEM and slope...")
dem_full <- terra::rast(dem_path)
slope_full <- terra::rast(slope_path)

stream_ext <- terra::ext(terra::vect(streams)) + buf
dem <- terra::crop(dem_full, stream_ext)
slope <- terra::crop(slope_full, stream_ext)

message("  Cropped DEM: ", terra::ncol(dem), " x ", terra::nrow(dem), " pixels")

# --- Rasterize streams and precipitation ---
message("Rasterizing streams...")
stream_r <- fl_stream_rasterize(streams, dem, field = "upstream_area_ha")
precip_r <- fl_stream_rasterize(streams, dem, field = "map_upstream")

# --- Run Valley Confinement Algorithm ---
message("Running valley confinement algorithm...")
valleys <- fl_valley_confine(
  dem, streams,
  field = "upstream_area_ha",
  slope = slope,
  slope_threshold = 9,
  max_width = 2000,
  cost_threshold = 2500,
  flood_factor = 6,
  precip = precip_r,
  size_threshold = 5000,
  hole_threshold = 2500
)

n_valley <- sum(terra::values(valleys) == 1, na.rm = TRUE)
message(
  "  Valley cells: ", n_valley, " / ", terra::ncell(valleys),
  " (", round(100 * n_valley / terra::ncell(valleys), 1), "%)"
)

# --- Polygonize ---
message("Converting to polygons...")
valleys_poly <- fl_valley_poly(valleys)
message("  ", nrow(valleys_poly), " polygon features")

# --- Write outputs ---
terra::writeRaster(valleys, out_raster, overwrite = TRUE)
message("Saved raster: ", out_raster)

sf::st_write(valleys_poly, out_vector, delete_dsn = TRUE, quiet = TRUE)
message("Saved vector: ", out_vector)

message("Done. Floodplain AOI ready for drift pipeline (lulc_classify.R).")
