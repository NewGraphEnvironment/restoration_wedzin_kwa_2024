# Findings: Restoration Neexdzii Kwah Report Finalization

**Purpose:** Store research, discoveries, and technical details as work progresses.

---

## Companion Repositories

### Recommendations Shiny App
- **Repo:** `restoration_wedzin_kwa_2024_recomendations`
- **Location:** `/Users/airvine/Projects/repo/restoration_wedzin_kwa_2024_recomendations`
- **Purpose:** Interactive sortable recommendations table linked from main report
- **Note:** Uses `xciter` package (SRED item) for citations in HTML objects
- **Coordination:** Updates to recommendations require syncing both repos

### Climate Anomaly Fork
- **Repo:** `bc_climate_anomaly` (fork of bcgov/bc_climate_anomaly)
- **Branch:** `newgraph`
- **Location:** `/Users/airvine/Projects/repo/bc_climate_anomaly`
- **Purpose:** Climate perspective before/during study; illustrates climate pattern differences within watershed

---

## Reference Materials (new_graphiti posts)

### Precipitation Patterns (2024-06-19)
- **Location:** `../new_graphiti/posts/2024-06-19-precipitation/`
- **Purpose:** 3D interactive precipitation visualization; demonstrates reproducible workflow
- **Status:** Need to document in report

### Land Cover Classification (2024-06-30)
- **Location:** `../new_graphiti/posts/2024-06-30-land-cover/`
- **Purpose:** Proof of concept for baseline land cover classification
- **Future use:** Reference for large-scale change detection over time
- **Status:** Need to add as recommendation

### Historic Ortho Work (2024-11-15)
- **Location:** `../new_graphiti/posts/2024-11-15-bcdata-ortho-historic/`
- **Budget details:** `/Users/airvine/Projects/current/Admin/admin_projects/2024-069-ow-wedzin-kwa-restoration/admin/2025_2026/neexdzi_kwa_budget_options_20251119.xlsx`
- **Status:** Need to review and expand into recommendation

### Time Series Example (2026-01-08)
- **Location:** `../new_graphiti/posts/2026-01-08-stac-ortho-mosaics/`
- **Area:** Maxam Creek near confluence with Bulkley Lake
- **Status:** Need to read and document methodology

---

## Field Methods References

### Benthic Invertebrate Sampling
- **Method:** Cabin kick
- **Citation:** reynoldson_etal2001CABINcanadian (Zotero)
- **Sites:** 3 locations in Neexdzi Kwah mainstem
- **Lab:** Cordillera Lab, Summerland BC
- **Database:** Federal CABIN database

### eDNA Sampling
- **Sites:** Below Bulkley Falls + 1km downstream
- **Methods:** (awaiting user input)

---

## UAV/Remote Sensing Stack

### Processing Pipeline
1. UAV imagery collection (extensive watershed mapping)
2. Processing via ngr functions → orthomosaics
3. STAC collection creation via stac_uav_bc workflows
4. VM with postgres + stac-fastapi-pgstac
5. Served via images.a11s.one

### iPhone LiDAR Vegetation Monitoring
- Tool: iPhone LiDAR
- Output: 3D models on Sketchfab
- Use case: Riparian vegetation monitoring over time
- Current: Attachment 1 has baseline model
- Needed: Add +1 growing season model, side-by-side comparison

---

## GIS Project Details

- **Project:** `/Users/airvine/Projects/gis/restoration_wedzin_kwa`
- **Tasks:** Review comments, add benthic sites, add eDNA sites
- **Export:** Site summary for report deliverables

---

## Report Structure Notes

### Current Chapter Order
- 0050: Executive Summary (needs simplification)
- 0100: Introduction
- 0200: Background
- 0300: Methods (needs major expansion)
- 0400: Results (needs major expansion)
- 0500: Recommendations (add historic ortho rec)
- 2080: Attachment 1 (add 3D model)

### Bookdown Parts
- May need to implement parts structure for organization
- Reference: https://bookdown.org/yihui/bookdown/markdown-extensions-by-bookdown.html#parts

---

## Discoveries Log

| Date | Finding | Source | Implications |
|------|---------|--------|--------------|
| 2026-01-15 | Project mapped to SRED iterations 1 & 4 | sred-2025-2026 repo | Document R&D activities |
| | | | |
