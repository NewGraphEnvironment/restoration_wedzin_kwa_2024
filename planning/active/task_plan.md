# Task Plan: Reproducible report build — national DEM + Mergin-synced GIS (#147)

**Goal:** Make the report rebuildable on any machine by sourcing the DEM from the national
MRDEM-30 (`flooded::fl_dem_aoi`) instead of the local bcfishpass DEM, syncing the GIS project
via Mergin, gating the copy-to-GIS step under `update_gis`, then regenerating the LULC layers
and confirming the numbers don't diverge materially from `main`.

**Status:** `in_progress`
**Created:** 2026-06-08
**Issue:** [#147](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/147)
**Branch:** `lulc-appendix-streamline` (continues here — also carries appendix streamline + version bump)

---

## Phase 1: Build prerequisites + DB connection (local fwapg)
- [x] 1.1 Document fwapg DB prerequisite + fresh Docker path in `scripts/README.md` + `scripts/floodplain_lcc/README.md` (credit fwapg as the engine, fresh as the wrapper)
- [x] 1.2 File `fresh` issue to generalize `frs_db_conn()` off `PG_*_SHARE` → standard libpq env vars ([NewGraphEnvironment/fresh#213](https://github.com/NewGraphEnvironment/fresh/issues/213)) — separate, non-blocking
- [x] 1.3 Point pipeline DB connection at the local fwapg DB via standard libpq env vars: replace `frs_db_conn()` in `01`/`02`/`05` with `DBI::dbConnect(RPostgres::Postgres())` (credential-free; reads `PGHOST`/`PGPORT`/`PGDATABASE`/`PGUSER`/`PGPASSWORD`). No tunnel. Added libpq vars to `~/.Renviron`; bare connect verified against local fwapg.
- [x] 1.5 Read parameter CSVs (`parameters_habitat_thresholds.csv`, `parameters_fresh.csv`) from the `fresh` package (`system.file(..., package="fresh")`) instead of hand-copied gitignored project files — `fresh` vendors them from bcfishpass `example_newgraph`. Unblocks M1 (no M4 file needed). Issue #147 updated.
- [ ] 1.4 (Optional, write-back only) sync GIS project via Mergin — only needed for `update_gis=TRUE` copy-back, not for the build

## Phase 2: Switch DEM source to national MRDEM-30
- [x] 2.1 In `scripts/floodplain_lcc/02_floodplain_model.R` replace `path_dem`/`path_slope` reads + crop (and the obsolete hardcoded bcfishpass clip block) with `dem <- flooded::fl_dem_aoi(streams, buffer = buf, target_crs = sf::st_crs(streams))`
- [x] 2.2 Pass `slope = NULL` to `fl_valley_confine()` (derive slope from DEM); dropped the separate slope raster
- [x] 2.3 Kept `flood_scenarios.csv` (`run=TRUE`) unchanged so only the DEM input changes (clean A/B)
- [ ] 2.4 Ensure streams/waterbodies inputs exist (`fresh_streams_co3.gpkg`, `fresh_waterbodies_co3.gpkg`): re-run `01_network_extract.R` against the local fwapg DB — record any deviation in findings.md

## Phase 3: Unify copy-to-GIS switch under `update_gis`
- [x] 3.1 In `01`, `02`, `03` replaced `dir.exists(path_gis)`-only gate and script-local `copy_to_qgis` (03:50) with `isTRUE(params$update_gis) && dir.exists(params$path_gis)`

## Phase 3.5: Modernize 01 to link ([#148](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/148))
- [x] 3.5.1 Inspected `link` internals — persist schema via `cfg$pipeline$schema`; access in `streams_access.access_co` (0=blocked,1=modelled,2=obs-confirmed); per RUNBOOK
- [x] 3.5.2 Rewrote `01` to `link`: `lnk_config("bcfishpass")` → full pipeline for `aoi="BULK"` into dedicated schema `neexdzii`, `dams=TRUE`, `mapping_code=FALSE`. Persist verified routed to `neexdzii` — shared `fresh.*` BULK rows untouched (42861). Needs link >= 0.43.0 (#218: access without mapping_code).
- [x] 3.5.3 Subset Neexdzii reach via `fresh::frs_watershed_at_measure(blk, drm_confluence)` + spatial filter
- [x] 3.5.4 Export: `aquatic_network.gpkg` `streams_co3` (access_co IN (1,2), order≥3, +`upstream_area_ha`/`map_upstream` joined from fwapg) + `waterbodies_co3` (1915 + 215)
- [x] 3.5.5 Validated: `02` reads the gpkg and runs with national DEM → `floodplain.gpkg` (co_ff02/04/06). Also required `flooded` >= 0.3.1 (`fl_dem_aoi`).
- [ ] 3.5.6 Document reproducible DB build in `scripts/README.md` (don't rebuild); pin `link`+`fresh`+`flooded` in `renv.lock`

## Phase 4: Regenerate LULC layers from national DEM
- [ ] 4.1 Run `02_floodplain_model.R` (national DEM) → new `floodplain.gpkg`
- [ ] 4.2 Run `03_lulc_classify.R` (drift STAC) → new `floodplain_landcover.gpkg`, `rasters/co_ff04/`, `lulc_summary.rds`

## Phase 5: Sanity check vs main + rebuild
- [ ] 5.1 Extract baseline numbers from committed `docs/2043-Appendix-lulc.html` (bcfishpass DEM)
- [ ] 5.2 Rebuild appendix (`scripts/preview.R` or `run.R`); compare per-sub-basin tree loss / ag gain + total floodplain tree loss
- [ ] 5.3 Flag any sub-basin with substantial shift; investigate floodplain-extent delta before accepting

## Phase 6: Finalize
- [ ] 6.1 NEWS.md line for the DEM-source change; confirm version (0.2.10)
- [ ] 6.2 Full build via `scripts/run.R` (gitbook + exec summary PDF)
- [ ] 6.3 Commit, push, `gh pr merge`; watch post-merge CI

---

## Validation

- [ ] LULC numbers consistent with main (or divergence understood + documented)
- [ ] `/code-check` clean on each commit
- [ ] Report builds with no rendering errors
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion
