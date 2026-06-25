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

## Network / accessibility investigation (2026-06-12..14) — RESOLVED

Investigated why the link-derived coho network differed from the old (main) gpkg.
Conclusion: the network *grab* is identical; the difference is the **`fresh::frs_break_find`
gradient algorithm changing** between old `01` and now.

- **Network is identical across databases.** `frs_network` reaches upstream purely via
  `whse_basemapping.fwa_upstream(wscode_ltree, localcode_ltree)` (deterministic FWA topology).
  Pulled from the `db_newgraph` tunnel (the DB old `01` used) AND local fwapg: both give
  **4158.7 km all-order / 919.3 km order≥3**, identical to the old gpkg. Differing segment
  *counts* (old 24,114 vs raw 8,876) are just segmentation (old `01` broke at barriers+habitat).
  So `linear_feature_id`/segment-count comparisons were invalid the whole time.
- **The only real difference is CO accessibility:** old accessible 733.9 km vs link 678.2 km
  (~56 km), on the identical 919 km backbone. Both are clean subsets (no over-grab).
- **Root cause = `frs_break_find` gradient method changed.** Old `01` used the #56-era version;
  link uses current. fresh #87 ("Island-based gradient breaks: entry only, min 100m sustained,
  **adapted from bcfishpass `gradient_barriers_load.sql`**"), #118, #128 rewrote gradient
  detection to reproduce bcfishpass. So current `frs_break_find` is the bcfishpass-accurate one
  (~99% parity); old `01`'s 734 km used the superseded gradient method. NOT a DB, config,
  subsurface, anthropogenic, or new-table difference.
- **link uses `fresh::frs_break_find` for gradient** (`lnk_pipeline_prepare.R:347`) — same
  function old `01` called; no `frs` update needed (already #87+). Old gpkg is simply stale.
- **Config:** switched `01` from `lnk_config("bcfishpass")` to `lnk_config("default")` — the
  NewGraph methodology bundle leaves `subsurfaceflow` OFF (bcfishpass opts it in for parity).
  Subsurface accounted for only ~5 km of the gap anyway.
- **link gotcha fixed in `01`:** `lnk_persist_init` only creates persist tables when absent, so
  switching configs (different species set, e.g. `rb`) on an existing schema fails the persist
  INSERT. `01` now `DROP SCHEMA neexdzii CASCADE` before the run.
- **Decision:** use the link default-config network (current `frs`, bcfishpass-accurate). The
  new floodplain tree-loss is *larger* than main despite the *smaller* network → driven by the
  DEM (30 m MRDEM-30 vs 25 m), not accessibility.

## Authoritative baseline confirmed (2026-06-15) — Mergin sync

Pulled the served `floodplain_landcover.gpkg` from Mergin (`newgraph/restoration_wedzin_kwa`,
`scripts/gis/mergin_sync.R pull` → `~/Projects/gis/restoration_wedzin_kwa`). Computed tree
loss from `transition_co_ff04_2017_2023` (the sieved ≥1 ha transition vector):

- **Tree loss = −646.7 ha** (stored `area_ha` AND geometry-recompute AGREE; total transition
  area 1354.4 ha; Trees lost 806.3 ha, gained 159.5 ha). **Matches the served ~647 ha headline
  exactly.**
- **The Mergin file is current, NOT stale.** In this authoritative file stored `area_ha` ==
  geometry area, so its transition polygons are already post-clip/correct. The earlier
  −1108/−1029 figure was a misread of a different/stale artifact (total area 14,068 ha — ~10×
  the correct 1354 ha — i.e. an unsieved or pre-intersection layer), not the served file.
- **Real baseline gap:** served/main = −646.7 ha (old fresh network 734 km, bcfishpass 25 m
  DEM) vs new reproducible build = −746 ha (link default network 678 km, MRDEM-30 30 m DEM).
  New build runs ~+100 ha / ~+15% hotter despite a *smaller* accessible network → driven by
  the **DEM** (30 m vs 25 m; `flood_factor=4` was tuned for 25 m), not accessibility. This is
  the documented divergence to carry into the appendix methods note.

## Network-difference reconciliation — SUPERSEDES the 2026-06-12..14 conclusion (2026-06-25)

The earlier "RESOLVED" section below pinned the served-vs-link accessibility delta on a
`frs_break_find` gradient-algorithm change (#87 island-based). **That attribution is retracted
as over-confident** — we could not (and need not) verify a single root cause. Git + NEWS
archaeology gives the actual, documented history:

- **Served floodplain provenance (the `co_ff04`, ~647 ha build):** modelled **March 2026**.
  NEWS v0.2.6 (2026-03-19, #138): "build stream network with `fresh` classification pipeline
  instead of bcfishpass views" + "flood_factor reduced from 6 to 4". The last main `01`
  (`1c2e3e9`) connects via `frs_db_conn()` (**bcfp tunnel**), builds the network with
  `fresh::frs_network` from FWA base, computes access with `fresh::frs_break_find`
  (gradient @ 15% + `bcfishpass.falls_vw` falls), exports `accessible IS TRUE & stream_order
  >= 3`. → User's memory ("pulled from bcfp tunnel via fresh") is correct; it also used
  `frs_break_find` on that tunnel data, so "tunnel pull" and "frs_break_find" are not mutually
  exclusive. (The original #115 pure `bcfishpass.streams_co_vw` pull at order≥4 / ff=6 was a
  *predecessor*, replaced before the served report.)
- **New build:** `link` default config (June 2026), `fresh::frs_break_find` under the hood,
  against **local fwapg** + national **MRDEM-30 (30 m)** DEM, ff=4, order≥3.
- **Why we stop here:** the link agent confirmed link's access model reproduces bcfishpass
  within ~2% (CO 97.90%, issue #200) — but that parity work is **recent, well after the served
  floodplain was modelled**. So the served network used an earlier `fresh` vintage; the small
  (~56 km / <8%) accessibility delta reflects `fresh`'s evolution between March and June, not a
  cleanly isolable single cause. Not worth chasing.
- **Headline driver:** the ~647 → ~746 ha tree-loss shift is **DEM-dominated** (30 m MRDEM-30
  vs 25 m bcfishpass habitat_lateral → wider floodplain at ff=4); accessibility/network-vintage
  is a minor secondary contributor.
- **Decision (user, 2026-06-25):** accept + document the methodology change in NEWS; do not
  retune flood_factor, do not chase the network delta further. The new pipeline is the
  reproducible/portable one going forward.

## Sub-basin coverage gap — EXPECTED, no action (2026-06-16)

Checked the 346.6 ha of floodplain (`co_ff04`) falling outside the sub-basin union. It is NOT
a distributed rim or silent error: it is 3 discrete chunks at the analysis-reach extremities —
267 ha (77%) at the downstream confluence end (past the `Bulkley Confluence-McKilligan`
boundary cut), 59 + 20 ha at the upstream/headwater end, plus 2 × 0.2 ha true slivers. The
DEM-derived floodplain simply overshoots the topology-derived sub-basin boundary cuts at the
two ends of the reach. `dft_transition_vectors()` correctly trims this out-of-reporting-frame
area via its zonal intersection. User confirmed: **expected behaviour, all good — no drift
issue.** Does not affect the −647 vs −746 comparison (same sub-basins/trim in both builds).
Map: /tmp/gap_map.png.
