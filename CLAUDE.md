# Restoration Neexdzii Kwah (Upper Bulkley River) 2024

Check `task_plan.md`, `findings.md`, `progress.md` for active task context before starting work.

## Company Vision

**New Graph Environment** - With integrity, using sound science and open communication, we build productive relationships between First Nations, regulators, non-profits, proponents, scientists, and stewardship groups. Our value-added deliverables include open-source, collaborative GIS environments and interactive online reporting.

We are biologists and computer programmers that facilitate aquatic ecosystem restoration with an emphasis on inclusive engagement and knowledge sharing.

## This Repository

Restoration planning report for the Neexdzii Kwah (Upper Bulkley River) watershed, prepared for the Wet'suwet'en Treaty Office Society on behalf of SERN BC.

**Current Version:** DRAFT (see NEWS.md for version tracking)

**Key characteristics:**
- Living document combining ecological science with Wet'suwet'en Indigenous stewardship
- Open-source iterative reporting using R/Markdown and Git version control
- Interactive web-based presentation via bookdown gitbook
- Collaborative GIS data management via Mergin Maps
- Heavy use of interactive elements (maps, tables) - not configured for PDF output

**Build:** `scripts/run.R` orchestrates builds (bookdown gitbook)

**Build Artifacts:** The `docs/` directory contains rendered HTML output. Commits to `docs/` should use simple messages (e.g., "rebuild book") and are NOT linked to issues or SRED tracking - they are just build outputs.

## Companion Repositories

### Recommendations Shiny App
| Repo | Location |
|------|----------|
| `restoration_wedzin_kwa_2024_recomendations` | `/Users/airvine/Projects/repo/restoration_wedzin_kwa_2024_recomendations` |

Interactive shiny app linked from main report containing recommendations as a user-sortable table. Uses `xciter` package (SRED item) for generating citations within HTML objects. **Note:** Updates to recommendations require coordination between main report and this app.

### Climate Analysis
| Repo | Location | Purpose |
|------|----------|---------|
| `bc_climate_anomaly` (fork, newgraph branch) | `/Users/airvine/Projects/repo/bc_climate_anomaly` | Climate perspective before/during study period; illustrates climate pattern differences within Neexdzi Kwah watershed |

Fork of `bcgov/bc_climate_anomaly` with modifications on `newgraph` branch.

### Related Blog Posts (new_graphiti)
| Post | Location | Purpose |
|------|----------|---------|
| `2024-06-19-precipitation` | `/Users/airvine/Projects/repo/new_graphiti/posts/2024-06-19-precipitation` | 3D interactive precipitation patterns; demonstrates reproducible workflow |
| `2024-06-30-land-cover` | `/Users/airvine/Projects/repo/new_graphiti/posts/2024-06-30-land-cover` | Proof of concept for baseline land cover classification; reference for future large-scale change detection |
| `2024-11-15-bcdata-ortho-historic` | `/Users/airvine/Projects/repo/new_graphiti/posts/2024-11-15-bcdata-ortho-historic` | Historic orthophoto processing workflow |
| `2026-01-08-stac-ortho-mosaics` | `/Users/airvine/Projects/repo/new_graphiti/posts/2026-01-08-stac-ortho-mosaics` | Time series analysis example (Maxam Creek / Bulkley Lake) |

## Repository Ecosystem

### Core Templates
| Repo | Purpose |
|------|---------|
| `mybookdown-template` | General bookdown template - upstream base |
| `fish_passage_template_reporting` | Fish passage report template (sibling pattern) |

### R Packages (Internal)
| Repo | Purpose |
|------|---------|
| `fpr` | Fish passage R functions |
| `ngr` | New Graph R utilities |
| `rfp` | R functions for proposals/reporting |
| `xciter` | Citation management |

### Supporting Infrastructure
| Repo | Purpose |
|------|---------|
| `dff-2022` | Shared scripts (`/scripts`) for data processing |
| `db_newgraph` | Database management |
| `compost` | Communications workflow templates |

