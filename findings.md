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

## Proposed Methods Section Restructure

**Date:** 2026-01-15
**Status:** Draft for review

### Current Structure (0300-methods.Rmd)
```
## Methods
1. Collaborative GIS Environment
2. Aerial Imagery
3. Open Source - Iterative Reporting
   - Issue and Discussion Tracking
   - Tables and Figures
4. Data Sourcing from Skeena Salmon Data Centre
5. Documentation of Workflows
6. Historic Information Regarding Impacts and Restoration Initiatives
7. Benthic Invertebrate Sampling ← NEW (orphaned, needs proper placement)
8. Future Restoration Site Selection
   - Evaluation of Historic and Current Imagery
   - Fish Passage
   - Local Knowledge for Riparian Area and Erosion Protection Site Selection
   - Delineation of Areas of High Fisheries Values
   - Parameter Ranking to Select Future Restoration Sites
```

**Problems with current structure:**
- No logical grouping (mixes field work, technical infrastructure, analysis)
- "Open Source - Iterative Reporting" is meta/documentation, not a method
- Benthic section added but doesn't fit the flow
- Missing: eDNA, workshops, iPhone LiDAR, time series, climate anomaly

### Proposed Structure

```
## Methods

### Field Assessments
- Site Reviews and Prioritization Visits
- Benthic Invertebrate Sampling ✓
- eDNA Sampling (pending)
- Stakeholder Workshops (pending)
  - Landowner workshop
  - Wet'suwet'en community members & leadership workshop

### Collaborative Data Management
- GIS Environment (Mergin Maps / QGIS)
- Data Sourcing (Skeena Knowledge Trust)
- Open Source Reporting Framework

### Remote Sensing & Imagery
- UAV Mapping and STAC Infrastructure
- iPhone LiDAR Vegetation Monitoring (pending)
- Time Series Analysis (pending)

### Background Research & Analysis
- Historic Information Review
- Climate Anomaly Analysis (→ reference Appendix)
- Future Restoration Site Selection
  - Fish Passage Context
  - Local Knowledge Integration
  - High Fisheries Value Delineation
  - Parameter Ranking Methodology
```

### Rationale for Reorganization
1. **Field Assessments first** - What we actually did in the watershed
2. **Collaborative Data Management** - How we organized and shared information
3. **Remote Sensing & Imagery** - Technical methods for spatial data
4. **Background Research & Analysis** - Desk-based work and site selection logic

### Content to Tighten/Remove
- "Open Source - Iterative Reporting" → condense to 1-2 paragraphs about reproducibility
- "Issue and Discussion Tracking" → likely remove (meta, not methods)
- "Tables and Figures" → likely remove (meta, not methods)
- "Documentation of Workflows" → fold into reporting framework paragraph

### Sections to Add
| Section | Status | Notes |
|---------|--------|-------|
| Benthic Invertebrate Sampling | ✅ Done | Move to Field Assessments |
| eDNA Sampling | ⬜ Pending | Awaiting user details |
| Stakeholder Workshops | ⬜ Pending | Need to document |
| iPhone LiDAR Vegetation Monitoring | ⬜ Pending | |
| Time Series Analysis | ⬜ Pending | Reference new_graphiti post |
| Climate Anomaly Analysis | ⬜ Pending | Reference Appendix 1 |

### Open Source Reporting Section - Decisions
- **Memos table:** Remove - blog posts cover workflows better, will be referenced in relevant sections
- **Issue/Discussion Tracking subsection:** Remove - fold into one sentence with links
- **Tables and Figures subsection:** Remove - too meta
- **Documentation of Workflows subsection:** Remove - memos being dropped
- **R/bookdown references:** Plain text, no hyperlinks (audience isn't R programmers)
- **Final form:** 3 sentences max with links to repo, issues, discussions

**Draft paragraph:**
> This report is produced using open-source tools (R, bookdown) with full version control via git, enabling iterative updates as restoration planning progresses. All code, data, and revision history are publicly accessible in the [project repository](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024), with ongoing tasks tracked via GitHub [issues](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues).

### Version Release Workflow (do after major changes)
1. Add tight summary to `NEWS.md`
2. Bump version number in `index.Rmd` YAML
3. Run build (`scripts/run.R`) - triggers `my_news_to_appendix()` which adds NEWS to changelog appendix
4. Commit docs/ with simple "rebuild book" message
5. Push

**Upstream documentation needed:**
- [ ] Document in `mybookdown-template`
- [ ] Document in `fish_passage_template_reporting`

### Session Info (to address later)
- **Issue #98:** Broken link to session_info.csv (fs::path missing /blob/main/)
- **Question to resolve:** Does `devtools::session_info(to_file = ...)` capture all packages used during build, or just what's loaded at that moment?
- **Decision:** Keep session info - it's pro-level documentation for reproducibility
- **Location:** Stays in appendix, optionally reference from Open Source Reporting paragraph

---

## Maintenance Notes

**CLAUDE.md ↔ PWF Sync:** Review `CLAUDE.md` after completing major PWF milestones to ensure project context stays accurate. These files are interrelated - task progress may change project state described in CLAUDE.md.

---

## Discoveries Log

| Date | Finding | Source | Implications |
|------|---------|--------|--------------|
| 2026-01-15 | Project mapped to SRED iterations 1 & 4 | sred-2025-2026 repo | Document R&D activities |
| 2026-01-15 | Exec summary table mixes methods/tools/deliverables | executive_summary.csv | Need to categorize and relocate |
| 2026-01-15 | Methods/Results have parallel section names | 0300/0400 Rmd | Consider consolidating or clarifying |
| | | | |
