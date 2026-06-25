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
- Committed `01` link rewrite (aa251d0); ran full chain (02 national DEM, 03 drift LULC) → regenerated floodplain + landcover (bcfishpass config).
- Deep investigation of old-gpkg vs link network difference (2026-06-12..14): RESOLVED. Network identical (deterministic fwa_upstream, confirmed against db_newgraph tunnel); the ~56 km accessibility difference is `fresh::frs_break_find`'s gradient algorithm change (#87 island-based, adapted from bcfishpass) — old `01` used #56-era, link uses current/bcfishpass-accurate. No `frs` update needed. See findings.md.
- Switched `01` to `lnk_config("default")` (subsurface OFF, NewGraph methodology) + added `DROP SCHEMA` before run (config-switch persist fix). Default network: 1936 segs / 678.2 km.
- Mergin-synced authoritative `floodplain_landcover.gpkg` (`mergin_sync.R pull`); confirmed served baseline = **−646.7 ha** tree loss (sieved `transition_co_ff04_2017_2023`, stored==geometry, matches ~647 headline). Mergin file current (NOT stale); earlier −1108 was a misread artifact. New reproducible build = −746 ha → ~+15% from the 30 m MRDEM-30 DEM, not accessibility. See findings.md.
- Clip-behaviour proof (2026-06-16): `dft_transition_vectors` uses `st_intersection` (clip, not drop). Empirically Y(zoned)=Z(independently clipped)=1557.7 ha exactly; only 9.9 ha of real change trimmed outside sub-basins. Straddling patches keep their in-study-area portion. User: expected, all good.
- Network-difference reconciliation (2026-06-25): RETRACTED the earlier "frs_break_find #87 gradient-change" root cause as over-confident. Git+NEWS archaeology: served `co_ff04` floodplain modelled March 2026 (NEWS v0.2.6/#138) via `fresh::frs_break_find` over the bcfp tunnel (`1c2e3e9`: frs_db_conn + frs_network + frs_break_find, accessible order≥3, ff=4, bcfp 25m DEM). User's "pulled from tunnel via fresh" memory confirmed. link bcfishpass parity (~98%, CO 97.9%) is recent — postdates the served model — so the ~56km delta = fresh vintage drift, not chased. Headline 647→746 ha is DEM-dominated. Decision: accept+document in NEWS, no flood_factor retune.
- Next: draft NEWS entry for the portable-build methodology change + headline revision; then report rebuild + number propagation, renv pin, PR.
