# Scripts

Pipeline for sub-basin delineation, floodplain modelling, land cover classification, and prioritization scoring.

## Pipeline Order

| Step | Script | What it does |
|------|--------|-------------|
| 1 | `fwa_extract_flood.R` | Generate sub-basin polygons from `break_points.csv` via `frs_watershed_split()`, extract FWA stream network via `frs_network()`, build floodplain AOI via flooded VCA |
| 2 | `lulc_classify.R` | Fetch IO LULC imagery via drift STAC, classify per sub-basin, save `lulc_summary.rds` |
| 3 | `prioritization_score.R` | Assemble `area_scores.csv` and `project_scores.csv` from sub-basins, LULC, fish habitat (DB), land ownership, reserves, cultural sites |

## Data Flow

```
break_points.csv  ──→  fwa_extract_flood.R  ──→  subbasins.gpkg (name_basin, description, fisheries_value)
                              │                         │
                              ↓                         ↓
                       floodplain AOI ──→  lulc_classify.R  ──→  lulc_summary.rds (name_basin)
                       streams gpkg               │
                              │                   ↓
                              └──────→  prioritization_score.R  ──→  area_scores.csv
                                                                      project_scores.csv
```

`name_basin` is the join key throughout — defined once in `break_points.csv`, carried through `subbasins.gpkg` to all downstream outputs.

## Sketch / Future

| Script | Status | Purpose |
|--------|--------|---------|
| `lulc_classify_zones.R` | Sketch | Zone-stratified LULC within nested flood zones (bankfull → rearing → functional → migration) |

## Other Scripts

See `scripts/gis/`, `scripts/api_skt.R`, `scripts/fwa_query.R`, etc. for data ingestion and GIS processing outside the main pipeline.
