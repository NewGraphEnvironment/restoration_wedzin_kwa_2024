# CABIN biomonitoring sites for the Bulkley and Morice watershed groups
#
# Source: Environment and Climate Change Canada, Canadian Aquatic Biomonitoring
#   Network (CABIN), Pacific drainage area (MDA 08), 1987-present.
#   https://open.canada.ca/data/en/dataset/13564ca4-e330-40a5-9521-bfb1be767147
#
# The published CSV is UTF-16LE with bilingual slash-separated headers
# ("Site/Site", "Year/Annee") and plain Latitude/Longitude columns, so it is read
# through spacehakr::spk_source_url(), which fetches it, re-encodes to UTF-8 and
# converts it to a point layer in one call.
#
# Note: ogr2ogr refuses -a_srs together with -t_srs, so a_srs assigns 4326 here
# and the reprojection to BC Albers happens in R below.
#
# Output: ~/Projects/gis/restoration_wedzin_kwa/wq/cabin_sites.gpkg (layer cabin_sites),
#   added to the Mergin QGIS project under Project Specific > Water Quality, in the
#   "Floodplain" map theme only.

{
  library(sf)
  library(dplyr)
}

url_cabin <- "https://cabin-rcba.ec.gc.ca/Cabin/opendata/cabin_study_data_mda08_1987-present.csv"

# permanent id for WHSE_BASEMAPPING.FWA_WATERSHED_GROUPS_POLY
id_wsg <- "51f20b1a-ab75-42de-809d-bf415a0f9c62"
wsg_codes <- c("BULK", "MORR")

path_project <- fs::path_expand("~/Projects/gis/restoration_wedzin_kwa")
path_gpkg <- fs::path(path_project, "wq", "cabin_sites.gpkg")
path_qml <- fs::path_ext_set(path_gpkg, "qml")
path_qgs <- fs::path(path_project, "restoration_wedzin_kwa.qgs")

layer_name <- "cabin_sites"

# symbology is lifted from this layer - note the leading space in the name
layer_style_src <- " Form eDNA"
size_scale <- 0.7


# STEP 1 - source the CABIN sites from the URL ---------------------------------

path_raw <- fs::path(tempdir(), "cabin_raw.gpkg")
fs::file_delete(path_raw[fs::file_exists(path_raw)])

spacehakr::spk_source_url(
  path_gpkg = path_raw,
  urls = url_cabin,
  layer = "cabin_all",
  open_options = c(
    "X_POSSIBLE_NAMES=Longitude",
    "Y_POSSIBLE_NAMES=Latitude",
    "KEEP_GEOM_COLUMNS=NO"
  ),
  a_srs = "EPSG:4326",
  encoding = "UTF-16LE"
)

cabin_all <- sf::st_read(path_raw, "cabin_all", quiet = TRUE) |>
  sf::st_transform(3005)

cat("CABIN site visits in MDA 08:", nrow(cabin_all), "\n")


# STEP 2 - watershed group AOI -------------------------------------------------

aoi <- bcdata::bcdc_query_geodata(id_wsg) |>
  bcdata::filter(WATERSHED_GROUP_CODE %in% wsg_codes) |>
  bcdata::collect() |>
  sf::st_transform(3005)

stopifnot(nrow(aoi) == length(wsg_codes))
cat("AOI:", paste(aoi$WATERSHED_GROUP_NAME, collapse = " + "),
    "-", round(sum(as.numeric(sf::st_area(aoi))) / 1e6), "km2\n")


# STEP 3 - clip to the AOI and tidy --------------------------------------------

# bilingual headers arrive as "Site.Site", "Year.Annee" - keep the English half
names(cabin_all) <- sub("\\..*$", "", names(cabin_all))

cabin_sites <- cabin_all |>
  sf::st_filter(sf::st_union(aoi)) |>
  janitor::clean_names() |>
  dplyr::select(
    site, site_name, local_basin_name, study, year, stream_order,
    ecoregion, province
  ) |>
  # the CSV driver types every field as text; year and stream_order are the two
  # anyone will filter or graduate a symbol on
  dplyr::mutate(dplyr::across(c(year, stream_order), as.integer)) |>
  dplyr::arrange(site, year)

cat("site visits within AOI:", nrow(cabin_sites),
    "across", dplyr::n_distinct(cabin_sites$site), "sites\n")

stopifnot(nrow(cabin_sites) > 0)


