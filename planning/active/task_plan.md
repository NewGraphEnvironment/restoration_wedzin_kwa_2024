# Task Plan: Multi-Scenario Floodplain Modelling Pipeline

**Goal:** Run flooded VCA at multiple flood_factor scenarios to map nested floodplain zones, run drift LULC change detection within each zone stratified by sub-basin (25m DEM), and produce site-specific template restoration design maps at 1m LiDAR (2-3 pilot sites).

**Status:** `in_progress`
**Created:** 2026-03-17
**Issue:** [#123](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/123)
**Branch:** `123-floodplain-refinement`
**SRED:** Relates to NewGraphEnvironment/sred-2025-2026#4

---

## Phase 1: Literature Review & Scenario Lock
**Status:** `complete`
**Upstream:** Research here feeds [flooded#28](https://github.com/NewGraphEnvironment/flooded/issues/28) — VCA parameter documentation + default scenarios will live in flooded

- [x] 1.1 Semantic search Zotero for each scenario's ecological basis
- [x] 1.2 Build BBT citation keys per scenario via `/zotero-lookup`
- [x] 1.3 Document rationale in findings.md — cover ALL VCA params (flood_factor, slope_threshold, max_width, cost_threshold, size_threshold, hole_threshold, precip), not just flood_factor
- [x] 1.4 Add columns to `data/lulc/flood_scenarios.csv`: `ecological_process`, `citations`
- [x] 1.5 Note: flood_factor-to-process mapping is interpretive framework, not calibrated thresholds

---

## Phase 2: Add `dft_rast_zonal()` to drift
**Status:** `pending`
**Repo:** `/Users/airvine/Projects/repo/drift`

- [ ] 2.1 File issue in drift
- [ ] 2.2 Create `R/dft_rast_zonal.R`
- [ ] 2.3 Create `tests/testthat/test-dft_rast_zonal.R`
- [ ] 2.4 Roxygen docs with runnable example
- [ ] 2.5 Export in NAMESPACE, `devtools::document()`
- [ ] 2.6 Add/extend vignette showing zonal workflow on small AOI
- [ ] 2.7 `devtools::test()` + `lintr::lint_package()`
- [ ] 2.8 Commit with `Fixes #N`, bump version

**Function signature:**
```r
dft_rast_zonal(x, zones, zone_col = "zone_id", source = "io-lulc", unit = "ha")
# Returns tibble: zone_id | year | code | class_name | color | n_cells | area | pct
```

---

## Phase 3: Test VCA Pipeline on 1 Sub-Basin (25m DEM)
**Status:** `pending`
**Requires:** SSH tunnel + bcfishpass DEM

- [ ] 3.1 Check out branch `123-floodplain-refinement`
- [ ] 3.2 Pick 1 test sub-basin with known floodplain features
- [ ] 3.3 Run `fwa_extract_flood.R` for all 6 scenarios on that sub-basin
- [ ] 3.4 Inspect: polygon areas increase monotonically with flood_factor?
- [ ] 3.5 Run zone-stratified LULC on that sub-basin using `dft_rast_zonal()`
- [ ] 3.6 Review results — does zone stratification reveal different patterns?
- [ ] 3.7 **Decision point:** proceed to scale up

---

## Phase 4: Scale Up — Watershed (25m)
**Status:** `pending`

- [ ] 4.1 Run `fwa_extract_flood.R all` (all 6 scenarios, full watershed)
- [ ] 4.2 Decide zone boundaries (likely ff02, ff04, ff06, ff12)
- [ ] 4.3 Add `zone_id`, `zone_boundary` columns to `flood_scenarios.csv`
- [ ] 4.4 Update `lulc_classify_zones.R`: CSV-driven zones, use `dft_rast_zonal()`
- [ ] 4.5 Run `lulc_classify_zones.R` (14 sub-basins × 4 zones × 3 years)
- [ ] 4.6 Validate: zone areas sum ≈ total floodplain per sub-basin
- [ ] 4.7 Commit outputs

---

## Phase 5: Site-Specific Template Maps (1m LiDAR)
**Status:** `pending`
**Purpose:** High-resolution restoration design maps for 2-3 pilot sites (200-1000m of stream)

- [ ] 5.1 Select 2-3 sites from `data/gis/sites_prioritized.geojson` (varied valley types)
- [ ] 5.2 Query stac_dem_bc API — confirm 1m LiDAR coverage at each site
- [ ] 5.3 For each site: snap → extract reach → fetch 1m DEM → run VCA per flood_factor
- [ ] 5.4 Produce template restoration design maps showing nested zones
- [ ] 5.5 Compare 1m vs 25m results at same sites — document resolution effects
- [ ] 5.6 Script naming TBD (consult)

---

## Phase 6: Report Integration
**Status:** `pending`

- [ ] 6.1 Update `2043-Appendix-lulc.Rmd`: zone-stratified summary table + plot
- [ ] 6.2 Update methods (0300): nested scenario approach, CSV-generated scenario table
- [ ] 6.3 Add site-level 1m results as figures/maps
- [ ] 6.4 Add exploitation caveat to recommendations preamble
- [ ] 6.5 Rebuild report, version bump, NEWS.md

---

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| (none yet) | | |

---

## Key Technical Notes

- **VCA bankfull regression:** `h_bf = 0.054 × A^0.170 × P^0.215`
- **Precip critical:** Without `map_upstream`, flood depth underestimated ~4x on Bulkley
- **Stream network:** `streams_co_vw` scoped to coho potential habitat
- **DB tunnel:** localhost:63333 → bcfishpass/fwapg
- **25m DEM:** `/Users/airvine/Projects/repo/bcfishpass/model/habitat_lateral/data/temp/BULK/dem.tif`
- **1m DEM:** stac_dem_bc STAC catalog (query API for coverage)
- **flood_scenarios.csv:** 6 scenarios (co_ff01-co_ff12), all use min_order=3, anchor_order=1
- **Annular rings:** rearing = ff04 - ff02, functional = ff06 - ff04, migration = ff12 - ff06
