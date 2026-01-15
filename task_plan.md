# Task Plan: Restoration Neexdzii Kwah Report Finalization

**Goal:** Restructure and finalize the restoration report to scientific reporting standards, incorporating all 2024 field work deliverables.

**Status:** `in_progress`
**Created:** 2026-01-15
**SRED Tracking:** Relates to NewGraphEnvironment/sred-2025-2026 (Iterations 1, 4)

---

## Phase 1: Report Restructuring
**Status:** `in_progress`

### 1.1 Executive Summary Updates
- [x] Review current executive summary table structure
- [x] Decision: Keep table for technical tools/workflows; add field work narrative separately

**Field Work Narrative Paragraph (to add):**
- [ ] Benthic invertebrate sampling (3 sites, Neexdzi Kwah mainstem)
- [ ] eDNA sampling (below Bulkley Falls + 1km downstream)
- [ ] Site reviews (as already described in Results)
- [ ] UAV mapping extent
- [ ] Two workshops conducted:
  - Landowners workshop (input on prioritization)
  - Wet'suwet'en community members & leadership workshop (input on prioritization)

**Technical Tools Table:**
- [ ] Rename table caption to "Project Resources & Deliverables" or similar
- [ ] Add time series analysis workflow
- [ ] Add climate anomaly tool
- [ ] Keep existing technical items

**Future improvements (document for later):**
- Condense URLs to anchor text links
- Add internal links to corresponding Methods sections
- Query STAC catalogue to summarize UAV work (number of products, sites mapped, area covered) for exec summary

### 1.2 Methods Section Expansion
- [ ] Restructure `0300-methods.Rmd` to receive content from exec summary
- [ ] Organize by methodology type (field, GIS, lab, remote sensing)

### 1.3 Results Section Expansion
- [ ] Restructure `0400-results.Rmd` to receive content from exec summary
- [ ] Organize by deliverable type

---

## Phase 2: QGIS Project Cleanup & Site Data
**Status:** `pending`

### 2.1 QGIS Review
- [ ] Review comments in `/Users/airvine/Projects/gis/restoration_wedzin_kwa` for errors/omissions
- [ ] Create summary of monitored field sites
- [ ] Export site data for report integration

### 2.2 Add Missing Site Locations
- [ ] Benthic invertebrate sampling sites (3 sites, Neexdzi Kwah mainstem)
- [ ] eDNA sampling sites (below Bulkley Falls + 1km downstream)
- [ ] Verify all sites have proper attributes

---

## Phase 3: Climate & Remote Sensing Documentation
**Status:** `pending`

### 3.1 Climate Anomaly Analysis
- [ ] Verify climate anomaly appendix documents bc_climate_anomaly fork (newgraph branch)
- [ ] Document climate perspective before/during study period
- [ ] Illustrate climate pattern differences within Neexdzi Kwah watershed

### 3.2 Precipitation Patterns
- [ ] Review `../new_graphiti/posts/2024-06-19-precipitation/index.qmd`
- [ ] Document 3D interactive precipitation visualization in report
- [ ] Reference reproducible workflow demonstration

### 3.3 Land Cover Classification
- [ ] Review `../new_graphiti/posts/2024-06-30-land-cover/index.qmd`
- [ ] Document baseline land cover classification proof of concept
- [ ] Add as recommendation for future large-scale change detection

### 3.4 Time Series Documentation
- [ ] Read and understand `../new_graphiti/posts/2026-01-08-stac-ortho-mosaics/index.qmd`
- [ ] Document methodology for time series analysis
- [ ] Add Maxam Creek / Bulkley Lake confluence example to report
- [ ] Create/reference time series figures

### 3.5 Historic Ortho Recommendation
- [ ] Review `../new_graphiti/posts/2024-11-15-bcdata-ortho-historic/index.qmd`
- [ ] Review budget line item in `admin/2025_2026/neexdzi_kwa_budget_options_20251119.xlsx`
- [ ] Write recommendation for purchasing/processing/storing historic ortho datasets
- [ ] Add to Recommendations section

---

## Phase 4: Field Methods Documentation
**Status:** `pending`

### 4.1 Benthic Invertebrate Sampling
- [ ] Document cabin kick methods (cite reynoldson_etal2001CABINcanadian from Zotero)
- [ ] Note 3 sites in Neexdzi Kwah mainstem
- [ ] Reference Cordillera Lab (Summerland) for sample processing
- [ ] Note results upload to federal CABIN database
- [ ] Add methods to `0300-methods.Rmd`
- [ ] Add results/locations to `0400-results.Rmd`

### 4.2 eDNA Sampling
- [ ] Document eDNA sampling methods (user to provide details)
- [ ] Sites: below Bulkley Falls + 1km downstream
- [ ] Add to QGIS project
- [ ] Pull locations into report

---

## Phase 5: UAV & Remote Sensing Methods
**Status:** `pending`

### 5.1 UAV Mapping Methodology
- [ ] Document extensive watershed UAV mapping work
- [ ] Document image processing workflow (ngr functions → orthomosaics)
- [ ] Document STAC collection workflows (stac_uav_bc scripts)
- [ ] Document VM setup: postgres + stac-fastapi-pgstac
- [ ] Document serving via images.a11s.one
- [ ] Reference existing `scripts/gis/uav_process.Rmd`

### 5.2 iPhone LiDAR / 3D Vegetation Monitoring
- [ ] Document innovative vegetation monitoring methodology (iPhone LiDAR → Sketchfab)
- [ ] Add new 3D model to Attachment 1 (Riparian Prescription Example)
- [ ] Consider side-by-side comparison layout (baseline vs +1 growing season)
- [ ] Get Sketchfab embed link for new model

---

## Phase 6: Final Integration & Review
**Status:** `pending`

- [ ] Verify all cross-references work
- [ ] Check citations (especially new ones: reynoldson_etal2001CABINcanadian)
- [ ] Build report and verify rendering
- [ ] Review all figures/tables render correctly
- [ ] Final cleanup of uncommitted changes

---

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| (none yet) | | |

---

## Companion App Coordination
| App | Action | Status |
|-----|--------|--------|
| `restoration_wedzin_kwa_2024_recomendations` | Sync if recommendations change | pending |

**Note:** Shiny app uses `xciter` for citations. Updates require coordination.

---

## Files to Create/Modify
| File | Action | Status |
|------|--------|--------|
| `0050-executive-summary.Rmd` | Simplify, move content | pending |
| `0300-methods.Rmd` | Major expansion | pending |
| `0400-results.Rmd` | Major expansion | pending |
| `0500-recomendations.Rmd` | Add historic ortho, land cover recs | pending |
| `2040-appendix-climate-anomaly.Rmd` | Verify bc_climate_anomaly docs | pending |
| `2080-Attachment_1_riparian_prescription.Rmd` | Add 3D model | pending |
| QGIS project | Add sites, review | pending |

---

## User Input Needed
- [ ] eDNA sampling methods details
- [ ] Sketchfab link for new 3D model
- [ ] Confirmation on benthic site locations
- [ ] Any additional tasks to add
