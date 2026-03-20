# Floodplain Land Cover Change Pipeline

Modelled floodplain delineation and satellite-derived land cover change analysis for the Neexdzii Kwah watershed.

## Pipeline Order

| Script | Tool | Purpose |
|--------|------|---------|
| `01_network_extract.R` | fresh | Build coho-accessible stream network + filtered waterbodies |
| `02_floodplain_model.R` | flooded | Run VCA at each flood_factor scenario |
| `03_lulc_classify.R` | drift | Classify land cover per sub-basin within floodplain |
| `04_lulc_zones.R` | drift | Zone-stratified LULC (nested flood zones) |
| `05_prioritization_score.R` | — | Score sub-basins from all above |

Scripts 01 and 02 require an SSH tunnel to the database. Scripts 03–05 are disk-only.

## CSV Controls

All in `data/lulc/`:

| File | Purpose |
|------|---------|
| `flood_scenarios.csv` | VCA parameters per scenario. `run=TRUE` rows are executed. |
| `parameters_fresh.csv` | Access gradient, spawn gradient min per species |
| `parameters_habitat_thresholds.csv` | Spawn/rear gradient, channel width, MAD thresholds |
| `break_points.csv` | Sub-basin delineation points on FWA network |

## Outputs

All in `data/lulc/`:

| File | From | Description |
|------|------|-------------|
| `fresh_streams_classified.gpkg` | 01 | Full network with access + habitat columns |
| `fresh_streams_co3.gpkg` | 01 | Accessible order 3+ streams (flooded input) |
| `fresh_waterbodies_co3.gpkg` | 01 | Lakes/wetlands on accessible network |
| `floodplain.gpkg` | 02 | Multi-layer: one layer per scenario (co_ff02, co_ff04, co_ff06) |
| `floodplain_{scenario_id}.tif` | 02 | Raster per scenario |
| `subbasins.gpkg` | 02 | Sub-basin polygons from break_points.csv |
| `lulc_summary_{scenario_id}.rds` | 03 | Area/pct by class, sub-basin, year |
| `lulc_summary.rds` | 03 | Copy of active scenario for report |
| `rasters/{scenario_id}/` | 03 | Classified + transition tifs |

## QGIS Integration

Scripts 01 and 02 copy key outputs to the QGIS project at `params$path_gis` (from `index.Rmd` YAML). This path is read via `rmarkdown::yaml_front_matter(here::here("index.Rmd"))$params$path_gis`.
