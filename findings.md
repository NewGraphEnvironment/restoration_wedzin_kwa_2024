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
- **Citation:** environmentcanada2012Canadianaquatic (Zotero)
- **Sites:** 3 locations in Neexdzii Kwah mainstem
- **Lab:** Cordillera Consulting, Summerland BC
- **Database:** Federal CABIN database

**Rationale:**
- Assess aquatic health through species composition/presence metrics
- Indicates water quality status at different watershed locations
- Does not explain causation if issues found, but flags potential problems
- All sites within known high-value Chinook spawning/rearing habitat

**Site 1 - Upstream of Landfill:**
- Just downstream of Macquarie Creek
- Upstream of Regional District landfill
- Reference/control site for comparing to downstream locations

**Site 2 - Downstream of Landfill:**
- Downstream of McKilligan Road
- Downstream of landfill
- Detects potential landfill impacts on aquatic health

**Site 3 - Downstream of Houston:**
- Downstream of Town of Houston
- ~200m upstream of North Road overpass
- Adjacent to rest/picnic area
- Downstream of Houston sewage treatment plant
- Existing CABIN site (need to find reference ID)
- Detects potential municipal wastewater impacts

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

## Phase 1 Analysis: Current Report Structure

### Executive Summary Table (executive_summary.csv)
Currently 15 rows mixing different types:

**Infrastructure/Tools:**
- Reporting Framework
- Collaborative GIS Mapping Tool
- Code Repository
- UAV Imagery Viewer
- Bibliography

**Methodology References:**
- Historic Imagery workflow
- Land Cover Analysis
- Precipitation Analysis
- State of the Value analysis
- Scripted Prioritization Ranking

**Deliverables:**
- Vegetation Monitoring (iPhone LiDAR)
- Leveraging local Data Hubs

**Already Covered in Methods/Results:**
- GIS, UAV, Historic Info all have sections already

### Current Methods (0300) Structure
1. Collaborative GIS Environment
2. Aerial Imagery (UAV/STAC)
3. Open Source - Iterative Reporting
4. Data Sourcing from SKT
5. Documentation of Workflows
6. Historic Information review
7. Future Restoration Site Selection (5 subsections)

### Current Results (0400) Structure
1. Field Review
2. Collaborative GIS Environment
3. Aerial Imagery
4. Historic Information (5 subsections with detailed summaries)
5. Future Restoration Site Selection (5 subsections)

### Issues Identified
- Methods/Results have parallel structures (some overlap)
- Exec summary table is more "project outputs catalog" than summary
- Missing methods: benthic, eDNA, iPhone LiDAR, time series, climate anomaly
- Results needs: site monitoring data, deliverables summary

---

## Discoveries Log

| Date | Finding | Source | Implications |
|------|---------|--------|--------------|
| 2026-01-15 | Project mapped to SRED iterations 1 & 4 | sred-2025-2026 repo | Document R&D activities |
| 2026-01-15 | Exec summary table mixes methods/tools/deliverables | executive_summary.csv | Need to categorize and relocate |
| 2026-01-15 | Methods/Results have parallel section names | 0300/0400 Rmd | Consider consolidating or clarifying |
| | | | |
