# Progress — Reproducible report build (#147)

## Session 2026-06-08

- Plan-mode exploration complete — phases approved by user
- Filed issue [#147](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/147)
- Archived stale #123 PWF to `planning/archive/2026-03-issue-123-floodplain-modelling/` (#123 left open)
- Scaffolded PWF baseline for #147 on existing branch `lulc-appendix-streamline`
- Branch already carries: LULC appendix streamline, fledge-doc fix, version bump to 0.2.10
- Decided DB approach: local fwapg via standard libpq env vars (no tunnel, no `source` arg); filed [fresh#213](https://github.com/NewGraphEnvironment/fresh/issues/213) to generalize `frs_db_conn()` (non-blocking)
- Documented fwapg DB prerequisite in `scripts/README.md` + `scripts/floodplain_lcc/README.md` (credit fwapg, point at fresh Docker)
- Added standard libpq vars (`PGHOST`/`PGPORT`/`PGDATABASE`/`PGUSER`/`PGPASSWORD`) to `~/.Renviron` → local `fwapg`; bare `DBI::dbConnect(RPostgres::Postgres())` verified (db `fwapg`, FWA schemas present)
- Implemented portability code (Phases 1.3, 2, 3): DB repoint in `01`/`02`/`05`, DEM swap to `flooded::fl_dem_aoi()` (MRDEM-30) + `slope=NULL`, GIS-copy gated on `update_gis`; stale tunnel/bcfishpass header notes corrected; all scripts parse
- Hit missing parameter CSVs (gitignored, M4-only). Traced provenance: bcfishpass `example_newgraph` → vendored in `fresh/inst/extdata` → hand-copied to `data/lulc` (the hand-bomb). Repointed `01` to read them from `fresh` via `system.file(..., package="fresh")` — no M4 dependency, no need to add them to `link`. Updated issue #147 (edited body) + CLAUDE.md CSV-controls note.
- Rewrote `01` onto `link` 0.43.0 (config-driven, `aoi="BULK"` → dedicated `neexdzii` schema; persist verified not clobbering `fresh.*`). Other agent landed link#218 (access without mapping_code); confirmed via docs. access_co IN (1,2) = accessible (1 modelled, 2 obs-confirmed).
- Export: `aquatic_network.gpkg` streams_co3 (1915, accessible order≥3, upstream_area_ha+map_upstream joined from fwapg) + waterbodies_co3 (215).
- Ran `02` (national MRDEM-30) on the link network → `floodplain.gpkg` (co_ff02/04/06). Required `flooded` 0.3.1 (`fl_dem_aoi`).
- Next: commit `01` rewrite, then `03` (drift LULC) → compare vs main; then renv pin + DB-build docs
