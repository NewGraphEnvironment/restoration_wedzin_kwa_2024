# this script will put all the site forms from 2024 and 2025 (june) into one form and burn back to the project so we
# can more easily view in QGIS and elsewhere

path_gis <- "/Users/airvine/Projects/gis/restoration_wedzin_kwa/data_field/sites_reviewed_2024_202506.geojson"
path_repo <- "data/gis/sites_reviewed_2024_202506.geojson"


forms_ls <- c(
  "~/Projects/gis/restoration_wedzin_kwa/data_field/2024/form_monitoring_ree_2024.gpkg",
  "~/Projects/gis/restoration_wedzin_kwa/data_field/2024/form_monitoring_ree_20240923.gpkg",
  "~/Projects/gis/restoration_wedzin_kwa/data_field/2024/form_fiss_site_fraser_2024.gpkg",
#   stream walks
  # "~/Projects/gis/restoration_wedzin_kwa/data_field/2024/form_fiss_site_2024.gpkg",
  "~/Projects/gis/restoration_wedzin_kwa/data_field/2025/form_monitoring_ree_2025.gpkg"
)



form_prep <- forms_ls |>
  purrr::map(
    ~ fpr::fpr_sp_gpkg_backup(
      path_gpkg = .x,
      update_utm = TRUE,
      return_object = TRUE,
      write_to_rdata = FALSE
    )
  ) |>
  purrr::set_names(basename(forms_ls))

form_prep <- form_prep |>
  purrr::map(
    ~ ngr::ngr_tidy_type(
      dat_w_types = form_prep$form_monitoring_ree_2025.gpkg,
      dat_to_type = .x)
  ) |>
  dplyr::bind_rows(.id = "source") |>
  ngr::ngr_tidy_cols_rm_na() |>
  dplyr::mutate(dplyr::across(dplyr::matches("length|meters"), as.numeric)) |>
  dplyr::mutate(
    site_id = dplyr::case_when(is.na(site_id) ~ site_name, T ~ site_id),
    site_id = dplyr::case_when(is.na(site_id) ~ local_name, T ~ site_id),
    stream_name = dplyr::case_when(is.na(stream_name) ~ gazetted_names, T ~ stream_name),
    length_meters = dplyr::case_when(is.na(length_meters) ~ site_length, T ~ length_meters),
    assessment_comment = dplyr::case_when(is.na(assessment_comment) ~ comments, T ~ assessment_comment)
    )

cols_photos <- names(form_prep)[stringr::str_detect(names(form_prep), "photo")]
cols_notes <- names(form_prep)[stringr::str_detect(names(form_prep), "notes")]
cols_rm <- c(
  "site_name",
  "local_name",
  "link_method_site_card",
  "site_length",
  "no_visible_channel",
  "comments",
  "crossing_type",
  "crossing_subtype"
)

cols_start <- c(
  "source",
  "date_time_start",
  "site_id",
  "site_name_wfn",
  "stream_name",
  "land_owner",
  "new_site",
  "uav_flight",
  "width_meters",
  "length_meters",
  "assessment_comment",
  "habitat_comment",
  "works_completed",
  "citation_key"
)

cols_all <- setdiff(
  names(form_prep),
  c(
    cols_photos,
    cols_notes,
    cols_start,
    cols_rm)
  )

form <- form_prep |>
  dplyr::select(
    dplyr::all_of(cols_start),
    dplyr::all_of(cols_notes),
    dplyr::all_of(cols_all),
    dplyr::all_of(cols_photos)
  )


# burn to the project
# first remove the old layer if exists

if(fs::file_exists(path_gis)){
  fs::file_delete(path_gis)
  }

form |>
  sf::st_write(
    path_gis
  )

# burn to repo
if(fs::file_exists(path_repo)){
  fs::file_delete(path_repo)
}
form |>
  # convert so we can see on github?
  sf::st_transform(crs = 4326) |>
  sf::st_write(
    path_repo,
    append=FALSE
  )

