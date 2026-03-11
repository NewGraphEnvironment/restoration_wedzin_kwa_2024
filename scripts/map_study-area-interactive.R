# map_study-area-interactive.R
#
# Interactive study area map using mapgl + gq registry styles.
# Layers from cached RDS files (run data_map-study-area.R first).
# Produces fig/map_study-area-interactive.html for bookdown embedding.
#
# Usage: Rscript scripts/map_study-area-interactive.R

library(sf)
library(dplyr)
library(mapgl)
library(gq)
library(htmlwidgets)

sf_use_s2(FALSE)

cache <- "data/spatial"
reg   <- gq_registry_read("data/gis/gq_registry.json")

# --- Load cached layers -------------------------------------------------------

neexdzii <- readRDS(file.path(cache, "neexdzii.rds"))
streams  <- readRDS(file.path(cache, "streams.rds"))
lakes    <- readRDS(file.path(cache, "lakes.rds"))
parks    <- readRDS(file.path(cache, "parks.rds"))
roads    <- readRDS(file.path(cache, "roads.rds"))
railway  <- readRDS(file.path(cache, "railway.rds"))

# --- Site locations -----------------------------------------------------------

label_short <- function(x) {
  x |>
    gsub("bulkley_meints_", "", x = _) |>
    gsub("bulkley_", "", x = _) |>
    gsub("-2021$", "", x = _) |>
    gsub("_0(\\d)", " \\1", x = _) |>
    gsub("_", " ", x = _) |>
    tools::toTitleCase() |>
    gsub("Mickilligan Road", "McKilligan", x = _) |>
    gsub("Mckilligan Rd", "McKilligan", x = _) |>
    gsub("Foxy Maxan Confluence", "Foxy-Maxan", x = _)
}

path_gis <- "/Users/airvine/Projects/gis/restoration_wedzin_kwa/data_field/sites_reviewed_2024_202506.geojson"

sites <- st_read(path_gis, quiet = TRUE) |>
  mutate(
    type = case_when(
      works_completed == "yes" &
        !grepl("mud|kenneth", site_id, ignore.case = TRUE) ~
        "Effectiveness Monitoring",
      works_completed == "yes" &
        grepl("mud|kenneth", site_id, ignore.case = TRUE) ~
        "Fraser Site",
      TRUE ~ "Potential Site"
    ),
    type = factor(type, levels = c("Effectiveness Monitoring", "Potential Site", "Fraser Site"))
  ) |>
  filter(type != "Fraser Site") |>
  mutate(type = droplevels(type),
         label = label_short(site_id)) |>
  distinct(site_id, .keep_all = TRUE)

# --- Falls --------------------------------------------------------------------

# Hardcoded from bcfishpass.falls_vw query (falls_id e59c47b5-...)
buck_lon <- -126.50428
buck_lat <- 54.18855

falls <- st_sf(
  name = c("Bulkley Falls", "Buck Falls"),
  description = c(
    "12-15m bedrock cascade, partial barrier dependent on flow",
    "Series of 4 drops over ~200m, up to ~4m individual drops"
  ),
  geometry = st_sfc(
    st_point(c(-126.2492, 54.46086)),
    st_point(c(buck_lon, buck_lat)),
    crs = 4326
  )
)

# --- Derive road layers -------------------------------------------------------

roads_hwy <- roads |>
  filter(!is.na(route) & road_type == "RH1") |>
  group_by(route) |>
  summarise(geom = st_union(geom), .groups = "drop")

roads_secondary <- roads |>
  filter(!is.na(route) & road_type != "RH1") |>
  group_by(route, road_type) |>
  summarise(geom = st_union(geom), .groups = "drop")

# --- Stream filtering ---------------------------------------------------------

streams_major <- streams |> filter(stream_order >= 5)
streams_large <- streams |> filter(stream_order >= 6)

# --- Lake labels (>1 km²) ----------------------------------------------------

lake_labels <- lakes |> filter(!is.na(name) & area_km2 > 1)

# --- Towns --------------------------------------------------------------------

towns <- st_sf(
  name = c("Houston", "Smithers", "Burns Lake", "Topley"),
  geometry = st_sfc(
    st_point(c(-126.648, 54.398)),
    st_point(c(-127.176, 54.779)),
    st_point(c(-125.764, 54.230)),
    st_point(c(-126.246, 54.566)),
    crs = 4326
  )
)

# --- gq styles ----------------------------------------------------------------

lake_style <- gq_mapgl_style(reg$layers$lake)
park_style <- gq_mapgl_style(reg$layers$provincial_park)
rail_style <- gq_mapgl_style(reg$layers$railway)

# --- Bounding box -------------------------------------------------------------

bbox <- st_bbox(neexdzii)

# --- Esri tile URLs (standard NGE basemaps) -----------------------------------
# TODO: These basemap defaults should eventually live in gq package
# (see leaflet pattern: addProviderTiles("Esri.WorldImagery", group = "Ortho"))

