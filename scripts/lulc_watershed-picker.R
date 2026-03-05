#!/usr/bin/env Rscript
#
# lulc_watershed-picker.R
#
# Interactive Shiny app for defining sub-basin break points on the Neexdzii Kwa
# stream network. Click on streams to place break points, app snaps to FWA via
# fwa_indexpoint(), delineates upstream watersheds, and computes inter-reach
# polygons (downstream minus upstream = reach catchment).
#
# Exports break points and sub-basin polygons for use in lulc_subbasin-compare.R.
#
# Requires:
#   - SSH tunnel on port 63333
#   - data/lulc/streams_neexdzii_co.gpkg (from lulc_network-extract.R)
#   - data/lulc/floodplain_neexdzii_co.gpkg (from lulc_network-extract.R)
#   - R packages: shiny, leaflet, sf, DBI, RPostgres
#
# Relates to #67

library(shiny)
library(leaflet)
library(sf)
library(DBI)
library(RPostgres)

sf::sf_use_s2(FALSE)

# --- Load data ---
streams <- sf::st_read(
  here::here("data", "lulc", "streams_neexdzii_co.gpkg"),
  quiet = TRUE
) |> sf::st_transform(4326)

floodplain <- sf::st_read(
  here::here("data", "lulc", "floodplain_neexdzii_co.gpkg"),
  quiet = TRUE
) |> sf::st_transform(4326)

# NCFDC 1998 reach breaks (pre-existing)
ncfdc_breaks_path <- "/Users/airvine/Projects/gis/restoration_wedzin_kwa/ncfdc_1998/ncfdc_1998_reach_breaks.geojson"
ncfdc_breaks <- if (file.exists(ncfdc_breaks_path)) {
  sf::st_read(ncfdc_breaks_path, quiet = TRUE) |> sf::st_transform(4326)
} else {
  NULL
}

# Key waterfalls (natural barriers)
falls <- sf::st_sf(
  name = c("Bulkley Falls", "Buck Falls"),
  geometry = sf::st_sfc(
    sf::st_point(c(-126.2492, 54.46086)),
    sf::st_point(c(-126.504281, 54.188549)),
    crs = 4326
  )
)

# --- DB helpers ---
get_conn <- function() {
  DBI::dbConnect(
    RPostgres::Postgres(),
    host = "localhost", port = 63333,
    dbname = "bcfishpass", user = "newgraph"
  )
}

fwa_snap <- function(lon, lat, conn) {
  sql <- sprintf(
    "SELECT blue_line_key, downstream_route_measure, gnis_name,
            distance_to_stream, ST_AsText(geom) as geom_wkt
     FROM whse_basemapping.fwa_indexpoint(ST_Transform(ST_SetSRID(ST_MakePoint(%.6f, %.6f), 4326), 3005))",
    lon, lat
  )
  DBI::dbGetQuery(conn, sql)
}

fwa_watershed <- function(blk, drm, conn) {
  sql <- sprintf(
    "SELECT ST_Transform(geom, 4326) as geom
     FROM whse_basemapping.fwa_watershedatmeasure(%d, %f)",
    as.integer(blk), drm
  )
  result <- sf::st_read(conn, query = sql, quiet = TRUE)
  if (nrow(result) > 0) {
    result <- sf::st_union(result)
    sf::st_sf(geometry = result, crs = 4326)
  } else {
    NULL
  }
}

# --- UI ---
ui <- fluidPage(
  titlePanel("Neexdzii Kwa Sub-Basin Picker"),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Break Points"),
      helpText(
        "Click on a stream to place a break point.",
        "Each break generates an upstream watershed.",
        "Inter-reach polygons are computed automatically",
        "(downstream watershed minus upstream watershed)."
      ),
      hr(),
      fileInput("load_csv", "Load Break Points CSV (lon, lat)",
                accept = ".csv"),
      hr(),
      actionButton("clear_last", "Remove Last Point", class = "btn-warning"),
      actionButton("clear_all", "Clear All", class = "btn-danger"),
      hr(),
      actionButton("compute", "Compute Sub-Basins", class = "btn-primary"),
      hr(),
      actionButton("export", "Export", class = "btn-success"),
      helpText("Saves break_points.csv and subbasins.gpkg to data/lulc/"),
      hr(),
      h4("Break Points Table"),
      tableOutput("points_table"),
      hr(),
      h4("Sub-Basins"),
      tableOutput("subbasins_table")
    ),
    mainPanel(
      width = 9,
      leafletOutput("map", height = "85vh")
    )
  )
)

