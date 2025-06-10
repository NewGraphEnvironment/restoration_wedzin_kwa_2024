# Convert the traditional fishing sites documented Skeena Fish Populations and their Habitat, by Gottesfeld and Rabnett 2007,
# which are stored in "data/trad_fish_sites_wilson_rabnett2007FishPassage.csv" to a spatial object for visualization in QGIS

path <- "~/Projects/gis/data_secure/wetsuweten_treaty_society/trad_fish_sites_gottesfeld_rabnett2007FishPassage.csv"
path_out <- "~/Projects/gis/data_secure/wetsuweten_treaty_society/trad_fish_sites_gottesfeld_rabnett2007FishPassage.gpkg"

trad_fish_sites_raw <- readr::read_csv(path) |>
  dplyr::filter(!is.na(utm_zone)) |>
  fpr::fpr_sp_assign_sf_from_utm() |>
  # get lat long
  fpr::fpr_sp_assign_latlong()


  # get closest point on each stream - https://smnorris.github.io/fwapg/04_functions.html
fwa <- purrr::map2(
  trad_fish_sites_raw$lon,
  trad_fish_sites_raw$lat,
    ~fwapgr::fwa_index_point(
      x = .x,
      y = .y,
      # we can adjust this to be sure we get a result for everything
      tolerance = 100,
      limit = 1
      , properties = c(
        "gnis_name",
        "distance_to_stream",
        "downstream_route_measure",
        "linear_feature_id",
        "localcode_ltree",
        "wscode_ltree",
        "blue_line_key"
      )
    )
  ) |>
  dplyr::bind_rows()

trad_fish_sites <- dplyr::bind_cols(
  trad_fish_sites_raw,
  fwa
)

t <- purrr::map2(
  trad_fish_sites_raw$lon,
  trad_fish_sites_raw$lat,
  ~fwapgr::fwa_index_point(
    x = .x,
    y = .y,
    # we can adjust this to be sure we get a result for everything
    tolerance = 100,
    limit = 1
    , properties = c(
      "gnis_name",
      "distance_to_stream",
      "downstream_route_measure",
      "linear_feature_id",
      "localcode_ltree",
      "wscode_ltree",
      "blue_line_key"
    )
  )
)



sf::st_write(dsn = path_out,
               layer = "trad_fish_sites",
               delete_layer = TRUE,
               quite = TRUE)