### STAC Ecosystem (Spatial Data)
| Repo | Purpose |
|------|---------|
| `stac_dem_bc` | Digital elevation models |
| `stac_orthophoto_bc` | Orthophotos |
| `stac_uav_bc` | UAV/drone imagery |

## External Dependencies

### Hillcrest Geographics / BC Data
| Repo | Purpose |
|------|---------|
| `smnorris/bcfishpass` | Fish passage modeling, habitat estimates |
| `smnorris/fwapg` | BC Freshwater Atlas PostgreSQL tools |
| `smnorris/bcfishobs` | BC fish observations data |
| `bcgov/bcdata_py` | Python access to BC Data Catalogue |

### Data APIs
| Source | Purpose |
|--------|---------|
| Skeena Knowledge Trust | CKAN API at data.skeenasalmon.info - riparian assessments, fish habitat, water quality |
| BC Data Catalogue | Provincial spatial data layers |
| DFO NuSEDS | Salmon escapement database |
| ECCC Hydrometric | tidyhydat access to flow data |

## GIS/Mergin Ecosystem

Primary GIS project for field data collection and collaborative mapping:

| GIS Project | Location |
|-------------|----------|
| `restoration_wedzin_kwa` | `/Users/airvine/Projects/gis/restoration_wedzin_kwa` |

**Workflow:** Mergin Maps for mobile/desktop sync, QGIS for analysis, scripts in `scripts/gis/` for processing.

## SRED Tracking Framework

R&D activities tracked in `sred-2025-2026` repository.

**Project Code:** 2024-069-ow-wedzin-kwa-restoration

**Iterations:**
- **Iteration 1:** Dynamic GIS-RMarkdown Synchronization - core reporting infrastructure
- **Iteration 4:** Field-to-Cloud Data Workflows - data ingestion and processing

**Pattern:**
1. Use planning-with-files for complex tasks
2. Add SRED tracking section to planning files when R&D work occurs
3. Create/link issues in `sred-2025-2026`
4. Cross-reference commits with: `Relates to NewGraphEnvironment/sred-2025-2026#<issue>`

## Report Structure

**Chapter ordering (by prefix):**
- 0050: Executive Summary
- 0100: Introduction (Wet'suwet'en context, project scope)
- 0200: Background (location, hydrology, fisheries, land use)
- 0300: Methods (GIS, imagery, monitoring, data management)
- 0400: Results (field review, GIS layers, data tables)
- 0500: Recommendations (strategic restoration actions)
- 2000: References
- 2040-2100: Appendices (climate anomaly, monitoring, ESI, site priority, etc.)

## Key Data Sources

| Source | Location | Purpose |
|--------|----------|---------|
| SKT API downloads | `data/skt/` | Riparian assessments, fish habitat, water quality |
| DFO NuSEDS | `data/inputs_raw/` | Salmon escapement data |
| NCFDC 1998 | `data/inputs_raw/ncfdc_1998/` | Historic restoration prescriptions |
| Field reviews 2024 | `data/gis/` | Site assessments via Mergin |
| Prioritization | `data/gis/sites_prioritized.geojson` | Weighted criteria ranking |
| UAV imagery | STAC catalog / S3 | Orthomosaics, DSMs, DTMs |

## Key Scripts

| Script | Purpose |
|--------|---------|
| `scripts/run.R` | Master build script |
| `scripts/packages.R` | Package dependencies |
| `scripts/functions.R` | Custom utility functions |
| `scripts/api_skt.R` | Skeena Knowledge Trust API access |
| `scripts/forms_amalgamate.R` | Combine field survey forms |
| `scripts/gis/prioritize.R` | Site prioritization algorithm |
| `scripts/gis/uav_process.Rmd` | UAV imagery → STAC pipeline |

## Current Challenges / Evolution Opportunities

- Review and update all chapters for completeness
- Validate cross-references and citations
- Streamline GIS ↔ reporting integration
- Form data backup synchronization
- Document R&D activities for SRED tracking
