# map_study-area.R
#
# Produces fig/map_study-area.png from cached spatial layers in data/spatial/.
# Run data_map-study-area.R first (requires DB) to populate the cache.
# Layer styles pulled from gq registry extracted from QGIS project.
#
# Usage: Rscript scripts/map_study-area.R

library(sf)
library(tmap)
library(terra)
library(maptiles)
library(dplyr)
library(magick)
library(bcmaps)
library(gq)
sf_use_s2(FALSE)

logo_path <- "fig/logo_newgraph/BLACK/PNG/nge-icon_black.png"
cache     <- "data/spatial"

# --- Short labels for map display --------------------------------------------
# Drops redundant prefixes (bulkley_, meints_), normalises spelling, title-cases.
# Keep historic IDs (Buc7, Bul38, MX1, etc.) as-is.

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

# --- Load gq registry from QGIS project ----------------------------------

reg <- gq_registry_read("data/gis/gq_registry.json")

# --- Load cached layers ---------------------------------------------------

neexdzii <- readRDS(file.path(cache, "neexdzii.rds"))
streams  <- readRDS(file.path(cache, "streams.rds"))
lakes    <- readRDS(file.path(cache, "lakes.rds"))
parks    <- readRDS(file.path(cache, "parks.rds"))
roads    <- readRDS(file.path(cache, "roads.rds"))
railway  <- readRDS(file.path(cache, "railway.rds"))

# --- Site locations -------------------------------------------------------

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

# --- Feature derivations --------------------------------------------------

# Dissolved roads by route
roads_dissolved <- roads |>
  filter(!is.na(route)) |>
  group_by(route, road_type) |>
  summarise(geom = st_union(geom), .groups = "drop")

# Stream label points (5th order+ named)
stream_label_pts <- streams |>
  filter(!is.na(gnis_name) & stream_order >= 5) |>
  group_by(gnis_name) |>
  summarise(geom = st_union(geom), .groups = "drop") |>
  mutate(geometry = st_point_on_surface(geom)) |>
  st_set_geometry("geometry") |>
  st_set_crs(4326)

# Lake labels (>1 km²)
lake_labels <- lakes[!is.na(lakes$name) & lakes$area_km2 > 1, ]

# Towns within/near Neexdzii Kwah
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

# --- Bounding box ---------------------------------------------------------
# Zoom to Neexdzii Kwah with modest padding

# Fit Neexdzii Kwah watershed in frame — padding tuned to 8.5x11 aspect ratio
bbox <- st_bbox(neexdzii)
bbox["ymax"] <- bbox["ymax"] + 0.06
bbox["ymin"] <- bbox["ymin"] - 0.06
bbox["xmin"] <- bbox["xmin"] - 0.04
bbox["xmax"] <- bbox["xmax"] + 0.04

# --- Basemap: hillshade ---------------------------------------------------

bbox_sf <- st_as_sfc(bbox) |> st_set_crs(4326)
relief  <- get_tiles(bbox_sf, provider = "Esri.WorldShadedRelief", zoom = 10, crop = TRUE)
basemap_stars <- stars::st_as_stars(relief)

# --- Site type symbology --------------------------------------------------

site_colors <- c(
  "Effectiveness Monitoring" = "#1f78b4",
  "Potential Site"           = "#ff7f00"
)

site_shapes <- c(
  "Effectiveness Monitoring" = 21,
  "Potential Site"           = 22
)

# --- Map ------------------------------------------------------------------

tmap_mode("plot")

# Pull styles from gq registry
lake_style <- gq_tmap_style(reg$layers$lake)
park_style <- gq_tmap_style(reg$layers$provincial_park)
rail_style <- gq_tmap_style(reg$layers$railway)

