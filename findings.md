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
| 2026-01-16 | Results section mixing background, methods, and results | 0400-results.Rmd | Major reorganization needed |

---

## Analysis: Background/Methods/Results Reorganization (2026-01-16)

### The Core Problem

The Results section (0400) currently contains three types of content mixed together:

1. **Literature Review / Background Context** - Summaries of what past reports contain
2. **Methods / Work Description** - How we extracted, digitized, and spatialized historic data
3. **Actual Results / Deliverables** - The extracted datasets, tables, and field findings

### Specific Issues in 0400-results.Rmd

| Section | Current Location | What It Actually Is | Should Be |
|---------|------------------|---------------------|-----------|
| Field Review | Results | ✓ Actual findings | Results |
| GIS Environment table | Results | Deliverable/output | Results (OK) |
| Aerial Imagery table | Results | Deliverable/output | Results (OK) |
| **Historic Info intro paragraph** | Results | Literature review | Background |
| **Morin 2016 summary** | Results | Literature review | Background |
| **Mitchell 1997 summary** | Results | Literature review | Background |
| **Price 2014 summary** | Results | Mixed - lit review + extraction work | Split |
| **Price 2014 waypoints table** | Results | Deliverable | Results |
| **NCFDC 1998 summary** | Results | Mixed - lit review + extraction work | Split |
| **NCFDC prescriptions tables** | Results | Deliverable | Results |
| **Gaboury 2016 summary** | Results | Literature review | Background |
| **SSAF 2021 summary** | Results | Literature review | Background |
| Future Site Selection sections | Results | Mixed methods/results | Split |

### The NCFDC 1998 Work - Key Deliverable (Detailed Analysis)

This work deserves proper documentation because it was significant technical effort involving multiple data extraction pipelines and integration with the BC Freshwater Atlas.

#### Component 1: Prescription Text Extraction
**Script:** `scripts/gis/extract-prescriptions-ncfdc-1998.R`

**Process:**
1. Used `pdftools` to extract raw text from prescription PDF
2. Built complex regex patterns to parse unstructured PDF text into structured fields
3. Extracted 18 fields per prescription: sub-basin, creek, reach, prescription number, category, location, UTM coordinates, land tenure, impact description, goals, master plan objectives, proposed works, technical references, cost estimates, approvals
4. Required manual "hand bombing" to fix coordinate errors (UTM easting/northing reversed in original)
5. Created unique IDs and converted to spatial format (UTM Zone 9 → BC Albers 3005)

**Output:** `ncfdc_1998_prescriptions_cleaned.csv`, `ncfdc_1998_prescriptions_raw` layer

#### Component 2: Riparian Prescription Spatialization
**Script:** `scripts/gis/ncfdc_1998_extract_riparian_presriptions.R`

This was the more complex pipeline:

**Step 1: Georeference PDF Maps**
- Georeferenced appendix PDF maps in QGIS to identify reach break locations
- Created `reach_breaks.csv` with corrected reach names and UTM coordinates
- Loaded georeferenced PDFs to shared QGIS project for reference

**Step 2: Link to BC Freshwater Atlas**
- Used `fwatlasbc::fwa_add_blks_to_stream_name` to match stream names (e.g., "Buck Creek", "Bulkley River") to FWA blueline keys
- Used `fwapgr::fwa_index_point` to get downstream_route_measure for each reach break point

**Step 3: Convert Chainage to Spatial Coordinates**
- Prescriptions in original report used chainage (distance upstream from reach break)
- Calculated absolute downstream_route_measure: `rm_adjusted = chainage + reach_break_rm`
- Special cases required (e.g., Buck 11/12 with different reference points, Bulkley mainstem offset)
- Used `fwapgr::fwa_locate_along(blueline_key, downstream_route_measure)` to get actual spatial coordinates

**Step 4: Join Polygon Descriptions**
- Read riparian polygon descriptions from `AppD_riparian_polygons.xls`
- Joined to prescription locations by polygon ID

**Key Dependencies:**
- `fwapgr` - R wrapper for BC Freshwater Atlas PostgreSQL functions
- `fwapg` - PostgreSQL implementation of FWA spatial queries (Simon Norris)
- `fwatlasbc` - Stream name to blueline key crosswalk

**Output:** `ncfdc_1998_riparian_raw` layer in `sites_restoration.gpkg`

#### Additional Extractions
- Table 71a (sub-basin prioritization summary) - extracted via `tabulapdf`
- Table 73/Appendix H (detailed prioritization matrix) - extracted from Excel

**Current problem:** This work is buried in what reads like a literature review section.

### Proposed Reorganization

#### 1. Background (0200) - ADD New Section

Add **"Historic Restoration Context"** section containing:
- Literature summaries of Morin 2016, Mitchell 1997, Price 2014, NCFDC 1998, Gaboury 2016
- Focus on WHAT these reports contain and their importance
- NO tables of extracted data (those are deliverables)

#### 2. Methods (0300) - ADD New Section

Add **"Historic Data Compilation"** section (under Background Research & Analysis) containing:
- Description of the process for digitizing and spatializing historic data
- PDF extraction methods (tabulapdf)
- Coordinate extraction and conversion to spatial formats
- Linking of tabular data to GIS layers
- Site categorization approach

Also ADD: **"Field Review"** methods section (currently missing!)
- What sites were visited
- Selection criteria
- Assessment approach

#### 3. Results (0400) - RESTRUCTURE

**Keep/Enhance:**
- Field Review (actual findings)
- GIS Environment table
- Aerial Imagery table

**New section: "Historic Data Products"** containing:
- Price 2014 waypoints table (with brief context that it was extracted from PDF)
- NCFDC 1998 prescriptions tables
- NCFDC prioritization tables
- Brief statement about spatial layers created

