# Convert the traditional fishing sites documented Skeena Fish Populations and their Habitat, by Gottesfeld and Rabnett 2007,
# which are stored in "data/trad_fish_sites_wilson_rabnett2007FishPassage.csv" to a spatial object for visualization in QGIS

path <- "data/inputs_raw/traditional_names_places.csv"
path_out <- "~/Projects/gis/restoration_wedzin_kwa_2024/traditional_names_places_morin2016.gpkg"

d_raw <- readr::read_csv(path) |>
  dplyr::filter(!is.na(utm_zone)) |>
  fpr::fpr_sp_assign_sf_from_utm() |>
  # get lat long
  fpr::fpr_sp_assign_latlong()



sf::st_write(dsn = path_out,
             delete_layer = TRUE,
             quite = TRUE)
