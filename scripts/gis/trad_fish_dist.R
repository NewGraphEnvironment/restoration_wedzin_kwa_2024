# grab sites
path <- "~/Projects/gis/restoration_wedzin_kwa/sites_prioritized.geojson"

aoi <- sf::st_read("/Users/airvine/Projects/gis/restoration_wedzin_kwa/aoi.geojson") |>
  sf::st_transform(3005)

sites_raw <- sf::st_read(path)


# get sites
path <- "~/Projects/gis/data_secure/wetsuweten_treaty_society/trad_fish_sites_gottesfeld_rabnett2007FishPassage.gpkg"

trad_fish_sites_raw <- sf::st_read(path) |>
  janitor::clean_names() |>
  fpr::fpr_sp_assign_latlong()  |>
  # assign and index
  tibble::rowid_to_column(var = "idx2")




# get closest point on each stream - https://smnorris.github.io/fwapg/04_functions.html
fwa <- purrr::map2(
  trad_fish_sites_raw$lon,
  trad_fish_sites_raw$lat,
  ~fwapgr::fwa_index_point(
    x = .x,
    y = .y,
    # we can adjust this to be sure we get a result for everything
    tolerance = 200,
    limit = 1
    , properties = c(
      # "gnis_name",
      # "distance_to_stream",
      "downstream_route_measure",
      # "linear_feature_id",
      "localcode_ltree",
      "wscode_ltree",
      "blue_line_key"
    )
  )
) |>
  dplyr::bind_rows() |>
  sf::st_drop_geometry()

sites <- sites_raw |>
  # dplyr::slice(40:45) |>
  # dplyr::filter(source %in% c("sites_wfn_proposed", "ncfdc_1998_prescriptions", "/Users/airvine/Projects/gis/restoration_wedzin_kwa/data_field/2024/form_monitoring_ree_2024.gpkg")) |>
  dplyr::select(
    idx:site_name_proposed,
    localcode_ltree,
    wscode_ltree,
    blue_line_key,
    downstream_route_measure
  ) |>
  sf::st_drop_geometry()

trad_fish_sites_prep <- dplyr::bind_cols(
  trad_fish_sites_raw,
  fwa
  ) |>
  sf::st_filter(aoi) |>
  # dplyr::slice(1:5) |>
  dplyr::select(
    idx2,
    site_location,
    localcode_ltree2 = localcode_ltree,
    wscode_ltree2 = wscode_ltree,
    blue_line_key2 = blue_line_key,
    downstream_route_measure2 = downstream_route_measure
  ) |>
  sf::st_drop_geometry()

input <- tidyr::crossing(
  sites,
  trad_fish_sites_prep
) |>
  # make unique cross index site/site idx_x
  dplyr::mutate(idx_x = paste(idx, site_location, sep = "_"))

# this works
t <- fwapgr::fwa_network_trace(
  trad_fish_sites_prep$blue_line_key[1],
  trad_fish_sites_prep$downstream_route_measure[1],
  trad_fish_sites_prep$blue_line_key[3],
  trad_fish_sites_prep$downstream_route_measure[3]
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

# save to rds so we don't need to redo for now
res |>
  saveRDS(file = "data/inputs_extracted/fwa_network_trace.rds")
usethis::use_git_ignore("data/inputs_extracted/fwa_network_trace.rds")

res <- readRDS("data/inputs_extracted/fwa_network_trace.rds")

#fwa_network_trace SQL -----------------------------------------------------------------------------------------------------
# OR DO IT ALL AT ONCE DIRECT - this query takes 7 minutes to run....
vals <- input |>

  # dplyr::slice(1:100) |>

  dplyr::rowwise() |>
  dplyr::mutate(
    sql_row = glue::glue("({blue_line_key}, {downstream_route_measure}, {blue_line_key2}, {downstream_route_measure2})")
  ) |>
  dplyr::pull(sql_row) |>
  paste(collapse = ",\n")

sql <- glue::glue("
  SELECT
    v.*,
    t.*
  FROM (
    VALUES
      {vals}
  ) AS v(
    blue_line_key_a,
    measure_a,
    blue_line_key_b,
    measure_b
  )
  JOIN LATERAL whse_basemapping.fwa_networktrace(
    blue_line_key_a,
    measure_a,
    blue_line_key_b,
    measure_b
  ) AS t ON TRUE
")

res_sql <- fpr::fpr_db_query(sql)

names(res[[1]])

# isolate a site for testing
t <- res |>
  dplyr::filter(stringr::str_detect(idx, "138"))

# test using thhe remote server to get upstream or downstream

fpr::fpr_db_query("select * from whse_basemapping.fwa_downstream(360873822, 0, 360881038, 0)")
fpr::fpr_db_query("select * from FWA_NetworkTrace(
  360881038,
  1185,
 360873822,
  258082
)"
)

t <- fpr::fpr_db_query(
  "SELECT
  n.nspname AS schema,
  p.proname AS function_name,
  pg_catalog.pg_get_function_arguments(p.oid) AS arguments,
  pg_catalog.pg_get_function_result(p.oid) AS return_type
FROM pg_catalog.pg_proc p
JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'whse_basemapping'
  AND p.proname = 'fwa_downstream'
ORDER BY p.proname;"
)

wscode_ltree_a = ngr::ngr_dbqs_ltree("400.431358.623573")
localcode_ltree_a = ngr::ngr_dbqs_ltree("400.431358.623573.718570")
wscode_ltree_b = ngr::ngr_dbqs_ltree("400.431358.623573")
localcode_ltree_b = ngr::ngr_dbqs_ltree("400.431358.623573.883279")


# this works!!
fwa_ds <- function(){
  fpr::fpr_db_query(
  glue::glue(
    "SELECT whse_basemapping.fwa_downstream(
      {blue_line_key_a},
      {downstream_route_measure_a},
      {wscode_ltree_a},
      {localcode_ltree_a},
      {blue_line_key_b},
      {downstream_route_measure_b},
      {wscode_ltree_b},
      {localcode_ltree_b}
    );"
  )
)
}