**Simplify:**
- Future Site Selection → becomes summary of outputs only
- Remove literature review paragraphs (moved to Background)

### Missing: Field Review Methods

Currently 0400 has Field Review results but 0300 has no corresponding methods.

**Need to add to Methods:**
- Site selection criteria (why these ~36 sites?)
- Field assessment protocol
- Data collection approach (forms, photos)
- Categories of sites reviewed:
  - Past NCFDC 1998 prescription sites
  - Wet'suwet'en FN 2016 sites
  - HWI sites
  - Newly proposed sites
  - Fraser erosion sites

**Status:** Site Reviews methods section added (2026-01-16)

---

### Stream Walks - Methods & Results Needed

**Data Location:** `~/Projects/gis/restoration_wedzin_kwa/data_field/2024/form_fiss_site_2024.gpkg`

**Note:** This is a different form type than the monitoring forms, so it is NOT included in the amalgamated `sites_reviewed_2024_202506.geojson`. The stream walks data uses `form_fiss_site` structure rather than `form_monitoring_ree`.

**Purpose of Stream Walks:**
- Understand areas of high-value salmon habitat
- Visit sites where past prescriptions were developed
- Find publicly accessible points for field technicians to connect with Bulkley River mainstem and Buck Creek systems
- Build state of knowledge regarding:
  - Current conditions
  - Ecological values
  - Degradation issues
  - Restoration and conservation potential

**Tasks:**
- [ ] Summarize stream walk start locations from gpkg
- [ ] Add stream walks methods to 0300-methods.Rmd
- [ ] Add stream walks results/summary to 0400-results.Rmd (may already be partially covered)

---

### Site Visit Data - Amalgamated Dataset (2026-01-16)

**Amalgamated Data Location:**
- GIS: `/Users/airvine/Projects/gis/restoration_wedzin_kwa/data_field/sites_reviewed_2024_202506.geojson`
- Repo: `data/gis/sites_reviewed_2024_202506.geojson`

**Script:** `scripts/gis/amalgamate_field_forms.R`

**Source Forms Combined:**
1. `form_monitoring_ree_2024.gpkg` - 2024 monitoring
2. `form_monitoring_ree_20240923.gpkg` - Sept 2024 stream walks
3. `form_fiss_site_fraser_2024.gpkg` - Fraser sites
4. `form_monitoring_ree_2025.gpkg` - 2025 monitoring (June)

**Current State:**
- Appendix 2 ("Potential Restoration Site Review and Effectiveness Monitoring Data - 2024") contains interim version
- **Now out of date** - needs updating with amalgamated file

**Data Structure (26 features total):**

Key fields for categorization:
- `source` - which form file
- `site_id` - site identifier
- `citation_key` - links to historic reports
- `new_site` - yes/null flag
- `works_completed` - yes/null flag

**Preliminary Site Categorization:**

| # | site_id | Date | Source | Category |
|---|---------|------|--------|----------|
| 1-2 | BR1-2021, BR2-2021 | 2024-09 | form_monitoring_ree_2024 | HWI past work |
| 3 | BR04-2016 | 2024-09 | form_monitoring_ree_2024 | HWI/WFN 2016 past work |
| 4 | Meints_01 | 2024-10 | form_monitoring_ree_2024 | New proposed (new_site=yes) |
| 5-6 | Mickilligan Rd Upper/middle | 2024-10 | form_monitoring_ree_2024 | Site reconnaissance |
| 7-9 | bulkley_wilson_01/02/03 | 2024-09 | form_monitoring_ree_20240923 | New proposed (Wilson property, new_site=yes) |
| 10-12 | bulkley_meints_craker_rd_* | 2024-09 | form_monitoring_ree_20240923 | Site reconnaissance (Meints/Craker Rd access) |
| 13-17 | chilako_*, keneth_ds | 2024-10 | form_fiss_site_fraser_2024 | Fraser erosion sites |
| 18 | Foxy Maxan Confluence | 2025-06 | form_monitoring_ree_2025 | New proposed (new_site=yes) |
| 19-23 | buc7, Bul38, bul32, Buc207, Buc172 | 2025-06 | form_monitoring_ree_2025 | NCFDC 1998 prescriptions (citation_key) |
| 24 | MX2 | 2025-06 | form_monitoring_ree_2025 | Maxan reconnaissance |
| 25-26 | MX1, Br5 | 2025-06 | form_monitoring_ree_2025 | Gaboury/Smith completed (works=yes, citation_key) |

**Tasks Needed:**
- [x] Review geojson columns to understand available attributes
- [ ] Confirm/refine site categorization above
- [ ] Add category field to data or document in methods
- [ ] Determine best presentation format for results
- [ ] Update Appendix 2 or move data directly to Results section
- [ ] Ensure methods section documents rationale for each site category

### Site Categories (from 0400 Field Review)

| Category | Count | Notes |
|----------|-------|-------|
| NCFDC 1998 prescription sites | 14 | Past prescriptions |
| Wet'suwet'en FN 2016 sites | 6 | 2 drone-mapped |
| HWI sites | 6 | Past work |
| Newly proposed sites | 7 | Groot fencing, Wilson, Mients; 3 drone-mapped |
| Fraser erosion sites | 3 | Lower Chilako; 2 drone-mapped |

### Implementation Approach

**Option A: Minimal disruption**
- Move literature summaries from 0400 to 0200
- Add Field Review methods to 0300
- Add brief "Historic Data Compilation" methods paragraph
- Keep extracted data tables in 0400 but reframe as "deliverables"

**Option B: Full restructure**
- Create new Background section for historic context
- Create comprehensive methods section for data compilation
- Restructure Results into clear deliverable categories

**Recommendation:** Option A first, iterate toward Option B
