# wrangle the Nadina prescriptions into a spatial dataset

# make a subset of the stream/blk xref used in fwatlasbc::fwa_add_blks_to_stream_name
xref_str_blk <- fwatlasbc::fwa_stream_name |>
  dplyr::filter(stringr::str_starts(as.character(blk), "360"))

#reach breaks-----------------------------------------------------------------------------------------------------
path_reach <- 'data/inputs_raw/ncfdc_1998/reach_breaks.csv'
reaches_raw <- readr::read_csv(path_reach)



reaches <- reaches_raw |>
  # need to ditch those we don't have coords for
  dplyr::filter(!is.na(easting_fhap)) |>
  sf::st_as_sf(coords = c("easting_fhap", "northing_fhap"), crs = 32609, remove = FALSE) |>
  # create stream_name column so we can use fwatlasbc::fwa_add_blks_to_stream_name to get blueline key
  dplyr::mutate(
    stream_name = stringr::str_remove(reach_name_corrected, "\\s\\d+$") |>
      paste("Creek") |>
      stringr::str_replace("^Bulkley Creek$", "Bulkley River")
  ) |>
  # add the bluelinekey
  fwatlasbc::fwa_add_blks_to_stream_name(stream_name = xref_str_blk)
  # sf::st_transform(crs = 4326)

# burn to project for viewing
reaches |>
  sf::st_write("/Users/airvine/Projects/gis/restoration_wedzin_kwa/ncfdc_1998_reach_breaks_raw.geojson", delete_dsn = TRUE)

################################################################################################################
#-------From here we added many reaches from georeffed pdfs and moved some others---------------------------------------------------
################################################################################################################


# corrected and added reach breaks in Q
path_reach <- "~/Projects/gis/restoration_wedzin_kwa/ncfdc_1998_reach_breaks.geojson"
reaches_raw <- sf::st_read(path_reach) |>
  fpr::fpr_sp_assign_latlong()

# get the downtreawm_route_measure for the breaks
# here we grab the point on a stream corresponding to the river metre
fwa <- purrr::map2(
  reaches_raw$lon,
  reaches_raw$lat,
  ~fwapgr::fwa_index_point(
    x = .x,
    y = .y,
    tolerance = 1000,
    properties = c("downstream_route_measure")
  )
) |>
  dplyr::bind_rows() |>
  sf::st_drop_geometry()

reaches_prep <- dplyr::bind_cols(
  reaches_raw,
  fwa
)

# get the prescriptions
path <- 'data/inputs_raw/ncfdc_1998/AppF_riparian_prescriptions.xls'

# list all the sheet in the file (path)
d_sheets <- readxl::excel_sheets(path)

# d_types <- readxl::read_excel(path) |>
#   janitor::clean_names()

# get the boudnign box of the Neexdzi Kwah - we burn it local so we don't repeat
# blueline key
# blk <- 360873822
# # downstream route measure
# drm <- 166030.4
# aoi <- fwapgr::fwa_watershed_at_measure(blue_line_key = blk,
#                                             downstream_route_measure = drm) |>
#   # we put it in wsg84
#   sf::st_transform(4326)
#   # dplyr::select(geometry)
#
# # burn it to file
# sf::st_write(aoi, "data/gis/aoi.geojson")

aoi <- sf::st_read("data/gis/aoi.geojson")

#get the bounding box of our aoi
aoi_bb <- sf::st_bbox(aoi)




# Function to conditionally rename columns
col_rename <- function(df) {
  if ("distance_u_s" %in% names(df)) {
    df <- dplyr::rename(df, distance_u_s_km_m = distance_u_s)
  }
  df
}

# read in all the sheets
d_raw <- purrr::map(d_sheets, ~readxl::read_excel(path, sheet = .x)) |>
  purrr::map(janitor::clean_names) |>
  purrr::set_names(d_sheets) |>
  # make all columns character
  purrr::map(~dplyr::mutate_all(., as.character)) |>
  # sometimes distance_u_s_km_m and sometimes distance_u_s
  purrr::map(col_rename) |>
  dplyr::bind_rows(.id = "sheet_name")


rm_buck_reach12 <- reaches |>
  dplyr::filter(
    reach_name_corrected == "Buck 12"
  ) |>
  dplyr::pull(downstream_route_measure)