# --- Server ---
server <- function(input, output, session) {

  # Reactive values
  rv <- reactiveValues(
    breaks = data.frame(
      id = integer(), lon = numeric(), lat = numeric(),
      blk = integer(), drm = numeric(), gnis_name = character(),
      dist_m = numeric(),
      stringsAsFactors = FALSE
    ),
    watersheds = list(),    # named list of sf polygons keyed by break id
    subbasins = NULL,       # sf with inter-reach polygons
    conn = NULL
  )

  # DB connection on start
  conn <- tryCatch(get_conn(), error = function(e) NULL)
  rv$conn <- conn

  onStop(function() {
    if (!is.null(conn)) DBI::dbDisconnect(conn)
  })

  # Base map
  output$map <- renderLeaflet({
    m <- leaflet() |>
      addProviderTiles("OpenTopoMap", group = "Topo") |>
      addProviderTiles("Esri.WorldImagery", group = "Satellite") |>
      addProviderTiles("OpenStreetMap", group = "OSM") |>
      addPolygons(
        data = floodplain, color = "#00ff88", weight = 1,
        fillOpacity = 0.2, group = "Floodplain"
      ) |>
      addPolylines(
        data = streams, color = "#3388ff", weight = 2,
        popup = ~paste0(
          "<b>", gnis_name, "</b><br>",
          "Order: ", stream_order, "<br>",
          "BLK: ", blue_line_key
        ),
        group = "Streams"
      )

    # Waterfalls
    falls_coords <- sf::st_coordinates(falls)
    m <- m |> addMarkers(
      lng = falls_coords[, 1], lat = falls_coords[, 2],
      label = falls$name,
      popup = falls$name,
      group = "Falls"
    )

    if (!is.null(ncfdc_breaks)) {
      coords <- sf::st_coordinates(ncfdc_breaks)
      m <- m |> addCircleMarkers(
        lng = coords[, 1], lat = coords[, 2],
        radius = 5, color = "orange", fillColor = "orange",
        fillOpacity = 0.6, weight = 1,
        label = paste0(ncfdc_breaks$reach_name_corrected,
                       " (", ncfdc_breaks$stream_name, ")"),
        group = "NCFDC 1998"
      )
    }

    m |> addLayersControl(
      baseGroups = c("Topo", "Satellite", "OSM"),
      overlayGroups = c("Floodplain", "Streams", "Falls", "NCFDC 1998"),
      position = "topright"
    )
  })

  # Load break points from CSV — snap each to FWA
  observeEvent(input$load_csv, {
    if (is.null(rv$conn)) {
      showNotification("No DB connection", type = "error")
      return()
    }

    pts <- tryCatch(
      read.csv(input$load_csv$datapath, stringsAsFactors = FALSE),
      error = function(e) {
        showNotification(paste("CSV read failed:", e$message), type = "error")
        NULL
      }
    )
    if (is.null(pts)) return()

    if (!all(c("lon", "lat") %in% names(pts))) {
      showNotification("CSV must have 'lon' and 'lat' columns", type = "error")
      return()
    }

    n <- nrow(pts)
    loaded <- 0L
    withProgress(message = "Snapping points to streams...", value = 0, {
      for (i in seq_len(n)) {
        incProgress(1 / n, detail = paste(i, "of", n))

        result <- tryCatch(
          fwa_snap(pts$lon[i], pts$lat[i], rv$conn),
          error = function(e) {
            message("Snap error for point ", i, ": ", e$message)
            NULL
          }
        )
        if (is.null(result) || nrow(result) == 0) next

        new_id <- nrow(rv$breaks) + 1L
        new_row <- data.frame(
          id = new_id,
          lon = pts$lon[i],
          lat = pts$lat[i],
          blk = as.integer(result$blue_line_key),
          drm = result$downstream_route_measure,
          gnis_name = result$gnis_name %||% "",
          dist_m = round(result$distance_to_stream, 1),
          stringsAsFactors = FALSE
        )
        rv$breaks <- rbind(rv$breaks, new_row)
        loaded <- loaded + 1L

        leafletProxy("map") |>
          addCircleMarkers(
            lng = pts$lon[i], lat = pts$lat[i],
            radius = 8, color = "red", fillColor = "yellow",
            fillOpacity = 0.9, weight = 2,
            label = paste0("#", new_id, ": ", result$gnis_name,
                           " (", round(result$distance_to_stream, 0), "m)"),
            group = "Break Points",
            layerId = paste0("break_", new_id)
          )
      }
    })

    showNotification(
      paste(loaded, "of", n, "points loaded and snapped"),
      type = "message"
    )
  })

  # Handle map clicks — snap to stream
  observeEvent(input$map_click, {
    click <- input$map_click
    if (is.null(rv$conn)) {
      showNotification("No DB connection", type = "error")
      return()
    }

    withProgress(message = "Snapping to stream...", {
      result <- tryCatch(
        fwa_snap(click$lng, click$lat, rv$conn),
        error = function(e) {
          showNotification(paste("Snap failed:", e$message), type = "error")
          NULL
        }
      )
    })

    if (is.null(result) || nrow(result) == 0) {
      showNotification("No stream found nearby", type = "warning")
      return()
    }

    new_id <- nrow(rv$breaks) + 1L
    new_row <- data.frame(
      id = new_id,
      lon = click$lng,
      lat = click$lat,
      blk = as.integer(result$blue_line_key),
      drm = result$downstream_route_measure,
      gnis_name = result$gnis_name %||% "",
      dist_m = round(result$distance_to_stream, 1),
      stringsAsFactors = FALSE
    )
    rv$breaks <- rbind(rv$breaks, new_row)

    # Add marker to map
    leafletProxy("map") |>
      addCircleMarkers(
        lng = click$lng, lat = click$lat,
        radius = 8, color = "red", fillColor = "yellow",
        fillOpacity = 0.9, weight = 2,
        label = paste0("#", new_id, ": ", result$gnis_name,
                       " (", round(result$distance_to_stream, 0), "m)"),
        group = "Break Points",
        layerId = paste0("break_", new_id)
      )

    showNotification(
      paste0("Break #", new_id, ": ", result$gnis_name,
             " (blk=", result$blue_line_key,
             ", drm=", round(result$downstream_route_measure, 1),
             ", snap=", round(result$distance_to_stream, 0), "m)"),
      type = "message"
    )
  })

  # Remove last point
  observeEvent(input$clear_last, {
    if (nrow(rv$breaks) == 0) return()
    last_id <- max(rv$breaks$id)
    rv$breaks <- rv$breaks[rv$breaks$id != last_id, ]
    rv$watersheds[[as.character(last_id)]] <- NULL
    leafletProxy("map") |>
      removeMarker(paste0("break_", last_id)) |>
      clearGroup("Watersheds") |>
      clearGroup("Sub-Basins")
    rv$subbasins <- NULL
  })

  # Clear all
  observeEvent(input$clear_all, {
    rv$breaks <- rv$breaks[0, ]
    rv$watersheds <- list()
    rv$subbasins <- NULL
    leafletProxy("map") |>
      clearGroup("Break Points") |>
      clearGroup("Watersheds") |>
      clearGroup("Sub-Basins")
  })

  # Compute sub-basins
  observeEvent(input$compute, {
    if (nrow(rv$breaks) == 0) {
      showNotification("No break points placed", type = "warning")
      return()
    }
    if (is.null(rv$conn)) {
      showNotification("No DB connection", type = "error")
      return()
    }

    # Clear previous
    leafletProxy("map") |>
      clearGroup("Watersheds") |>
      clearGroup("Sub-Basins")

    breaks <- rv$breaks

    # Delineate watershed for each break point
    withProgress(message = "Delineating watersheds...", value = 0, {
      for (i in seq_len(nrow(breaks))) {
        incProgress(1 / nrow(breaks), detail = paste("Point", i, "of", nrow(breaks)))
        bid <- as.character(breaks$id[i])
        if (is.null(rv$watersheds[[bid]])) {
          ws <- tryCatch(
            fwa_watershed(breaks$blk[i], breaks$drm[i], rv$conn),
            error = function(e) {
              showNotification(
                paste0("Watershed failed for #", breaks$id[i], ": ", e$message),
                type = "error"
              )
              NULL
            }
          )
          rv$watersheds[[bid]] <- ws
        }
      }
    })

    # Build sub-basins by subtraction
    # Sort breaks by upstream area (largest first = most downstream)
    # For each break: its sub-basin = its watershed minus all upstream watersheds
    # that are contained within it
    withProgress(message = "Computing inter-reach polygons...", {
      ws_list <- rv$watersheds
      valid <- breaks$id[sapply(as.character(breaks$id), function(x) !is.null(ws_list[[x]]))]
      breaks_valid <- breaks[breaks$id %in% valid, ]

      if (nrow(breaks_valid) == 0) {
        showNotification("No valid watersheds", type = "error")
        return()
      }

      # Compute area for sorting (largest = most downstream)
      areas <- sapply(as.character(breaks_valid$id), function(x) {
        as.numeric(sf::st_area(sf::st_transform(ws_list[[x]], 3005)))
      })
      breaks_valid <- breaks_valid[order(-areas), ]

      subbasin_list <- list()
      for (i in seq_len(nrow(breaks_valid))) {
        bid <- as.character(breaks_valid$id[i])
        poly <- ws_list[[bid]]

        # Subtract all smaller (upstream) watersheds that intersect
        if (i < nrow(breaks_valid)) {
          for (j in (i + 1):nrow(breaks_valid)) {
            ubid <- as.character(breaks_valid$id[j])
            upstream_poly <- ws_list[[ubid]]
            if (!is.null(upstream_poly) &&
                sf::st_intersects(poly, upstream_poly, sparse = FALSE)[1, 1]) {
              poly <- tryCatch(
                sf::st_difference(poly, upstream_poly),
                error = function(e) poly
              )
            }
          }
        }

        subbasin_list[[bid]] <- sf::st_sf(
          break_id = breaks_valid$id[i],
          blk = breaks_valid$blk[i],
          drm = breaks_valid$drm[i],
          gnis_name = breaks_valid$gnis_name[i],
          geometry = sf::st_geometry(poly)
        )
      }

      rv$subbasins <- do.call(rbind, subbasin_list)
      sf::st_crs(rv$subbasins) <- 4326
    })

    # Draw on map
    if (!is.null(rv$subbasins) && nrow(rv$subbasins) > 0) {
      pal <- colorFactor("Set2", rv$subbasins$break_id)
      leafletProxy("map") |>
        addPolygons(
          data = rv$subbasins,
          color = ~pal(break_id), weight = 2,
          fillColor = ~pal(break_id), fillOpacity = 0.3,
          popup = ~paste0(
            "<b>Sub-basin #", break_id, "</b><br>",
            gnis_name, "<br>",
            "BLK: ", blk, "<br>",
            "DRM: ", round(drm, 1)
          ),
          group = "Sub-Basins"
        )
      showNotification(
        paste(nrow(rv$subbasins), "sub-basins computed"),
        type = "message"
      )
    }
  })

  # Export
  observeEvent(input$export, {
    if (nrow(rv$breaks) == 0) {
      showNotification("No break points to export", type = "warning")
      return()
    }

    out_dir <- here::here("data", "lulc")

    # Save break points
    bp_path <- file.path(out_dir, "break_points.csv")
    write.csv(rv$breaks, bp_path, row.names = FALSE)
    showNotification(paste("Saved:", bp_path), type = "message")

    # Save sub-basins if computed
    if (!is.null(rv$subbasins) && nrow(rv$subbasins) > 0) {
      sb_path <- file.path(out_dir, "subbasins.gpkg")
      sf::st_write(
        sf::st_transform(rv$subbasins, 3005),
        sb_path, delete_dsn = TRUE, quiet = TRUE
      )
      showNotification(paste("Saved:", sb_path), type = "message")
    }
  })

  # Tables
  output$points_table <- renderTable({
    if (nrow(rv$breaks) == 0) return(NULL)
    rv$breaks[, c("id", "gnis_name", "blk", "drm", "dist_m")]
  }, digits = 1)

  output$subbasins_table <- renderTable({
    if (is.null(rv$subbasins)) return(NULL)
    sb <- rv$subbasins
    sb$area_km2 <- round(
      as.numeric(sf::st_area(sf::st_transform(sb, 3005))) / 1e6, 1
    )
    sf::st_drop_geometry(sb)[, c("break_id", "gnis_name", "area_km2")]
  })
}

shiny::shinyApp(ui, server)
