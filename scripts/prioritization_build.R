#!/usr/bin/env Rscript
#
# prioritization_build.R
#
# Build area-level and project-level prioritization CSVs from existing outputs:
#   - data/lulc/subbasins.gpkg         (sub-basin geometries + area)
#   - data/lulc/lulc_summary.rds       (drift land cover by sub-basin/year)
#   - data/gis/sites_prioritized.geojson (GIS-scored sites from prioritize.R)
#
# Outputs:
#   data/prioritization/area_scores.csv     — sub-basin level scoring scaffold
#   data/prioritization/project_scores.csv  — site/project level scoring scaffold
#
# Relates to #125

library(sf)
library(dplyr)
library(readr)

sf::sf_use_s2(FALSE)

out_dir <- here::here("data", "prioritization")

# =============================================================================
# Part 1: Area scores from LULC outputs
# =============================================================================

# --- Load sub-basin geometries ---
subbasins <- sf::st_read(
  here::here("data", "lulc", "subbasins.gpkg"), quiet = TRUE
)

# --- Load drift LULC summary ---
lulc <- readRDS(here::here("data", "lulc", "lulc_summary.rds"))

# --- Load floodplain polygon for area calc per sub-basin ---
floodplain <- sf::st_read(
  here::here("data", "lulc", "floodplain_neexdzii_co.gpkg"), quiet = TRUE
) |> sf::st_transform(sf::st_crs(subbasins))

# Floodplain area per sub-basin (ha)
fp_areas <- subbasins |>
  dplyr::mutate(
    fp_geom = purrr::map(
      seq_len(dplyr::n()),
      ~ {
        clip <- sf::st_intersection(floodplain, subbasins[.x, ])
        if (nrow(clip) == 0) return(sf::st_sfc(sf::st_polygon(), crs = sf::st_crs(subbasins)))
        sf::st_union(clip)
      }
    ),
    floodplain_area_ha = purrr::map_dbl(fp_geom, ~ as.numeric(sf::st_area(.x)) / 10000)
  ) |>
  sf::st_drop_geometry() |>
  dplyr::select(name_basin, area_km2, floodplain_area_ha)

# --- Compute tree cover change per sub-basin ---
# Trees area in 2017 and 2023 from drift summary
tree_change <- lulc |>
  dplyr::filter(class_name == "Trees", year %in% c(2017, 2023)) |>
  dplyr::select(subbasin, year, area) |>
  tidyr::pivot_wider(names_from = year, values_from = area, names_prefix = "trees_ha_") |>
  dplyr::mutate(
    tree_loss_ha = trees_ha_2023 - trees_ha_2017,
    tree_loss_pct = round(tree_loss_ha / trees_ha_2017 * 100, 1)
  )

# --- Agriculture superclass change (Crops + Rangeland + Bare Ground) ---
ag_classes <- c("Crops", "Rangeland", "Bare Ground")

ag_change <- lulc |>
  dplyr::filter(class_name %in% ag_classes, year %in% c(2017, 2023)) |>
  dplyr::group_by(subbasin, year) |>
  dplyr::summarise(ag_area = sum(area), .groups = "drop") |>
  tidyr::pivot_wider(names_from = year, values_from = ag_area, names_prefix = "ag_ha_") |>
  dplyr::mutate(
    ag_change_ha = ag_ha_2023 - ag_ha_2017,
    ag_change_pct = round(ag_change_ha / ag_ha_2017 * 100, 1)
  )

# --- Position relative to barriers ---
# Encode from sub-basin names (known from break_points.csv structure)
barrier_position <- tibble::tribble(
  ~name_basin,                    ~position,
  "Bulkley-Houston",              "below_bulkley_falls",
  "Bulkley Houston-McKilligan",   "below_bulkley_falls",
  "Bulkley Byman-JDavid",        "below_bulkley_falls",
  "Bulkley JDavid-Richfield",    "below_bulkley_falls",
  "Bulkley Richfield-Falls",     "below_bulkley_falls",
  "Aitken Creek",                 "below_bulkley_falls",
  "Bulkley Upstream Falls",       "above_bulkley_falls",
  "Taman Creek",                  "above_bulkley_falls",
  "Maxam Creek",                  "above_bulkley_falls",
  "Maxan Lake",                   "above_bulkley_falls",
  "Foxy Creek",                   "above_bulkley_falls",
  "Gilmore-Day Lakes",            "above_bulkley_falls",
  "Buck Creek Downstream Falls",  "below_buck_falls",
  "Buck Creek Upstream Falls",    "above_buck_falls"
)