# join the drm for the bottom of each reach to each prescription
pres_prep <- dplyr::left_join(
  d_raw,
  reaches_prep |>
    dplyr::select(
      reach_name_corrected,
      rm_reach = downstream_route_measure
    ) |>
    # we are just interested in drm and blk so don't need the geom anymore
    sf::st_drop_geometry(),
  by = c("sheet_name" = "reach_name_corrected")
) |>
  # we have a funky value in the distance column of the `Buck 11` sheet - had said "72577" (to be near culvert? not sure)
  # but we will use random number more likley to be near to chainage from reach break and replace after
  dplyr::mutate(distance_u_s_km_m = dplyr::case_when(riparian_poly_id == "UB8/Impact Site 1" ~ "2400",
                                                     TRUE ~ distance_u_s_km_m)) |>
  dplyr::mutate(stream_name = dplyr::case_when(stringr::str_detect(sheet_name, "Bulkley") ~ stringr::str_replace(sheet_name, "\\s\\d+$", " River"),
                                               T ~ stringr::str_replace(sheet_name, "\\s\\d+$", " Creek")),
                rm_prep = as.numeric(stringr::str_remove(distance_u_s_km_m, "\\+")),
                # when reach is not 1 or it is the Bulkley add the rm_reach
                rm_adjusted = dplyr::case_when(
                  # note the regex to deal with matches like 11. just doesn't do the move if 1 is at the end
                  !stringr::str_detect(sheet_name, " 1$") ~ rm_prep + rm_reach,
                  # bulkley is a special case since it is actually 170 some km upstream from 0 drm
                  sheet_name == "Bulkley 1" ~ rm_prep + rm_reach
                ),
                # another special case here where we have Buck 11b being considered the "Reach" and a note that
                # it starts 2405m downstream of Reach 12 (drm = )
                rm_adjusted = dplyr::case_when(
                  sheet_name == "Buck 11" ~  rm_prep + rm_buck_reach12 - 2500,
                  TRUE ~ rm_adjusted
                ),
                rm = dplyr::case_when(
                  !is.na(rm_adjusted) ~ rm_adjusted,
                  TRUE ~ rm_prep
                )

  )  |>
  # dplyr::select(
  #   -rm_reach,
  #   -rm_prep,
  #   -rm_adjusted
  # ) |>
  # add the bluelinekey
  fwatlasbc::fwa_add_blks_to_stream_name(stream_name = xref_str_blk)

# get a spatial object for each of the prescriptions
fwa <- purrr::map2(
  pres_prep$blk,
  pres_prep$rm,
  ~fwapgr::fwa_locate_along(
    blue_line_key = .x,
    downstream_route_measure = .y,
    epsg = 3005
  )
) |>
  dplyr::bind_rows()

# join the prescriptions to the geom
pres_prep2 <- dplyr::bind_cols(
  pres_prep,
  fwa
) |>
  sf::st_as_sf() |>
  # assign coordinates so that we can see how much they moved
  fpr::fpr_sp_assign_utm(
    col_easting = "easting_og",
    col_northing = "northing_og"
  )

#riparian polygon descriptions-----------------------------------------------------------------------------------------------------

# get the prescriptions
path <- 'data/inputs_raw/ncfdc_1998/AppD_riparian_polygons.xls'

# list all the sheet in the file (path)
d_sheets <- readxl::excel_sheets(path)

# read in all the sheets
rip_poly_raw <- purrr::map(d_sheets, ~readxl::read_excel(path, sheet = .x)) |>
  purrr::map(~janitor::remove_empty(.x)) |>
  purrr::set_names(d_sheets) |>
  # make all columns character
  purrr::map(~dplyr::mutate_all(., as.character)) |>
  # sometimes distance_u_s_km_m and sometimes distance_u_s
  # purrr::map(col_rename) |>
  dplyr::bind_rows(.id = "sheet_name_poly") |>
  janitor::remove_empty() |>
  janitor::clean_names() |>
  # unnecessary extra columns (some hidden)  so remove
  dplyr::select(sheet_name_poly:section)

# join to the polygons
pres <- dplyr::left_join(
  pres_prep2,
  rip_poly_raw,
  by = c("riparian_poly_id" = "polygon_id")
) |>
  # remove the buck reach 5 prescriptions as obviously incorrect as per https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/91
  dplyr::filter(sheet_name != "Buck 5")


mapview::mapview(
  sf::st_zm(pres)
)

# burn to file
pres |>
  sf::st_write(
    "~/Projects/gis/restoration_wedzin_kwa/sites_restoration.gpkg",
    layer = "ncfdc_1998_riparian_raw",
    delete_layer = TRUE
    )


