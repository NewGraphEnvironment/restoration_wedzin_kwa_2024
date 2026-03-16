#!/usr/bin/env Rscript
#
# prioritization_score.R
#
# Compute sub-basin prioritization metrics by intersecting spatial layers
# with sub-basin polygons. Adds data-driven columns to area_scores.csv.
#
# Sources:
#   - Fish habitat: bcfishpass streams_co_vw + streams_ch_vw (DB via fresh)
#   - Land ownership: background_layers.gpkg (pmbc parcels ∩ floodplain)
#   - Reserves: background_layers.gpkg (clab_indian_reserves ∩ sub-basins)
#   - Cultural sites: trad_fish_sites_gottesfeld_rabnett2007.gpkg ∩ sub-basins
#   - LULC: already in area_scores.csv from prioritization_build.R
#
# Requires:
#   - SSH tunnel: ssh -L 63333:<db_host>:5432 <ssh_host>
#   - R packages: fresh, sf, readr, dplyr
#
# Outputs:
#   data/prioritization/area_scores.csv (updated with new columns)
#
# Relates to #125

library(sf)
library(dplyr)
library(readr)
library(fresh)

sf_use_s2(FALSE)

# --- DB connection (fresh conn-first API) ---
conn <- frs_db_conn()

# --- Paths ---
out_dir <- here::here("data", "prioritization")
lulc_dir <- here::here("data", "lulc")
gis_dir <- "/Users/airvine/Projects/gis/restoration_wedzin_kwa"
cultural_sites_path <- "/Users/airvine/Library/CloudStorage/OneDrive-Personal/Projects/gis/data_secure/wetsuweten_treaty_society/trad_fish_sites_gottesfeld_rabnett2007FishPassage.gpkg"

# --- Load sub-basins and floodplain ---
message("Loading sub-basins and floodplain...")
subbasins <- sf::st_read(file.path(lulc_dir, "subbasins.gpkg"), quiet = TRUE) |>
  sf::st_transform(3005)

fp_file <- file.path(lulc_dir, "floodplain_neexdzii_co_ff06.gpkg")
if (!file.exists(fp_file)) fp_file <- file.path(lulc_dir, "floodplain_neexdzii_co.gpkg")
floodplain <- sf::st_read(fp_file, quiet = TRUE)

# --- Load existing area_scores ---
area_scores <- readr::read_csv(file.path(out_dir, "area_scores.csv"), show_col_types = FALSE)

# --- 1. Fish habitat from DB (coho + chinook) ---
blk <- 360873822
drm <- 166030.4

message("Querying coho habitat streams from DB...")
co_result <- frs_network(
  conn,
  blue_line_key = blk,
  downstream_route_measure = drm,
  tables = list(
    streams = list(
      table = "bcfishpass.streams_co_vw",
      cols = c("segmented_stream_id", "stream_order", "spawning", "rearing", "access", "geom"),
      wscode_col = "wscode",
      localcode_col = "localcode"
    )
  )
)
# frs_network returns sf directly for single table, or list for multiple
co_streams <- if (inherits(co_result, "sf")) co_result else co_result$streams
co_streams <- sf::st_zm(co_streams, drop = TRUE)

message("Querying chinook habitat streams from DB...")
ch_result <- frs_network(
  conn,
  blue_line_key = blk,
  downstream_route_measure = drm,
  tables = list(
    streams = list(
      table = "bcfishpass.streams_ch_vw",
      cols = c("segmented_stream_id", "stream_order", "spawning", "rearing", "access", "geom"),
      wscode_col = "wscode",
      localcode_col = "localcode"
    )
  )
)
ch_streams <- if (inherits(ch_result, "sf")) ch_result else ch_result$streams
ch_streams <- sf::st_zm(ch_streams, drop = TRUE)

# Compute lengths
co_streams$length_m <- as.numeric(sf::st_length(co_streams))
ch_streams$length_m <- as.numeric(sf::st_length(ch_streams))

# Spatial join: streams to sub-basins
message("Joining streams to sub-basins...")
co_joined <- sf::st_join(co_streams, subbasins["name_basin"], largest = TRUE)
ch_joined <- sf::st_join(ch_streams, subbasins["name_basin"], largest = TRUE)

co_hab <- co_joined |>
  sf::st_drop_geometry() |>
  dplyr::group_by(name_basin) |>
  dplyr::summarize(
    co_total_km = round(sum(length_m) / 1000, 1),
    co_spawn_km = round(sum(length_m[spawning == 1]) / 1000, 1),
    co_rear_km  = round(sum(length_m[rearing == 1]) / 1000, 1),
    .groups = "drop"
  )

ch_hab <- ch_joined |>
  sf::st_drop_geometry() |>
  dplyr::group_by(name_basin) |>
  dplyr::summarize(
    ch_total_km = round(sum(length_m) / 1000, 1),
    ch_spawn_km = round(sum(length_m[spawning == 1]) / 1000, 1),
    ch_rear_km  = round(sum(length_m[rearing == 1]) / 1000, 1),
    .groups = "drop"
  )

message("  Coho: ", nrow(co_hab), " sub-basins with habitat")
message("  Chinook: ", nrow(ch_hab), " sub-basins with habitat")

