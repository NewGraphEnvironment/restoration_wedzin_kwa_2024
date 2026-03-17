# Progress Log: Multi-Scenario Floodplain Modelling Pipeline

**Issue:** #123
**Branch:** `123-floodplain-refinement`

---

## Session: 2026-03-17 — Plan & Archive

### Completed
- [x] Archived prior planning files to `planning/archive/2026-03-issue-123-floodplain-scenario-modelling/`
- [x] Reviewed current state: scripts, data, upstream packages (flooded, drift, fresh)
- [x] Designed 6-phase plan with decision points
- [x] Decided: `dft_rast_zonal()` goes in drift (not project workaround)
- [x] Decided: 25m DEM first on 1 sub-basin, then 1m LiDAR for 2-3 pilot sites
- [x] Decided: citations in flood_scenarios.csv as semicolon-separated BBT keys
- [x] Created fresh PWF files in planning/active/

### Key Decisions
- Run all 6 VCA scenarios, decide zone boundaries after inspection
- Site-specific 1m LiDAR from stac_dem_bc for template restoration design maps (200-1000m reaches)
- Test pipeline via drift vignette before full watershed run

### Next Steps
- Phase 1: Literature review — Zotero semantic search for scenario rationale
- Phase 2: Build `dft_rast_zonal()` in drift (file issue first)