esri_topo <- "https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}"
esri_imagery <- "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
esri_hillshade <- "https://services.arcgisonline.com/arcgis/rest/services/Elevation/World_Hillshade/MapServer/tile/{z}/{y}/{x}"
opentopomap <- "https://tile.opentopomap.org/{z}/{x}/{y}.png"

# --- Build mapgl map ----------------------------------------------------------

m <- maplibre(
  bounds = bbox,
  style = carto_style("positron")
) |>
  # Esri basemap tiles (under all data layers, hidden by default)
  add_raster_source(id = "esri-topo", tiles = esri_topo, tileSize = 256, maxzoom = 18) |>
  add_raster_layer(id = "basemap-topo", source = "esri-topo", visibility = "none") |>
  add_raster_source(id = "esri-imagery", tiles = esri_imagery, tileSize = 256, maxzoom = 18) |>
  add_raster_layer(id = "basemap-imagery", source = "esri-imagery", visibility = "none") |>
  add_raster_source(id = "esri-hillshade", tiles = esri_hillshade, tileSize = 256, maxzoom = 18) |>
  add_raster_layer(id = "basemap-hillshade", source = "esri-hillshade", visibility = "none",
                   raster_opacity = 0.7) |>
  add_raster_source(id = "opentopomap", tiles = opentopomap, tileSize = 256, maxzoom = 17) |>
  add_raster_layer(id = "basemap-opentopomap", source = "opentopomap", visibility = "none") |>
  # Watershed boundary
  add_fill_layer(
    id = "watershed",
    source = neexdzii,
    fill_color = "#a8c8e0",
    fill_opacity = 0.2
  ) |>
  add_line_layer(
    id = "watershed-outline",
    source = neexdzii,
    line_color = "#2c3e50",
    line_width = 2.5
  ) |>
  # Parks
  add_fill_layer(
    id = "parks",
    source = parks,
    fill_color = park_style$paint[["fill-color"]],
    fill_opacity = park_style$paint[["fill-opacity"]]
  ) |>
  # Lakes
  add_fill_layer(
    id = "lakes",
    source = lakes,
    fill_color = lake_style$paint[["fill-color"]],
    fill_opacity = lake_style$paint[["fill-opacity"]]
  ) |>
  # Streams (major)
  add_line_layer(
    id = "streams-major",
    source = streams_major,
    line_color = "#7ba7cc",
    line_width = 1.0
  ) |>
  # Streams (large — thicker)
  add_line_layer(
    id = "streams-large",
    source = streams_large,
    line_color = "#5b8fba",
    line_width = 2.0
  ) |>
  # Railway
  add_line_layer(
    id = "railway",
    source = railway,
    line_color = rail_style$paint[["line-color"]],
    line_width = 1.5
  ) |>
  # Highway 16
  add_line_layer(
    id = "highway",
    source = roads_hwy,
    line_color = "#c0392b",
    line_width = 3
  ) |>
  # Secondary roads
  add_line_layer(
    id = "roads-secondary",
    source = roads_secondary,
    line_color = "#e67e22",
    line_width = 1.5
  ) |>
  # Falls markers
  add_markers(
    data = falls |> mutate(popup_html = paste0("<b>", name, "</b><br>", description)),
    popup = "popup_html"
  ) |>
  # Sites — Effectiveness Monitoring
  add_circle_layer(
    id = "sites-monitoring",
    source = sites |>
      filter(type == "Effectiveness Monitoring") |>
      mutate(popup_html = paste0("<b>", label, "</b><br>Effectiveness Monitoring")),
    circle_color = "#1f78b4",
    circle_radius = 7,
    circle_stroke_color = "white",
    circle_stroke_width = 1.5,
    popup = "popup_html"
  ) |>
  # Sites — Potential Site
  add_circle_layer(
    id = "sites-potential",
    source = sites |>
      filter(type == "Potential Site") |>
      mutate(popup_html = paste0("<b>", label, "</b><br>Potential Site")),
    circle_color = "#ff7f00",
    circle_radius = 7,
    circle_stroke_color = "white",
    circle_stroke_width = 1.5,
    popup = "popup_html"
  ) |>
  # Navigation controls
  add_navigation_control(position = "top-right") |>
  add_scale_control(position = "bottom-left") |>
  # Layer toggle control — basemaps + site layers
  add_layers_control(
    position = "top-left",
    collapsible = TRUE,
    layers = list(
      "Esri Topo" = "basemap-topo",
      "Esri Imagery" = "basemap-imagery",
      "Hillshade" = "basemap-hillshade",
      "OpenTopoMap" = "basemap-opentopomap",
      "Monitoring Sites" = "sites-monitoring",
      "Potential Sites" = "sites-potential"
    )
  )

# --- Save ---------------------------------------------------------------------

dir.create("fig", showWarnings = FALSE)
saveWidget(m, file = normalizePath("fig/map_study-area-interactive.html", mustWork = FALSE),
           selfcontained = TRUE)
cat("Saved to fig/map_study-area-interactive.html\n")
