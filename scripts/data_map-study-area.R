# data_map-study-area.R
#
# Queries bcfishpass DB and caches spatial layers for map_study-area.R.
# Run once when source data changes. Requires SSH tunnel on port 63333.
#
# Usage: Rscript scripts/data_map-study-area.R

library(sf)
library(dplyr)
sf_use_s2(FALSE)

conn <- DBI::dbConnect(
  RPostgres::Postgres(),
  host = "localhost", port = 63333,
  dbname = "bcfishpass", user = "newgraph"
)

out <- "data/spatial"
dir.create(out, showWarnings = FALSE)

# --- Neexdzii Kwah watershed boundary ------------------------------------
# Upstream of blue_line_key 360873822 at measure 166030.4
# (above Morice confluence — no st_difference needed)

neexdzii <- sf::st_read(conn, query = "
  SELECT ST_Transform(ST_Simplify(geom, 200), 4326) as geom
  FROM fwa_watershedatmeasure(360873822, 166030.4)
") |>
  st_make_valid() |>
  mutate(watershed = "Neexdzii Kwah")

saveRDS(neexdzii, file.path(out, "neexdzii.rds"))
message("Saved neexdzii watershed")

# --- Streams (4th order+) within Neexdzii Kwah ---------------------------

streams <- sf::st_read(conn, query = "
  SELECT s.gnis_name, s.stream_order,
         ST_Transform(ST_Simplify(s.geom, 50), 4326) as geom
  FROM whse_basemapping.fwa_stream_networks_sp s
  WHERE s.watershed_group_code = 'BULK'
    AND s.stream_order >= 4
")
# FWA streams carry XYZM; drop for GEOS compatibility, then clip
streams <- st_zm(streams) |>
  st_intersection(neexdzii |> select(geom)) |>
  select(gnis_name, stream_order)
saveRDS(streams, file.path(out, "streams.rds"))
message("Saved streams")

# --- Lakes ----------------------------------------------------------------

lakes <- sf::st_read(conn, query = "
  SELECT l.gnis_name_1 as name,
         ST_Transform(ST_Simplify(l.geom, 50), 4326) as geom,
         ST_Area(l.geom) / 1e6 as area_km2
  FROM whse_basemapping.fwa_lakes_poly l
  WHERE l.watershed_group_code = 'BULK'
    AND ST_Area(l.geom) > 2e5
")
lakes <- st_intersection(lakes, neexdzii |> select(geom))
saveRDS(lakes, file.path(out, "lakes.rds"))
message("Saved lakes")

# --- Parks & protected areas ----------------------------------------------

parks <- sf::st_read(conn, query = "
  WITH ws AS (
    SELECT geom FROM whse_basemapping.fwa_watershed_groups_poly
    WHERE watershed_group_code = 'BULK'
  )
  SELECT p.protected_lands_name as name,
         p.protected_lands_designation as designation,
         ST_Transform(ST_Simplify(ST_Intersection(p.geom, ws.geom), 100), 4326) as geom
  FROM whse_tantalis.ta_park_ecores_pa_svw p, ws
  WHERE ST_Intersects(p.geom, ws.geom)
") |> st_make_valid()
parks <- st_intersection(parks, neexdzii |> select(geom))
saveRDS(parks, file.path(out, "parks.rds"))
message("Saved parks")

# --- Roads (highway + arterial) -------------------------------------------

roads <- sf::st_read(conn, query = "
  WITH ws AS (
    SELECT geom FROM whse_basemapping.fwa_watershed_groups_poly
    WHERE watershed_group_code = 'BULK'
  )
  SELECT t.transport_line_type_code as road_type,
         t.highway_route_1 as route,
         ST_Transform(ST_Simplify(t.geom, 50), 4326) as geom
  FROM whse_basemapping.transport_line t, ws
  WHERE t.transport_line_type_code IN ('RH1', 'RA1', 'RA2')
    AND ST_Intersects(t.geom, ST_Expand(ws.geom, 10000))
")
saveRDS(roads, file.path(out, "roads.rds"))
message("Saved roads")

# --- Railway --------------------------------------------------------------

railway <- sf::st_read(conn, query = "
  WITH ws AS (
    SELECT geom FROM whse_basemapping.fwa_watershed_groups_poly
    WHERE watershed_group_code = 'BULK'
  )
  SELECT ST_Transform(ST_Simplify(r.geom, 50), 4326) as geom
  FROM whse_basemapping.gba_railway_tracks_sp r, ws
  WHERE r.track_classification = 'Main'
    AND ST_Intersects(r.geom, ST_Expand(ws.geom, 10000))
") |>
  summarise(geom = st_union(geom))
saveRDS(railway, file.path(out, "railway.rds"))
message("Saved railway")

DBI::dbDisconnect(conn)
message("\nAll spatial layers cached to ", out)
