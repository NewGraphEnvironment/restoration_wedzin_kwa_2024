##funciton ot find a string in your directory from https://stackoverflow.com/questions/45502010/is-there-an-r-version-of-rstudios-find-in-files

fif <- function(what, where=".", in_files="\\.[Rr]$", recursive = TRUE,
                ignore.case = TRUE) {
  fils <- list.files(path = where, pattern = in_files, recursive = recursive)
  found <- FALSE
  file_cmd <- Sys.which("file")
  for (fil in fils) {

    if (nchar(file_cmd) > 0) {
      ftype <- system2(file_cmd, fil, TRUE)
      if (!grepl("text", ftype)[1]) next
    }
    contents <- readLines(fil)
    res <- grepl(what, contents, ignore.case = ignore.case)
    res <- which(res)
    if (length(res) > 0) {
      found <-  TRUE
      cat(sprintf("%s\n", fil), sep="")
      cat(sprintf(" % 4s: %s\n", res, contents[res]), sep="")
    }
  }
  if (!found) message("(No results found)")
}

# Function to clip a point layer to a polygon layer based on a join column and factor
# @param schema_table_point String (quoted) name of point layer schema.table
# @param schema_table_polygon String (quoted) name of polygon layer schema.table
# @param join_column String (quoted) name of column to join tables on from polygon. See column names of any table with \link{fpr_dbq_lscols}
# @param join_on String (quoted) or vector of specific terms to join on.
#
lfpr_dbq_clip <- function(
    schema_table_point,
    schema_table_polygon,
    join_column,
    join_on) {

  join_on_string <- paste0("'", join_on, "'", collapse = ", ")

  glue::glue("SELECT point.*, poly.{join_column}
   FROM {schema_table_point} point
   INNER JOIN {schema_table_polygon} poly
   ON ST_Intersects(poly.geom, point.geom)
   WHERE poly.{join_column} IN ({join_on_string});")

}

# Creates hydrographs
#' @param station String (quoted) station number
#' @param pane_hydat Boolean TRUE if you want a pane layout of all hydrographs
#' @param single_hydat Boolean TRUE if you want a single hydrograph with mean flows
#' @param start_year Specific start year, if not specified, will use the first year of the data
#' @param end_year Specific end year, if not specified, will use the first year of the data
#' @param fig/hydrology_stats_ hydrology stats figure saved to the fig folder
#' @param fig/hydrograph_ hydrograph figure saved to the fig folder

lfpr_create_hydrograph <- function(
    station = NULL,
    pane_hydat = TRUE,
    single_hydat = TRUE,
    start_year = NULL,
    end_year = NULL){

  if(is.null(station)){
    poisutils::ps_error('Please provide a station number, for example "08EE004"')
  }

  chk::chk_string(station)
  chk::chk_flag(pane_hydat)
  chk::chk_flag(single_hydat)

  flow_raw <- tidyhydat::hy_daily_flows(station)

  if(is.null(start_year)){
    start_year <- flow_raw$Date %>% min() %>% lubridate::year()
  }

  if(is.null(end_year)){
    end_year <- flow_raw$Date %>% max() %>% lubridate::year()
  }

  chk::chk_number(start_year)
  chk::chk_number(end_year)

  tidyhat_info <- tidyhydat::search_stn_number(station)



  ##### Hydrograph Stats #####

  ##build caption for the stats figure
  caption_info <- dplyr::mutate(tidyhat_info, title_stats = paste0(stringr::str_to_title(STATION_NAME),
                                                                   " (Station #",STATION_NUMBER," - Lat " ,round(LATITUDE,6),
                                                                   " Lon ",round(LONGITUDE,6), "). Available daily discharge data from ", start_year,
                                                                   # FIRST_YEAR, ##removed the default here
                                                                   " to ",end_year, "."))

  hydrograph1_stats_caption <- caption_info$title_stats



  if (pane_hydat == TRUE){
    #Create pane of hydrographs with "Mean", "Minimum", "Maximum", and "Standard Deviation" flows
    hydrograph_stats_print <- fasstr::plot_data_screening(station_number = station, start_year = start_year,
                                                          include_stats = c("Mean", "Minimum", "Maximum", "Standard Deviation"),
                                                          plot_availability = FALSE)[["Data_Screening"]] + ggdark::dark_theme_bw() ##first version is not dark
    hydrograph_stats_print

    #Save hydrograph pane
    ggplot2::ggsave(plot = hydrograph_stats_print, file=paste0("fig/hydrology_stats_", station, ".png"),
                    h=3.4, w=5.11, units="in", dpi=300)

   cli::cli_alert(hydrograph1_stats_caption)
  }



  ##### Single Hydrograph  #####

  ##build caption for the single figure
  caption_info2 <- dplyr::mutate(tidyhat_info, title_stats2 = paste0(stringr::str_to_title(STATION_NAME),
                                                                     " (Station #",STATION_NUMBER," - Lat " ,round(LATITUDE,6),
                                                                     " Lon ",round(LONGITUDE,6), "). Available mean daily discharge data from ", start_year,
                                                                     # FIRST_YEAR, ##removed the default here
                                                                     " to ",end_year, "."))

  hydrograph1_stats_caption2 <- caption_info2$title_stats2

  if (single_hydat == TRUE){
    # Create single hydrograph with mean flows from date range
    flow <- flow_raw %>%
      dplyr::mutate(day_of_year = yday(Date)) %>%
      dplyr::group_by(day_of_year) %>%
      dplyr::summarise(daily_ave = mean(Value, na.rm=TRUE),
                       daily_sd = sd(Value, na.rm = TRUE),
                       max = max(Value, na.rm = TRUE),
                       min = min(Value, na.rm = TRUE)) %>%
      dplyr::mutate(Date = as.Date(day_of_year))

    plot <- ggplot2::ggplot()+
      ggplot2::geom_ribbon(data = flow, aes(x = Date, ymax = max,
                                            ymin = min),
                           alpha = 0.3, linetype = 1)+
      ggplot2::scale_x_date(date_labels = "%b", date_breaks = "2 month") +
      ggplot2::labs(x = NULL, y = expression(paste("Mean Daily Discharge (", m^3, "/s)", sep="")))+
      ggdark::dark_theme_bw() +
      ggplot2::geom_line(data = flow, aes(x = Date, y = daily_ave),
                         linetype = 1, linewidth = 0.7) +
      ggplot2::scale_colour_manual(values = c("grey10", "red"))
    plot

    ggplot2::ggsave(plot = plot, file=paste0("fig/hydrograph_", station, ".png"),
                    h=3.4, w=5.11, units="in", dpi=300)

    cli::cli_alert(hydrograph1_stats_caption2)
  }
}



# make a function for downloading files straight from skt ckan
fetch_package <- function(package_nm = NULL,
                          ckan_info = data_deets,
                          store = "disk",
                          path_stub = "data/skt/",
                          csv_output = TRUE) {
  info <- ckan_info %>%
    dplyr::filter(package_name == package_nm)

  urls <- info %>%
    pull(url) %>%
    # to avoid dl errors we need to remove the NAs as well as those files that end without a file extension at the end (ex. .com/ and *123)
    na.omit() %>%
    .[str_detect(., ".*\\.[a-zA-Z0-9]+$")]

  # create the directory if it doesn't exist
  dir.create(paste0(path_stub, package_nm))

  walk(.x = urls,
       .f = ~ckan_fetch(.x, store = store, path = paste0(path_stub, package_nm, "/", basename(.x))))

  # if csv_output = TRUE burn out a little csv file of the information about everything that is downloaded
  if (csv_output) {
    info %>%
      arrange(basename(url)) %>%
      write_csv(paste0(path_stub, package_nm, "/001_pkg_info_", package_nm, ".csv"))
  }
}

# make column names for excel cols that span multiple rows (ie. 6 and 7)
wkb_col_names <-  function(wkb,
                           slice_from = 5,
                           slice_to = 6,
                           max_col = NULL
){
  a <- wkb %>%
    slice(slice_from:slice_to) %>%
    # rownames_to_column() %>%
    t() %>%
    tibble::as_tibble() %>%
    tidyr::fill(V1, .direction = 'down') %>%
    dplyr::mutate(across(everything(), .fns = ~replace_na(.,'')))
  if(slice_from != slice_to){
    a <- a %>% dplyr::mutate(col_names = paste0(V1, V2))
  }else a <- a %>% dplyr::mutate(col_names = V1)
  # replace_na(list(V2 = "unknown")) %>%
  # (col_names = paste0(V1, V2)) %>%
  b <- a %>% pull(col_names) %>%
    janitor::make_clean_names()
  if(!is.null(max_col)){length(b) <- max_col}
  return(b)
}

#' Check for NULL values in a specific column of a SQL table
#'
#' @param schema_table A string specifying the schema and table in the format "schema.table".
#' @param col_nulls A string specifying the column to check for NULL values.
#'
#' @return A string containing the SQL query.
#' @importFrom glue glue
#' @export
ldbq_chk_null <- function(schema_table, col_nulls) {
  query <- glue::glue(
    "SELECT COUNT(*)
    FROM {schema_table}
    WHERE {col_nulls} IS NULL;"
  )

  return(query)
}


ldfo_sad_plot_line <- function(dat, region, col_y, col_facet, col_group, col_group_exclude = NULL, value_group_exclude = NULL, theme = ggdark::dark_theme_bw()) {
  dat <- dat %>%
    dplyr::filter(waterbody == region) %>%
    dplyr::filter(!is.na(!!sym(col_y)))

  if (!is.null(col_group_exclude)) {
    dat <- dat |>
      dplyr::filter(!!sym(col_group_exclude) != value_group_exclude)
  }

  dat %>%
    arrange(!!sym(col_facet), !!sym(col_group)) %>%
    ggplot(aes(x = !!sym(col_group), y = !!sym(col_y), group = !!sym(col_facet))) +
    geom_line() +
    geom_point() +
    facet_wrap(as.formula(paste0("~", col_facet)), scales = "free") +
    labs(x = "Year", y = col_y) +
    theme
}


# write the contents of the NEWS.md file to a RMD file that will be included as an appendix
news_to_appendix <- function(
    md_name = "NEWS.md",
    rmd_name = "2090-report-change-log.Rmd",
    appendix_title = "# Report Change Log") {

  # Read and modify the contents of the markdown file
  news_md <- readLines(md_name)
  news_md <- stringr::str_replace(news_md, "^#", "###") |>
    stringr::str_replace_all("(^(### .*?$))", "\\1 {-}")

  # Write the title, a blank line, and the modified contents to the Rmd file
  writeLines(
    c(paste0(appendix_title, " {-}"), "", news_md),
    rmd_name
  )
}