fwa_ds <- function(
    blue_line_key_a,
    downstream_route_measure_a,
    wscode_ltree_a,
    localcode_ltree_a,
    blue_line_key_b,
    downstream_route_measure_b,
    wscode_ltree_b,
    localcode_ltree_b
){

  fpr::fpr_db_query(
    glue::glue(
      "SELECT whse_basemapping.fwa_downstream(
        {blue_line_key_a},
        {downstream_route_measure_a},
        {wscode_ltree_a},
        {localcode_ltree_a},
        {blue_line_key_b},
        {downstream_route_measure_b},
        {wscode_ltree_b},
        {localcode_ltree_b}
      );"
    )
  )
}

input_prep <- input |>
  dplyr::slice(1:10)

test <- purrr::pmap(
  list(
    input_prep$blue_line_key,
    input_prep$downstream_route_measure,
    ngr::ngr_dbqs_ltree(input_prep$wscode_ltree),
    ngr::ngr_dbqs_ltree(input_prep$localcode_ltree),
    input_prep$blue_line_key2,
    input_prep$downstream_route_measure2,
    ngr::ngr_dbqs_ltree(input_prep$wscode_ltree2),
    ngr::ngr_dbqs_ltree(input_prep$localcode_ltree2)
  ),
  fwa_ds
)

#try to run all the queries at once-----------------------------------------------------------------------------------------------------
# Prepare the VALUES clause
vals <- input |>
  dplyr::mutate(across(
    .cols = dplyr::matches("ltree"),
    .fns = ngr::ngr_dbqs_ltree
  )) |>
  dplyr::rowwise() |>
  dplyr::mutate(sql_row = glue::glue("({blue_line_key}, {downstream_route_measure}, {wscode_ltree}, {localcode_ltree}, {blue_line_key2}, {downstream_route_measure2}, {wscode_ltree2}, {localcode_ltree2})")) |>
  dplyr::pull(sql_row) |>
  paste(collapse = ",\n")

# Build the query
sql <- glue::glue("
  SELECT
    v.*,
    r.*
  FROM (
    VALUES
      {vals}
  ) AS v(
    blue_line_key_a,
    downstream_route_measure_a,
    wscode_ltree_a,
    localcode_ltree_a,
    blue_line_key_b,
    downstream_route_measure_b,
    wscode_ltree_b,
    localcode_ltree_b
  )
  JOIN LATERAL whse_basemapping.fwa_downstream(
    blue_line_key_a,
    downstream_route_measure_a,
    wscode_ltree_a,
    localcode_ltree_a,
    blue_line_key_b,
    downstream_route_measure_b,
    wscode_ltree_b,
    localcode_ltree_b
  ) AS r ON TRUE
")

# Run it
res <- fpr::fpr_db_query(sql)




fpr::fpr_db_query(
  glue::glue(
    "SELECT whse_basemapping.fwa_downstream(
      {wscode_ltree_a},
      {localcode_ltree_a},
      {wscode_ltree_b},
      {localcode_ltree_b}
    );"
  )
)

ngr_pg_ltree(res$localcode[1:5])



fpr::fpr_db_query("
  SELECT whse_basemapping.fwa_downstream(
    360873822,                  -- blue_line_key_a
    0.0,                        -- downstream_route_measure_a
    '100.100000.000100'::ltree, -- wscode_ltree_a
    '100.100000.000100'::ltree, -- localcode_ltree_a
    360881038,                  -- blue_line_key_b
    0.0,                        -- downstream_route_measure_b
    '100.100000'::ltree,        -- wscode_ltree_b
    '100.100000'::ltree         -- localcode_ltree_b
  );
")


# calculate length for each row, group by idx and sum, arrange by sum descending
res_sum <- res |>
  dplyr::mutate(length = as.numeric(sf::st_length(geometry))) |>
  dplyr::group_by(idx) |>
  sf::st_drop_geometry() |>
  dplyr::summarise(length_m = sum(length)) |>
  dplyr::arrange(length_m)


mapview::mapview(sf::st_zm(res |> dplyr::filter(idx == "28_Bulkley Lake outlet")))
plot(t)