# --- 2. Land ownership within floodplain per sub-basin ---
message("Loading parcels from GIS project...")
parcels <- sf::st_read(
  file.path(gis_dir, "background_layers.gpkg"),
  layer = "whse_cadastre.pmbc_parcel_fabric_poly_svw",
  quiet = TRUE
) |> sf::st_make_valid()

# Intersect parcels with floodplain, then with sub-basins
message("Intersecting parcels with floodplain...")
fp_parcels <- sf::st_intersection(parcels, sf::st_union(floodplain)) |>
  sf::st_make_valid()

fp_parcels_by_basin <- sf::st_join(fp_parcels, subbasins["name_basin"], largest = TRUE)
fp_parcels_by_basin$area_ha <- as.numeric(sf::st_area(fp_parcels_by_basin)) / 1e4

ownership <- fp_parcels_by_basin |>
  sf::st_drop_geometry() |>
  dplyr::group_by(name_basin) |>
  dplyr::summarize(
    fp_private_ha = round(sum(area_ha[owner_type == "Private"], na.rm = TRUE), 1),
    fp_crown_ha   = round(sum(area_ha[owner_type %in% c("Crown Provincial", "Untitled Provincial", "Crown Agency", "Local Government", "Federal", "Unclassified")], na.rm = TRUE), 1),
    fp_other_ha   = round(sum(area_ha[!owner_type %in% c("Private", "Crown Provincial", "Untitled Provincial", "Crown Agency", "Local Government", "Federal", "Unclassified")], na.rm = TRUE), 1),
    .groups = "drop"
  )

message("  Ownership: ", nrow(ownership), " sub-basins")

# --- 3. Reserves ---
message("Loading reserves...")
reserves <- sf::st_read(
  file.path(gis_dir, "background_layers.gpkg"),
  layer = "whse_admin_boundaries.clab_indian_reserves",
  quiet = TRUE
) |> sf::st_make_valid()

reserves_by_basin <- sf::st_join(reserves, subbasins["name_basin"], largest = TRUE)
reserves_by_basin$area_ha <- as.numeric(sf::st_area(reserves_by_basin)) / 1e4

reserve_summary <- reserves_by_basin |>
  sf::st_drop_geometry() |>
  dplyr::group_by(name_basin) |>
  dplyr::summarize(
    reserve_area_ha = round(sum(area_ha, na.rm = TRUE), 1),
    n_reserves = dplyr::n(),
    .groups = "drop"
  )

message("  Reserves: ", sum(reserve_summary$n_reserves), " in ", nrow(reserve_summary), " sub-basins")

# --- 4. Cultural sites ---
message("Loading cultural sites...")
cultural <- sf::st_read(cultural_sites_path, quiet = TRUE)

cultural_by_basin <- sf::st_join(cultural, subbasins["name_basin"])

cultural_summary <- cultural_by_basin |>
  sf::st_drop_geometry() |>
  dplyr::group_by(name_basin) |>
  dplyr::summarize(
    n_cultural_sites = dplyr::n(),
    .groups = "drop"
  )

message("  Cultural sites: ", sum(cultural_summary$n_cultural_sites), " in ", nrow(cultural_summary), " sub-basins")

# --- Merge all into area_scores ---
message("Merging into area_scores...")

# Drop old columns that we're now computing (handles reruns cleanly)
cols_to_drop <- c(
  "fish_value_score", "cultural_significance_score",
  "community_accessibility_score", "cumulative_pressure_score",
  "active_degradation_flag", "area_priority_score", "notes",
  "co_total_km", "co_spawn_km", "co_rear_km",
  "ch_total_km", "ch_spawn_km", "ch_rear_km",
  "fp_private_ha", "fp_crown_ha", "fp_other_ha",
  "reserve_area_ha", "n_reserves", "n_cultural_sites"
)
# Also drop any .x/.y suffixed duplicates from prior bad runs
all_drop <- c(cols_to_drop, paste0(cols_to_drop, ".x"), paste0(cols_to_drop, ".y"))
area_scores <- area_scores |>
  dplyr::select(-dplyr::any_of(all_drop))

area_scores <- area_scores |>
  dplyr::left_join(co_hab, by = "name_basin") |>
  dplyr::left_join(ch_hab, by = "name_basin") |>
  dplyr::left_join(ownership, by = "name_basin") |>
  dplyr::left_join(reserve_summary, by = "name_basin") |>
  dplyr::left_join(cultural_summary, by = "name_basin")

# Fill NA with 0 for numeric columns
fill_cols <- c(
  "co_total_km", "co_spawn_km", "co_rear_km",
  "ch_total_km", "ch_spawn_km", "ch_rear_km",
  "fp_private_ha", "fp_crown_ha", "fp_other_ha",
  "reserve_area_ha", "n_reserves", "n_cultural_sites"
)
area_scores <- area_scores |>
  dplyr::mutate(dplyr::across(dplyr::any_of(fill_cols), ~ tidyr::replace_na(.x, 0)))

# Write
readr::write_csv(area_scores, file.path(out_dir, "area_scores.csv"))
message("\nWrote: data/prioritization/area_scores.csv")
message("Columns: ", paste(names(area_scores), collapse = ", "))

DBI::dbDisconnect(conn)
