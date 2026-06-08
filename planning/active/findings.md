# Findings — Reproducible report build (#147)

## Issue context

The report can't be rebuilt on a fresh machine. The floodplain pipeline reads a
bcfishpass-derived DEM/slope from a hand-placed local file (`{path_gis}/dem_neexdzii.tif`),
and the pipeline's spatial outputs (`floodplain.gpkg`, `floodplain_landcover.gpkg`,
`rasters/co_ff04/`) are gitignored and exist only on the machine that generated them
(built on M4; absent on M1). So the LULC appendix and executive-summary numbers won't render
elsewhere.

Fix: national MRDEM-30 DEM via `flooded::fl_dem_aoi()`, Mergin-sync the GIS project,
gate copy-to-GIS under `update_gis`, regenerate + compare.

## Exploration (plan mode, 2026-06-08)

### DEM swap
- `flooded::fl_dem_aoi(aoi, source = NULL, buffer = 2000, target_crs = NULL)`
  (`flooded/R/fl_dem_aoi.R:75`) → fetches **MRDEM-30** (NRCan, `s3://canelevation-dem/mrdem-30`,
  via `/vsicurl/`, no auth), returns a `SpatRaster`. Vignettes: `flooded/vignettes/stac-dem.Rmd:56`.
- `fl_valley_confine(dem, streams, slope = NULL, slope_threshold = 9, ...)`
  (`flooded/R/fl_valley_confine.R:105`) derives slope from the DEM when `slope = NULL`
  (L134-138) → we can drop `slope_neexdzii.tif`.
- Current `02_floodplain_model.R`: `path_dem`/`path_slope` from `{path_gis}` (L79-81), loaded +
  cropped to stream extent (L100-107), passed to VCA with precomputed `slope` (L142-154).
  Scenarios from `flood_scenarios.csv` (`run=TRUE`).

### update_gis + copy gating
- `update_gis` (index.Rmd:32) used only in `2046-Appendix-sites-priority.Rmd:12,156` today.
- Copy-to-GIS gating is inconsistent: `01`/`02` use `dir.exists(params$path_gis)` only;
  `03` uses script-local `copy_to_qgis <- FALSE` (03:50, gate at 03:136).

### Mergin
- GIS project sync handled via rfp Mergin pull (private pkg) — "mergin moves" only.

### Data availability (this machine = M1)
- Present in `data/lulc/`: `subbasins.gpkg`, `lulc_summary.rds`, `break_points.csv`, `flood_scenarios.csv`.
- Missing (gitignored, regenerate or sync): `fresh_streams_co3.gpkg`, `fresh_waterbodies_co3.gpkg`,
  `floodplain.gpkg`, `floodplain_landcover.gpkg`, `rasters/co_ff04/`.
- `path_gis` (`~/Projects/gis/restoration_wedzin_kwa`) is **absent** — needs Mergin sync.
- LULC outputs are **not on S3** (UAV/LiDAR are).
- Baseline appendix numbers recoverable from committed `docs/2043-Appendix-lulc.html`.

## Risks
- MRDEM-30 is 30 m vs bcfishpass 25 m; `flood_factor=4` was tuned for 25 m. Sanity check is the guard.
- `01` (streams) needs the newgraph DB SSH tunnel — full pipeline machine-independence is a later step.
- Render-time S3 staging of heavy outputs (so render needs no pipeline) is a possible follow-up.

## Decisions

- **DB: local fwapg, no tunnel.** `01`/`02` need a fwapg PostgreSQL DB, not the remote shared DB.
  A healthy local fwapg Docker container (`fresh-db`, postgis:17) is already running on
  `localhost:5432`. The tunnel is not needed for this work.
- **Connect via standard libpq env vars.** Rejected a `frs_db_conn(source="share"/"local")` arg —
  it bakes our internal deployment vocabulary into a general package. Instead the pipeline will
  connect with `DBI::dbConnect(RPostgres::Postgres())`, which reads the standard
  `PGHOST`/`PGPORT`/`PGDATABASE`/`PGUSER`/`PGPASSWORD` env vars (set in `.Renviron` to the local
  fwapg DB). Credential-free in code, fully standard.
- **fresh generalization is separate.** `frs_db_conn()` hardcodes `PG_*_SHARE`; generalizing it
  to standard libpq env vars is filed as [fresh#213](https://github.com/NewGraphEnvironment/fresh/issues/213),
  non-blocking for #147.
- **fresh Docker = wrapper, fwapg = engine.** `fresh/docker/` is based on fwapg's Dockerfile and
  runs fwapg's own `create.sh`/`load.sh` (needs a local `fwapg` clone). READMEs credit fwapg as
  the source of the FWA data/functions and point at fresh as the convenience setup.
- **Mergin sync demoted.** With the national DEM, `path_gis` supplies no build input; Mergin sync
  is only the optional `update_gis=TRUE` write-back, not a build dependency.

_(log regeneration / comparison results below as execution proceeds)_