# --- Assemble area_scores.csv ---
area_scores <- fp_areas |>
  dplyr::left_join(barrier_position, by = "name_basin") |>
  dplyr::left_join(tree_change, by = c("name_basin" = "subbasin")) |>
  dplyr::left_join(ag_change, by = c("name_basin" = "subbasin")) |>
  dplyr::mutate(
    # Placeholder columns for manual/governance scoring (0-5 scale)
    fish_value_score = NA_integer_,
    cultural_significance_score = NA_integer_,
    community_accessibility_score = NA_integer_,
    cumulative_pressure_score = NA_integer_,
    active_degradation_flag = NA_character_,
    area_priority_score = NA_integer_,
    notes = NA_character_
  ) |>
  dplyr::select(
    name_basin, area_km2, floodplain_area_ha, position,
    trees_ha_2017, trees_ha_2023, tree_loss_ha, tree_loss_pct,
    ag_ha_2017, ag_ha_2023, ag_change_ha, ag_change_pct,
    fish_value_score, cultural_significance_score,
    community_accessibility_score, cumulative_pressure_score,
    active_degradation_flag, area_priority_score, notes
  )

readr::write_csv(area_scores, file.path(out_dir, "area_scores.csv"))
message("Wrote ", file.path(out_dir, "area_scores.csv"))

# =============================================================================
# Part 2: Project scores from prioritized sites
# =============================================================================

# --- Load GIS-scored sites ---
sites <- sf::st_read(
  here::here("data", "gis", "sites_prioritized.geojson"), quiet = TRUE
)

# --- Assign sub-basin to each site via spatial join ---
sites_sb <- sf::st_transform(sites, sf::st_crs(subbasins)) |>
  sf::st_join(
    subbasins |> dplyr::select(name_basin),
    join = sf::st_within,
    left = TRUE
  )

# --- Build project scaffold ---
# Carry forward the existing GIS total_score and key attributes,
# add new columns for the governance framework scoring
project_scores <- sites_sb |>
  sf::st_drop_geometry() |>
  dplyr::select(
    idx, site_id, site_name_proposed, source, name_basin,
    lon, lat,
    # Existing GIS scores
    total_score,
    bulkley_falls_downstream, floodplain_ind, owner_type,
    # Wet'suwet'en governance
    dplyr::any_of(c("name_wet_house", "house", "clan", "clan_english", "chiefs")),
    # bcfishpass fish habitat
    dplyr::starts_with("model_spawning"),
    dplyr::starts_with("model_rearing")
  ) |>
  dplyr::mutate(
    # Gate columns (TRUE/FALSE/NA)
    gate_diagnostic_certainty = NA,
    gate_active_degradation_clear = NA,
    gate_access_willingness = NA,
    # New framework scoring (0-5 scale, manual/governance input)
    project_type = NA_character_,  # site, reach, programmatic
    watershed_function_gain = NA_integer_,
    root_cause_alignment = NA_integer_,
    scale_of_benefit_ha = NA_real_,
    fish_habitat_connectivity = NA_integer_,
    probability_of_success = NA_integer_,
    cultural_significance = NA_integer_,
    collective_wellbeing = NA_integer_,
    passive_first_bonus = NA_integer_,
    delivery_bucket = NA_integer_,  # 1-4 per Ian's framework
    framework_score = NA_integer_,
    notes = NA_character_
  )

readr::write_csv(project_scores, file.path(out_dir, "project_scores.csv"))
message("Wrote ", file.path(out_dir, "project_scores.csv"))

message("\nDone. Review CSVs in ", out_dir)
message("  - area_scores.csv: ", nrow(area_scores), " sub-basins")
message("  - project_scores.csv: ", nrow(project_scores), " sites")