m <- tm_shape(basemap_stars, bbox = bbox) +
  tm_rgb() +

  # Watershed boundary
  tm_shape(neexdzii) +
  tm_polygons(fill = "#a8c8e0", fill_alpha = 0.25,
              col = "#2c3e50", lwd = 2.0) +

  # Parks
  tm_shape(parks) +
  tm_polygons(fill = park_style$fill, fill_alpha = park_style$fill_alpha,
              col = park_style$col, lwd = park_style$lwd) +

  # Lakes
  tm_shape(lakes) +
  tm_polygons(fill = lake_style$fill, col = lake_style$col,
              lwd = lake_style$lwd, fill_alpha = lake_style$fill_alpha) +
  tm_shape(lake_labels) +
  tm_text("name", size = 0.55, col = "#1a5276", fontface = "italic") +

  # Streams
  tm_shape(streams |> filter(stream_order >= 5)) +
  tm_lines(col = "#7ba7cc", lwd = 0.5) +
  tm_shape(streams |> filter(stream_order >= 6)) +
  tm_lines(col = "#7ba7cc", lwd = 1.0) +
  tm_shape(stream_label_pts) +
  tm_text("gnis_name", size = 0.60, col = "#1a5276", fontface = "italic") +

  # Railway
  tm_shape(railway) +
  tm_lines(col = rail_style$col, lwd = 1.2) +
  tm_shape(railway) +
  tm_lines(col = "white", lwd = 0.6, lty = "42") +

  # Roads
  tm_shape(roads_dissolved |> filter(road_type == "RH1")) +
  tm_lines(col = "#c0392b", lwd = 2.0) +
  tm_shape(roads_dissolved |> filter(road_type != "RH1")) +
  tm_lines(col = "#e67e22", lwd = 1.2) +

  # Site points
  tm_shape(sites) +
  tm_symbols(
    fill = "type",
    fill.scale = tm_scale_categorical(values = site_colors),
    shape = "type",
    shape.scale = tm_scale_categorical(values = site_shapes),
    size = 0.7,
    col = "grey20",
    lwd = 0.5,
    fill.legend = tm_legend(title = "Site Type"),
    shape.legend = tm_legend(show = FALSE)
  ) +
  tm_text("label", size = 0.65, col = "grey20",
          options = opt_tm_text(
            point.label = TRUE,
            point.label.method = "SANN",
            point.label.gap = 0.2,
            shadow = TRUE
          )) +

  # Towns
  tm_shape(towns) +
  tm_dots(fill = "black", size = 0.30) +
  tm_text("name", size = 0.65, xmod = 0.8, ymod = -0.6,
          col = "grey10", fontface = "bold") +

  # Watershed label
  tm_shape(neexdzii) +
  tm_text("watershed", size = 0.80, fontface = "bold", col = "#1a3c5e") +

  # Scale bar — bottom-left to give keymap its own corner
  tm_scalebar(breaks = c(0, 10, 20),
              position = c("left", "bottom"),
              text.size = 0.6) +

  tm_logo(logo_path, position = c("left", "top"), height = 2.2) +

  # Legend
  tm_add_legend(
    type = "polygons",
    labels = "Park / Protected Area",
    fill = park_style$fill,
    col  = park_style$col,
    lwd  = 1
  ) +
  tm_add_legend(
    type = "lines",
    labels = c("Highway 16", "Secondary highway", "Railway (CN)"),
    col  = c("#c0392b", "#e67e22", "black"),
    lwd  = c(2, 1.2, 1.2)
  ) +

  tm_layout(
    frame = TRUE,
    inner.margins  = c(0.005, 0.005, 0.005, 0.005),
    outer.margins  = c(0.002, 0.002, 0.002, 0.002),
    legend.position = c("right", "top"),
    legend.frame    = TRUE,
    legend.bg.color = "white",
    legend.bg.alpha = 0.85
  )

dir.create("fig", showWarnings = FALSE)
tmap_save(m, "fig/map_study-area.png", width = 8.5, height = 11, dpi = 200)
system("sips -s dpiWidth 200.0 -s dpiHeight 200.0 fig/map_study-area.png")

# --- Keymap inset (BC province + study area bbox) -------------------------

bc_albers   <- bcmaps::bc_bound()
bbox_albers <- st_as_sfc(bbox) |> st_set_crs(4326) |> st_transform(3005)

keymap_tmp <- tempfile(fileext = ".png")
png(keymap_tmp, width = 200, height = 220, bg = "white")
par(mar = c(0, 0, 0, 0))
plot(st_geometry(bc_albers), col = "#e8e8e8", border = "#999999", lwd = 0.8, axes = FALSE)
plot(st_geometry(bbox_albers), col = adjustcolor("#c0392b", alpha.f = 0.45),
     border = "#c0392b", lwd = 2.5, add = TRUE)
box(col = "#999999", lwd = 1)
invisible(dev.off())

main_img   <- image_read("fig/map_study-area.png")
keymap_img <- image_read(keymap_tmp) |>
  image_resize("200x220") |>
  image_border("white", "2x2") |>
  image_border("#aaaaaa", "1x1")

info   <- image_info(main_img)
km_inf <- image_info(keymap_img)

# Consistent margin from frame edge (px) for composited elements
margin_px <- 25
ox <- info$width  - km_inf$width  - margin_px
oy <- info$height - km_inf$height - margin_px

main_img |>
  image_composite(keymap_img, offset = paste0("+", ox, "+", oy)) |>
  image_write("fig/map_study-area.png")

system("sips -s dpiWidth 200.0 -s dpiHeight 200.0 fig/map_study-area.png")
cat("Saved to fig/map_study-area.png\n")
