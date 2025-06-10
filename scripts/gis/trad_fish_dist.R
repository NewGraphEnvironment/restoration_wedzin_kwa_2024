# grab sites
path <- "/Users/airvine/Projects/gis/data_secure/wetsuweten_treaty_society/sites_prioritized.geojson"

aoi <- sf::st_read("/Users/airvine/Projects/gis/restoration_wedzin_kwa/aoi.geojson") |>
  sf::st_transform(3005)

sites_raw <- sf::st_read(path)

sites <- sites_raw |>
  # dplyr::slice(40:45) |>
  dplyr::filter(source %in% c("sites_wfn_proposed", "ncfdc_1998_prescriptions", "/Users/airvine/Projects/gis/restoration_wedzin_kwa/data_field/2024/form_monitoring_ree_2024.gpkg")) |>
  dplyr::select(
    idx:site_name_proposed,
    blue_line_key,
    downstream_route_measure
  ) |>
  sf::st_drop_geometry()

trad_fish_sites_t <- trad_fish_sites |>
  sf::st_filter(aoi) |>
  # dplyr::slice(1:5) |>
  dplyr::select(
    site_trad = `Site Location`,
    blue_line_key2 = blue_line_key,,
    downstream_route_measure2 = downstream_route_measure
    ) |>
  # assign and index
  tibble::rowid_to_column(var = "idx2") |>
  sf::st_drop_geometry()

input <- tidyr::crossing(
  sites,
  trad_fish_sites_t
) |>
  # make unique cross index site/site idx_x
  dplyr::mutate(idx_x = paste(idx, site_trad, sep = "_"))

# this works
t <- fwapgr::fwa_network_trace(
    trad_fish_sites$blue_line_key[1],
    trad_fish_sites$downstream_route_measure[1],
    trad_fish_sites$blue_line_key[3],
    trad_fish_sites$downstream_route_measure[3]
)

res <- purrr::pmap(
  input,
  function(blue_line_key, downstream_route_measure, blue_line_key2, downstream_route_measure2, ...) {
    fwapgr::fwa_network_trace(
      blue_line_key_a = blue_line_key,
      measure_a = downstream_route_measure,
      blue_line_key_b = blue_line_key2,
      measure_b = downstream_route_measure2,
      epsg = 3005,
      properties = c(
        "blue_line_key",
        "downstream_route_measure",
        "localcode",
        "wscode"
        )
    )
  }
) |>
  purrr::set_names(nm = input$idx_x) |>
  dplyr::bind_rows(.id = "idx")

names(results[[1]])

# calculate length for each row, group by idx and sum, arrange by sum descending
res_sum <- res |>
  dplyr::mutate(length = as.numeric(sf::st_length(geometry))) |>
  dplyr::group_by(idx) |>
  sf::st_drop_geometry() |>
  dplyr::summarise(length_m = sum(length)) |>
  dplyr::arrange(length_m)


mapview::mapview(sf::st_zm(res |> dplyr::filter(idx == "41_Sunset Lake")))
plot(t)
