# setup.R — External paths for pipeline scripts
#
# Source this at the top of any script that needs files outside the repo.
# Edit these paths if your file system layout differs from the default.
#
# Usage:
#   source("scripts/setup.R")

# GIS project (Mergin Maps sync, shared layers)
path_gis <- "/Users/airvine/Projects/gis/restoration_wedzin_kwa"

# DEM and slope (clipped to AOI, stored in GIS project)
path_dem <- file.path(path_gis, "dem_neexdzii.tif")
path_slope <- file.path(path_gis, "slope_neexdzii.tif")
