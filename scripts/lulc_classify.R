#!/usr/bin/env Rscript
#
# lulc_classify.R
#
# Land cover classification and transition detection for the Neexdzii Kwa
# modelled floodplain. Two passes:
#   1. Whole-floodplain: classify + transition for interactive map
#   2. Per-sub-basin: summarize for tables/plots
#
# Consumes subbasins.gpkg (from break app) and floodplain_neexdzii_co.gpkg
# (from flooded). Runs drift pipeline: fetch, classify, summarize, transition.
#
# Outputs to data/lulc/:
#   lulc_summary.rds       — area/pct by class, sub-basin, year (for tables)
#   rasters/floodplain/    — classified + transition tifs (for interactive map)
#
# Gated by params$update_lulc in index.Rmd
#
# Relates to #116, #67

library(drift)
library(sf)
library(terra)
library(dplyr)

sf::sf_use_s2(FALSE)
terra::terraOptions(threads = 12)

out_dir <- here::here("data", "lulc")
ag_classes <- c("Crops", "Rangeland", "Bare Ground")
years <- c(2017, 2020, 2023)

# --- Load inputs ---
subbasins <- sf::st_read(
  file.path(out_dir, "subbasins.gpkg"), quiet = TRUE
) |> sf::st_transform(4326)

floodplain <- sf::st_read(
  file.path(out_dir, "floodplain_neexdzii_co.gpkg"), quiet = TRUE
) |> sf::st_transform(4326)

# Use name_basin from break_points.csv (carried through via fresh::frs_watershed_split)

# --- Pass 1: Whole floodplain (for interactive map) ---
message("=== Whole floodplain ===")
rasters_all <- dft_stac_fetch(floodplain, source = "io-lulc", years = years)
classified_all <- dft_rast_classify(rasters_all, source = "io-lulc")
trans_all <- dft_rast_transition(
  classified_all, from = "2017", to = "2023",
  from_class = "Trees"
)

# Save rasters as tif
fp_dir <- file.path(out_dir, "rasters", "floodplain")
dir.create(fp_dir, recursive = TRUE, showWarnings = FALSE)
for (yr in names(classified_all)) {
  terra::writeRaster(classified_all[[yr]], file.path(fp_dir, paste0("classified_", yr, ".tif")),
                     overwrite = TRUE, datatype = "INT1U")
}
if (nrow(trans_all$summary) > 0) {
  terra::writeRaster(trans_all$raster, file.path(fp_dir, "transition.tif"),
                     overwrite = TRUE, datatype = "INT4S")
}
message("Floodplain rasters saved to ", fp_dir)

# --- Pass 2: Per-sub-basin summaries (for tables/plots) ---
message("\n=== Per-sub-basin summaries ===")
results <- list()

for (i in seq_len(nrow(subbasins))) {
  sb <- subbasins[i, ]
  lab <- sb$name_basin

  fp_clip <- sf::st_intersection(floodplain, sb) |>
    sf::st_collection_extract("POLYGON") |>
    sf::st_union() |>
    sf::st_sf(geometry = _)
  sf::st_crs(fp_clip) <- sf::st_crs(floodplain)

  if (nrow(fp_clip) == 0 || as.numeric(sf::st_area(fp_clip)) < 1e4) {
    message("Skipping ", lab, " -- no floodplain overlap")
    next
  }

  message("Processing: ", lab)
  rasters <- dft_stac_fetch(fp_clip, source = "io-lulc", years = years)
  classified <- dft_rast_classify(rasters, source = "io-lulc")
  summary <- dft_rast_summarize(classified, unit = "ha")
  summary$subbasin <- lab
  results[[i]] <- summary
}

# --- Save ---
lulc_summary <- dplyr::bind_rows(results)
saveRDS(lulc_summary, file.path(out_dir, "lulc_summary.rds"))

message("\nDone. Outputs in ", out_dir)