# STEP 4 - write into the Mergin project ---------------------------------------

cabin_sites |>
  sf::st_write(path_gpkg, layer = "cabin_sites", delete_dsn = TRUE, quiet = TRUE)

cat("wrote", path_gpkg, "\n")


# STEP 5 - style: the eDNA form symbol, scaled down ----------------------------
#
# The symbol is taken from the eDNA form layer rather than written by hand - a
# renderer built by inference parses, validates and reads back fine while QGIS
# refuses to draw it. rfp_qgs_style_export() lifts the real one verbatim.
#
# rfp copies every child of the qml root into the maplayer, so the full export
# would also carry eDNA's fieldConfiguration, aliases, editform and constraints
# onto a layer with entirely different fields. Keep the renderer alone.

style_src <- rfp::rfp_qgs_style_export(
  path = path_qgs,
  layers = layer_style_src,
  path_out = fs::path(tempdir(), "styles")
)

qml <- xml2::read_xml(style_src$path_qml[[1]])
root <- xml2::xml_root(qml)

for (child in xml2::xml_children(root)) {
  if (!identical(xml2::xml_name(child), "renderer-v2")) xml2::xml_remove(child)
}
xml2::xml_set_attr(root, "styleCategories", "Symbology")

# scope to the renderer's own marker layers: a bare //Option[@name='size'] also
# matches sizes in the labeling and diagram blocks
nodes_size <- xml2::xml_find_all(root, "//renderer-v2//layer/Option/Option[@name='size']")
stopifnot(length(nodes_size) > 0)

for (n in nodes_size) {
  before <- as.numeric(xml2::xml_attr(n, "value"))
  after <- round(before * size_scale, 2)
  xml2::xml_set_attr(n, "value", format(after, trim = TRUE))
  cat("  marker size", before, "->", after, "\n")
}

# outline widths are left alone - scaled down with the marker the ring stops
# reading at this size

xml2::write_xml(root, path_qml)
cat("wrote", path_qml, "\n")


# STEP 6 - add to the QGIS project ---------------------------------------------
#
# QGIS holding this project open is a second writer: a Save from the desktop after
# the edit below silently discards it. Refuse rather than race.
open_in_qgis <- suppressWarnings(
  system2("lsof", c("-c", "QGIS"), stdout = TRUE, stderr = FALSE)
)
if (any(grepl(basename(path_project), open_in_qgis, fixed = TRUE))) {
  cli::cli_abort(c(
    "QGIS has {.file {basename(path_project)}} open.",
    "i" = "Close the project in QGIS, then re-run this script.",
    "i" = "Steps 1-5 are complete; {.file {path_gpkg}} is written."
  ))
}

# rm first so a re-run restyles rather than adding a second copy. rfp_qgs_layer_rm
# also prunes the tree entry, every theme listing it and the ordering lists.
qgs_layernames <- function(path) {
  xml2::xml_text(xml2::xml_find_all(xml2::read_xml(path), "//maplayer/layername"))
}
if (layer_name %in% qgs_layernames(path_qgs)) {
  rfp::rfp_qgs_layer_rm(path_qgs, layer = layer_name)

  # rfp writes <qgs>.bak beside the project, which is INSIDE the Mergin working
  # directory - left there it syncs a 14 MB copy of the project to every editor.
  # Keep the safety net, move it to the hold/ tree where backups belong.
  path_bak <- fs::path_ext_set(path_qgs, "qgs.bak")
  if (fs::file_exists(path_bak)) {
    dir_hold <- fs::path_expand(fs::path("~/Projects/gis/hold",
                                         basename(path_project), "qgs_versions"))
    fs::dir_create(dir_hold)
    fs::file_move(path_bak, fs::path(dir_hold, paste0(
      format(Sys.time(), "%Y%m%d_%H%M%S"), "_restoration_wedzin_kwa.qgs.bak")))
  }
}

# themes is named explicitly: a Mergin map theme hides a layer by ABSENCE from the
# preset, not by visible="0", so themes = "all" would show it in every theme on a
# phone regardless of the visibility flag.

rfp::rfp_qgs_vector_add(
  qgs = path_qgs,
  gpkg = path_gpkg,
  table = "cabin_sites",
  name = layer_name,
  qml = path_qml,
  group = "Water Quality",
  themes = "Floodplain"
)

cat("added", layer_name, "to", path_qgs, "\n")
