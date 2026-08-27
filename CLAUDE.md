# Restoration Neexdzii Kwah (Upper Bulkley River) 2024

Check `task_plan.md`, `findings.md`, `progress.md` for active task context before starting work.

## Company Vision

**New Graph Environment** - With integrity, using sound science and open communication, we build productive relationships between First Nations, regulators, non-profits, proponents, scientists, and stewardship groups. Our value-added deliverables include open-source, collaborative GIS environments and interactive online reporting.

We are biologists and computer programmers that facilitate aquatic ecosystem restoration with an emphasis on inclusive engagement and knowledge sharing.

## This Repository

Restoration planning report for the Neexdzii Kwah (Upper Bulkley River) watershed, prepared for the Wet'suwet'en Treaty Office Society on behalf of SERN BC.

**Current Version:** v0.3.0 DRAFT (see NEWS.md for version tracking)

**Key characteristics:**
- Living document combining ecological science with Wet'suwet'en Indigenous stewardship
- Open-source iterative reporting using R/Markdown and Git version control
- Interactive web-based presentation via bookdown gitbook
- Collaborative GIS data management via Mergin Maps
- Heavy use of interactive elements (maps, tables) - not configured for PDF output

**Build:** `scripts/run.R` orchestrates builds. It renders the bookdown gitbook (`docs/`) **and** the standalone executive summary PDF (`docs/executive_summary.pdf`) in one run — the exec summary is rebuilt at the same time as the main report. Must use `run.R` — not direct `bookdown::render_book()` — because it calls `staticimports::import()` and `source('scripts/staticimports.R')` first. Without this, `my_tab_caption()` and `my_dt_table()` are undefined.

**Build Artifacts:** The `docs/` directory contains rendered HTML output. Commits to `docs/` should use simple messages (e.g., "rebuild book v0.1.3") and are NOT linked to issues - they are just build outputs.

**Versioning:** Manual — no fledge. For each content change: bump `Version:` in `DESCRIPTION` (the report title block reads it via `desc::desc_get_version()`), add a matching dated section to `NEWS.md` by hand, and run a full build (`scripts/run.R`) so the rendered gitbook and the standalone executive summary PDF carry the new version. Version cadence increments the patch digit during `0.2.x` development (e.g. `0.2.9` → `0.2.10`). NEWS.md is linked from the Open Source Reporting section in methods (changelog appendix removed in v0.1.3).

## Companion Repositories

### Recommendations Shiny App
| Repo | Location |
|------|----------|
| `restoration_wedzin_kwa_2024_recomendations` | `~/Projects/repo/restoration_wedzin_kwa_2024_recomendations` |

Interactive shiny app linked from main report containing recommendations as a user-sortable table. Uses `xciter` package for generating citations within HTML objects. **Note:** Updates to recommendations require coordination between main report and this app.

### Climate Analysis
| Repo | Location | Purpose |
|------|----------|---------|
| `bc_climate_anomaly` (fork, newgraph branch) | `~/Projects/repo/bc_climate_anomaly` | Climate perspective before/during study period; illustrates climate pattern differences within Neexdzi Kwah watershed |

Fork of `bcgov/bc_climate_anomaly` with modifications on `newgraph` branch.

### Related Blog Posts (new_graphiti)
| Post | Location | Purpose |
|------|----------|---------|
| `2024-06-19-precipitation` | `~/Projects/repo/new_graphiti/posts/2024-06-19-precipitation` | 3D interactive precipitation patterns; demonstrates reproducible workflow |
| `2024-06-30-land-cover` | `~/Projects/repo/new_graphiti/posts/2024-06-30-land-cover` | Proof of concept for baseline land cover classification; reference for future large-scale change detection |
| `2024-11-15-bcdata-ortho-historic` | `~/Projects/repo/new_graphiti/posts/2024-11-15-bcdata-ortho-historic` | Historic orthophoto processing workflow |
| `2026-01-08-stac-ortho-mosaics` | `~/Projects/repo/new_graphiti/posts/2026-01-08-stac-ortho-mosaics` | Time series analysis example (Maxam Creek / Bulkley Lake) |

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
| `drift` | STAC land cover fetch, classification, multi-temporal change analysis |
| `flooded` | Floodplain delineation from DEMs and stream networks |
| `gq` | Cartographic style registry (QGIS ↔ tmap ↔ mapgl) |

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
| `restoration_wedzin_kwa` | `~/Projects/gis/restoration_wedzin_kwa` |

**Workflow:** Mergin Maps for mobile/desktop sync, QGIS for analysis, scripts in `scripts/gis/` for processing.

## Slash Command Configuration

Project-specific values for global slash commands (in `~/.claude/commands/`).
Internal-only values (SRED references, tracking issue numbers) live in the
gitignored `.claude/project-config.local.md` — read that file when running
`/commit-sred`, `/mergin-sync`, or `/push-pr`.

### Repository
| Key | Value |
|-----|-------|
| Repo | `NewGraphEnvironment/restoration_wedzin_kwa_2024` |
| Co-Author | `Claude Opus 4.6 <noreply@anthropic.com>` |

### Mergin Sync (`/mergin-sync`)
| Key | Value |
|-----|-------|
| GIS Project Path | `~/Projects/gis/restoration_wedzin_kwa` |
| Conda Environment | `dff2` |

### Build (`/push-pr`)
| Key | Value |
|-----|-------|
| Build Script | `scripts/run.R` |
| Test Plan | Report builds, no rendering errors, cross-refs resolve |

## Report Structure

**Chapter ordering (by prefix):**
- 0050: Executive Summary
- 0100: Introduction (Wet'suwet'en context, project scope)
- 0200: Background (location, hydrology, fisheries, land use)
- 0300: Methods (GIS, imagery, monitoring, data management)
- 0400: Results (field review, GIS layers, data tables)
- 0500: Recommendations (strategic restoration actions)
- 2000: References
- 2040: Appendix - Climate Anomaly
- 2043: Appendix - LULC Sub-Basin Analysis (drift/flooded pipeline, floodplain land cover change)
- 2045: Appendix - Fish Species (table moved from background in v0.1.5)
- 2050: Appendix - Monitoring
- 2060-2100: Appendices (ESI, site priority, etc.)

## Key Data Sources

| Source | Location | Purpose |
|--------|----------|---------|
| SKT API downloads | `data/skt/` | Riparian assessments, fish habitat, water quality |
| DFO NuSEDS | `data/inputs_raw/` | Salmon escapement data |
| NCFDC 1998 | `data/inputs_raw/ncfdc_1998/` | Historic restoration prescriptions |
| Field reviews 2024 | `data/gis/` | Site assessments via Mergin |
| Prioritization | `data/gis/sites_prioritized.geojson` | Weighted criteria ranking |
| UAV imagery | STAC catalog / S3 | Orthomosaics, DSMs, DTMs |
| LULC sub-basins | `data/lulc/subbasins.gpkg` | Sub-basin geometries (EPSG:3005, `st_transform(4326)` on load) |
| LULC floodplain AOI | `data/lulc/floodplain_neexdzii_co.gpkg` | Modelled floodplain extent for land cover analysis |
| Spatial layer cache | `data/spatial/*.rds` | Cached streams, lakes, roads, railway for maps |
| Seed collection | `data/seed_collection_data.xlsx` | Seed the North stored inventory (lot, species, coords, weight, purity) |

## Key Scripts

### Floodplain Land Cover Change Pipeline

See `scripts/floodplain_lcc/README.md` for full documentation.

| Script | Tool | Purpose |
|--------|------|---------|
| `scripts/floodplain_lcc/01_network_extract.R` | fresh | Coho-accessible stream network → `aquatic_network.gpkg` |
| `scripts/floodplain_lcc/02_floodplain_model.R` | flooded | VCA scenarios → `floodplain.gpkg` (multi-layer) |
| `scripts/floodplain_lcc/03_lulc_classify.R` | drift | Land cover classification → `floodplain_landcover.gpkg` + `lulc_summary.rds` |
| `scripts/floodplain_lcc/04_lulc_zones.R` | drift | Zone-stratified LULC (future) |
| `scripts/floodplain_lcc/05_prioritization_score.R` | — | Sub-basin scoring |

CSV controls in `data/lulc/`: `flood_scenarios.csv` (`run=TRUE` rows executed) and `break_points.csv`. Habitat/fresh parameter CSVs (`parameters_habitat_thresholds.csv`, `parameters_fresh.csv`) are read from the `fresh` package (`system.file("extdata", ..., package = "fresh")`, vendored from bcfishpass `example_newgraph`) — not project-local. DEM is fetched from the national MRDEM-30 via `flooded::fl_dem_aoi()`; the pipeline connects to a local fwapg DB via standard libpq env vars.

### Other Scripts

| Script | Purpose |
|--------|---------|
| `scripts/run.R` | Master build script |
| `scripts/packages.R` | Package dependencies |
| `scripts/functions.R` | Custom utility functions |
| `scripts/preview.R` | Chapter preview helper |
| `scripts/rag_build.R` | Build ragnar DuckDB store from Zotero PDFs |
| `scripts/api_skt.R` | Skeena Knowledge Trust API access |
| `scripts/gis/amalgamate_field_forms.R` | Combine field survey forms |
| `scripts/gis/prioritize.R` | Site prioritization algorithm |
| `scripts/gis/uav_process.Rmd` | UAV imagery → STAC pipeline |
| `scripts/map_study-area-interactive.R` | Interactive mapgl study area map with Esri/OpenTopoMap basemaps |
| `scripts/fwa_query.R` | FWA upstream fish observation queries (Bulkley Falls, Buck Falls) |

## Current Challenges / Evolution Opportunities

- Review and update all chapters for completeness
- Validate cross-references and citations
- Streamline GIS ↔ reporting integration (gq basemap extraction: [gq#13](https://github.com/NewGraphEnvironment/gq/issues/13))
- Form data backup synchronization
- Package citations: append `knitr::write_bib()` output to `references.bib` after rbbt writes it ([soul#27](https://github.com/NewGraphEnvironment/soul/issues/27), not yet implemented)
- LULC: Agriculture superclass = Crops + Rangeland + Bare Ground (10m IO LULC can't distinguish reliably)

<!-- BEGIN SOUL CONVENTIONS — DO NOT EDIT BELOW THIS LINE -->


# Bookdown Conventions

Standards for bookdown report projects across New Graph Environment.

## Template Repos

These are the canonical references. Child repos inherit their structure and patterns.

- [mybookdown-template](https://github.com/NewGraphEnvironment/mybookdown-template) — General-purpose bookdown starter
- [fish_passage_template_reporting](https://github.com/NewGraphEnvironment/fish_passage_template_reporting) — Fish passage reporting template

When in doubt, match what the template does. When the template and production repos disagree, production wins — update the template.

## Project Structure

```
project/
├── index.Rmd                # Master config, YAML params, setup chunks
├── _bookdown.yml            # book_filename, output_dir: "docs"
├── _output.yml              # Gitbook, pagedown, pdf_book config
├── 0100-intro.Rmd           # Chapter numbering: 4-digit, 100s increment
├── 0200-background.Rmd
├── 0300-methods.Rmd
├── 0400-results.Rmd
├── 0500-*.Rmd               # Discussion/recommendations
├── 0800-appendix-*.Rmd      # Appendices (site-specific in fish passage)
├── 2000-references.Rmd      # Auto-generated from .bib
├── 2090-report-change-log.Rmd  # Auto-generated from NEWS.md
├── 2100-session-info.Rmd    # Reproducibility
├── NEWS.md                  # Changelog (semantic versioning)
├── scripts/
│   ├── packages.R           # Package loading (renv-managed)
│   ├── functions.R          # Project-specific functions
│   ├── staticimports.R      # Auto-generated from staticimports pkg
│   ├── setup_docs.R         # Build helper
│   └── run.R                # Local build (gitbook + PDF)
├── fig/                     # Figures (organized by chapter or type)
├── data/                    # Project data
├── docs/                    # Rendered output (GitHub Pages)
├── renv.lock                # Locked dependencies
└── .Rprofile                # Activates renv
```

## Setup Chunk Pattern

Every `index.Rmd` follows this setup sequence. Order matters.

```r
# 1. Gitbook vs PDF switch
gitbook_on <- TRUE

# 2. Knitr options
knitr::opts_chunk$set(
  echo = identical(gitbook_on, TRUE),  # Show code only in gitbook
  message = FALSE, warning = FALSE,
  dpi = 60, out.width = "100%"
)
options(scipen = 999)
options(knitr.kable.NA = '--')
options(knitr.kable.NAN = '--')

# 3. Source in order: packages → static imports → functions → data
source('scripts/packages.R')
source('scripts/staticimports.R')
source('scripts/functions.R')
```

Responsive settings by output format:

```r
# Gitbook
photo_width <- "100%"; font_set <- 11

# PDF (paged.js)
photo_width <- "80%"; font_set <- 9
```

## YAML Parameters

Parameters live in `index.Rmd` frontmatter (not a separate file). Child repos override by editing these values.

```yaml
params:
  repo_url: 'https://github.com/NewGraphEnvironment/repo_name'
  report_url: 'https://www.newgraphenvironment.com/repo_name/'
  update_packages: FALSE
  update_bib: TRUE
  gitbook_on: TRUE
```

Fish passage repos add project-specific params (`project_region`, `model_species`, `wsg_code`, update flags for forms). These are project-specific — don't add them to the general template.

## Chunk Naming

Embed context and purpose in chunk names. The principle is universal; the codes are project-specific.

**Pattern:** `{type}-{system}-{description}`

| Type | Examples |
|------|---------|
| Tables | `tab-kln-load-int-yr`, `tab-sites-sum`, `tab-wshd-196332` |
| Figures | `plot-wq-kln-quadratic`, `map-interactive`, `map-196332` |
| Photos | `photo-196332-01`, `photo-196332-d01` (dual layout) |

## Cross-References

Bookdown auto-prepends `fig:` or `tab:` to chunk names.

- **Tables:** `Table \@ref(tab:chunk-name)`
- **Figures:** `Figure \@ref(fig:chunk-name)`

No `fig:` or `tab:` prefix in the chunk label itself — bookdown adds it.

## Table Caption Workaround

Interactive tables (DT) can't use standard bookdown captions. Use the `my_tab_caption()` function from `staticimports.R`.

**Pattern:** Separate `-cap` chunk from table chunk.

```r
# Caption chunk — must use results="asis"
{r tab-sites-sum-cap, results="asis"}
my_caption <- "Summary of fish passage assessment procedures."
my_tab_caption()
```

```r
# Table chunk — renders the DT
{r tab-sites-sum}
data |> my_dt_table(page_length = 20, cols_freeze_left = 0)
```

`my_tab_caption()` auto-grabs the chunk label via `knitr::opts_current$get()$label` and wraps it in HTML caption tags that bookdown can cross-reference.

## Photo Layout

Separate prep chunk (find the file) from display chunk (render it).

```r
# Prep — find the photo
{r photo-196332-01-prep}
my_photo1 <- fpr::fpr_photo_pull_by_str(str_to_pull = 'ds_typical_1_')
my_caption1 <- paste0('Typical habitat downstream of PSCIS crossing ', my_site, '.')
```

```r
# Gitbook — full width
{r photo-196332-01, fig.cap=my_caption1, out.width=photo_width, eval=gitbook_on}
knitr::include_graphics(my_photo1)
```

```r
# PDF — side by side with 1% spacer
{r photo-196332-d01, fig.show="hold", out.width=c("49.5%","1%","49.5%"), eval=identical(gitbook_on, FALSE)}
knitr::include_graphics(my_photo1)
knitr::include_graphics("fig/pixel.png")
knitr::include_graphics(my_photo2)
```

## Bibliography

**`references.bib` is auto-generated — never edit it manually.** On each build, `rbbt::bbt_write_bib()` scans all `.Rmd` files for `@citekey` references, pulls the BibTeX from Zotero's Better BibTeX, and overwrites `references.bib`. Any manual additions will be lost on the next build.

To add a reference: add it to the shared Zotero group library, use its BBT citation key (`@key`) in the `.Rmd` text, and build. rbbt handles the rest.

```yaml
bibliography: "`r rbbt::bbt_write_bib('references.bib', overwrite = TRUE)`"
biblio-style: apalike
link-citations: no
```

When `update_bib: FALSE` in params, the build uses the existing `references.bib` without regenerating — useful for offline builds or CI where Zotero isn't running.

Auto-generate package citations:

```r
knitr::write_bib(c(.packages(), 'bookdown', 'knitr', 'rmarkdown'), 'packages.bib')
```

Use `nocite:` in YAML to include references not cited in text.

## Acknowledgement & AI Disclosure

`index.Rmd` contains two separate front-matter sections after the setup chunks:

### Acknowledgement {.front-matter .unnumbered}

Three parts, in order:

1. **Personal connection to land** (template-level, same across all reports):
   > At New Graph Environment, we understand our well-being as inseparable from the health of the land and waters we work within. When we care for ecosystems, we care for ourselves and for the communities connected to them. This relationship is not metaphorical — it is the foundation of our practice.

2. **Colonial acknowledgement** (template-level):
   > Modern civilization has a long journey ahead to acknowledge and address the historic and ongoing impacts of colonialism...

3. **Territorial acknowledgement** (project-specific, must be edited per report): Name the Nations, governance systems, watersheds, and species relevant to the project. Do not use a generic office-location acknowledgement — tie it to the territory where the work happens. See the Wedzin Kwa chinook example for the pattern.

4. **Funding and partners** (project-specific).

### AI Disclosure

Do not use a `#` heading for the disclosure — this creates a separate chapter page in gitbook. Instead, add it to the YAML `date:` field so it renders in the title block:

```yaml
date: |
 |
 | Version X.X.X DRAFT `r format(Sys.Date(), "%Y-%m-%d")`
 |
 | *Claude Sonnet 4.6 (Anthropic) assisted with literature synthesis, drafting, and technical writing. All scientific interpretation, data analysis, and conclusions are the responsibility of the authors.*
```

**Wording principle:** Be accurate about what the LLM did. It assisted with drafting and synthesis — it did not make scientific interpretations or conclusions. Do not say "independently verified by the authors" (redundant) or attribute "ecological assessments" to the LLM.

For regulatory/EGBC-stamped work, use the extended disclaimer from `soul/research/20260212_ai_disclosure_research.md`. See NewGraphEnvironment/mybookdown-template#89.

## Conditional Rendering (Gitbook vs PDF)

A single boolean `gitbook_on` controls output format throughout.

```r
# Show only in gitbook
{r map-interactive, eval=gitbook_on}

# Show only in PDF
{r fig-print-only, eval=identical(gitbook_on, FALSE)}

# Conditional inline content
`r if(identical(gitbook_on, FALSE)) knitr::asis_output("This report is available online...")`

# Page breaks for PDF only
`r if(gitbook_on){knitr::asis_output("")} else knitr::asis_output("\\pagebreak")`
```

## PDF Build (pagedown)

Two patterns recur across every fish_passage report's PDF build path. Both are non-obvious; the second is a months-of-confusion gotcha worth memorizing.

### Heavy-appendix swap + size compaction

The Phase 1 appendix (`0600-appendix.Rmd`) is built **standalone** and distributed as a separate PDF (`docs/Appendix_1.pdf`). It does not belong in the body PDF.

**Body PDF build (pull 0600 out, render, swap back, then compact):**

```r
# 1. Pull heavy appendix out of the build set
if (fs::file_exists("hold/0600-appendix.Rmd")) {
  fs::file_move("hold/0600-appendix.Rmd", "0600-appendix.Rmd")
}
file.rename("0600-appendix.Rmd", "hold/0600-appendix.Rmd")

# 2. Render body PDF (see envir gotcha below)
bookdown::render_book(
  input         = "index.Rmd",
  output_format = "pagedown::html_paged",
  encoding      = "UTF-8",
  envir         = globalenv()
)

# 3. Swap 0600 back in
file.rename("hold/0600-appendix.Rmd", "0600-appendix.Rmd")

# 4. Chrome-print HTML to PDF
filename_html <- basename(params$repo_url)
pagedown::chrome_print(
  paste0(filename_html, ".html"),
  output  = paste0("docs/", filename_html, ".pdf"),
  timeout = 300
)

# 5. Compact via Ghostscript (size matters — repos hit GitHub file-size caps)
tools::compactPDF(
  paste0("docs/", filename_html, ".pdf"),
  gs_quality = "ebook",
  gs_cmd     = "/opt/homebrew/bin/gs",
  verbose    = TRUE
)

# 6. Delete the intermediate HTML — too big to commit
file.remove(paste0(filename_html, ".html"))
```

**Phase 1 appendix standalone build (the inverse swap):**

```r
filename_html <- basename(params$repo_url)

# Move EVERYTHING EXCEPT index, the book file, and 0600 to hold/
files_to_move <- list.files(pattern = ".Rmd$") |>
  stringr::str_subset(paste0("index|", filename_html, "|0600"), negate = TRUE)
files_destination <- paste0("hold/", files_to_move)
mapply(file.rename, from = files_to_move, to = files_destination)

# Render
bookdown::render_book(
  input         = "index.Rmd",
  output_format = "pagedown::html_paged",
  encoding      = "UTF-8",
  envir         = globalenv()
)

# Restore
mapply(file.rename, from = files_destination, to = files_to_move)

# Print, crop leading non-content pages (count varies by repo — 8 is typical)
pagedown::chrome_print(paste0(filename_html, ".html"),
                       output = "docs/Appendix_1_prep.pdf", timeout = 120)
n <- pdftools::pdf_length("docs/Appendix_1_prep.pdf")
crop <- 8
pdftools::pdf_subset("docs/Appendix_1_prep.pdf",
                     pages  = (crop + 1):(n - 1),
                     output = "docs/Appendix_1.pdf")
file.remove("docs/Appendix_1_prep.pdf")

# Compact (mandatory for the Phase 1 PDF — uncompacted is too big for git)
tools::compactPDF("docs/Appendix_1.pdf",
                  gs_quality = "ebook",
                  gs_cmd     = "/opt/homebrew/bin/gs",
                  verbose    = TRUE)
```

`gs_quality = "ebook"` typically yields 3–5× compression with no visible loss for assessment-photo content. Requires ghostscript installed (`brew install ghostscript`). The `gs_cmd` path is macOS-specific — Linux/CI will pick up `gs` from `$PATH` and can omit the arg.

### Fresh-Rscript scoping gotcha — use `render_book(envir = globalenv())`

**When building PDFs from a fresh Rscript process (CI, iter scripts, anything non-warmed), use `bookdown::render_book(..., envir = globalenv())`. NOT `rmarkdown::render_site(output_format = 'pagedown::html_paged')`.**

```r
bookdown::render_book(
  input         = "index.Rmd",
  output_format = "pagedown::html_paged",
  encoding      = "UTF-8",
  envir         = globalenv()
)
```

**Symptom of the wrong call:** cascading `object not found` errors at chunks that rely on lazy defaults — `font_set` (in `fpr::fpr_kable(font = font_set)`), `my_caption` (in `my_tab_caption()`), and similar. Often appears 80–100 chunks into the build, after a long warm-up that masks the root cause.

**Why:** `rmarkdown::render_site` evaluates chunks in a knit env that is a *sibling* of `globalenv()` (parent = globalenv, but not == globalenv). Helpers sourced into globalenv via the `source()` chunk (`fpr::fpr_kable`, `my_tab_caption`, etc.) resolve lazy-default args via R's closure chain — they look up names through their enclosing env (globalenv) but never see knit_env where the chunks actually assigned `my_caption <- "..."`. The interactive `scripts/run.R` flow accidentally works because the user's prior session activity has already warmed globalenv with the same names. `bookdown::render_book(envir = globalenv())` forces knit_env to *be* globalenv, so chunk-assigned vars and source()-d helpers share a lookup chain.

**Pre-seed PDF-mode globals before the render call** so chunks that use them via lazy defaults in the first ~10 chunks don't race the `settings-paged-html` chunk:

```r
font_set    <<- 9
photo_width <<- "80%"
gitbook_on  <<- FALSE
```

**Do not pre-bind `params`** — `bookdown::render_book` injects params from YAML and trips on "params object already exists in knit environment". Let bookdown handle it.

See `scripts/run_pagedown_iter.R` in any fish_passage repo for the working iter pattern, with crash-safe `on.exit` restoration of `gitbook_on` toggling and 0600 swap-back.

## Versioning and Changelog

Reports use MAJOR.MINOR.PATCH versioning with a `NEWS.md` changelog.

**Version in `index.Rmd` YAML:**
```yaml
date: |
 |
 | Version 1.1.0 DRAFT `r format(Sys.Date(), "%Y-%m-%d")`
```

**NEWS.md format:**
```markdown
## 1.1.0 (2026-02-17)

- Add feature X
- Fix issue Y ([Issue #N](https://github.com/Org/repo/issues/N))
```

**Auto-append as appendix** via `my_news_to_appendix()` in `staticimports.R`:
```r
news_to_appendix(md_name = "NEWS.md", rmd_name = "2090-report-change-log.Rmd")
```

**Convention:**
- Bump version in `index.Rmd` and add NEWS entry for every commit to main that changes report content
- Tag releases: `git tag -a v1.1.0 -m "v1.1.0: Brief description"`
- MAJOR: structural changes, new chapters, methodology changes
- MINOR: new content, figures, tables, discussion sections
- PATCH: prose fixes, corrections, formatting

## COG Viewer Embedding

Always use `ngr::ngr_str_viewer_cog()` — never hardcode viewer iframes.

```r
knitr::asis_output(ngr::ngr_str_viewer_cog("https://bucket.s3.us-west-2.amazonaws.com/ortho.tif"))
```

The function includes a cache-busting `?v=` parameter. Bump `v` in the function default when `viewer.html` has breaking changes.

## Dependency Management

Use `renv` for reproducible package management:
- `.Rprofile` activates renv on startup
- `renv::restore()` installs from lockfile
- `renv::snapshot()` updates lockfile after adding packages
- Use `pak::pak("pkg")` to install (not `install.packages`)

## Known Drift

Production repos (2024-2025) have drifted from templates in these areas. When working in a child repo, match what that repo does, not the template:

- **Script naming in `02_reporting/`** — older repos use `tables.R`, `0165-read-sqlite.R`; newer repos use numbered `0130-tables.R`. Follow the repo you're in.
- **Removed packages** — `elevatr`, `rayshader`, `arrow` removed from production but still in template.
- **`staticimports::import()` call** — some repos skip it and source `staticimports.R` directly.
- **Hardcoded vs parameterized years** — older repos hardcode years in file paths; newer repos use `params$project_year`. Prefer parameterized.


# Cartography

## Style Registry

Use the `gq` package for all shared layer symbology. Never hardcode hex color values when a registry style exists.

```r
library(gq)
reg <- gq_reg_main()  # load once per script — 51+ layers
```

**Core pattern:** `reg$layers$lake`, `reg$layers$road`, `reg$layers$bec_zone`, etc.

### Translators

| Target | Simple layer | Classified layer |
|--------|-------------|-----------------|
| tmap | `gq_tmap_style(layer)` → `do.call(tm_polygons, ...)` | `gq_tmap_classes(layer)` → field, values, labels |
| mapgl | `gq_mapgl_style(layer)` → paint properties | `gq_mapgl_classes(layer)` → match expression |

### Custom styles

For project-specific layers not in the main registry, use a hand-curated CSV and merge:

```r
reg <- gq_reg_merge(gq_reg_main(), gq_reg_read_csv("path/to/custom.csv"))
```

Install: `pak::pak("NewGraphEnvironment/gq")`

## Map Targets

| Output | Tool | When |
|--------|------|------|
| PDF / print figures | `tmap` v4 | Bookdown PDF, static reports |
| Interactive HTML | `mapgl` (MapLibre GL) | Bookdown gitbook, memos, web pages |
| QGIS project | Native QML | Field work, Mergin Maps |

## Key Rules

- **`sf_use_s2(FALSE)`** at top of every mapping script
- **Compute area BEFORE simplify** in SQL
- **No map title** — title belongs in the report caption
- **Legend over least-important terrain** — swap legend and logo sides when it reduces AOI occlusion. No fixed convention for which side.
- **Four-corner rule** — legend, logo, scale bar, keymap each get their own corner. Never stack two in the same quadrant.
- **Bbox must match canvas aspect ratio** — compute the ratio from geographic extents and page dimensions. Mismatch causes white space bands.
- **Consistent element-to-frame spacing** — all inset elements should have visually equal margins from the frame edge
- **Map fills to frame** — basemap extends edge-to-edge, no dead bands. Use near-zero `inner.margins` and `outer.margins`.
- **Suppress auto-legends** — build manual ones from registry values
- **ALL CAPS labels appear larger** — use title case for legend labels (gq `gq_tmap_classes()` handles this automatically via `to_title()` fallback)

## Self-Review (after every render)

Read the PNG and check before showing anyone:

1. Correct polygon/study area shown? (verify source data, not just the bbox)
2. Map fills the page? (no white/black bands)
3. Keymap inside frame with spacing from edge?
4. No element overlap? (each in its own corner)
5. Legend over least-important terrain?
6. Consistent spacing across all elements?
7. Scale bar breaks appropriate for extent?

See the `cartography` skill for full reference: basemap blending, BC spatial data queries, label hierarchy, mapgl gotchas, and worked examples.

## Land Cover Change

Use [drift](https://github.com/NewGraphEnvironment/drift) and [flooded](https://github.com/NewGraphEnvironment/flooded) together for riparian land cover change analysis. flooded delineates floodplain extents from DEMs and stream networks; drift tracks what's changing inside them over time.

**Pipeline:**

```r
# 1. Delineate floodplain AOI (flooded)
valleys <- flooded::fl_valley_confine(dem, streams)

# 2. Fetch, classify, summarize (drift)
rasters   <- drift::dft_stac_fetch(aoi, source = "io-lulc", years = c(2017, 2020, 2023))
classified <- drift::dft_rast_classify(rasters, source = "io-lulc")
summary    <- drift::dft_rast_summarize(classified, unit = "ha")

# 3. Interactive map with layer toggle
drift::dft_map_interactive(classified, aoi = aoi)
```

- Class colors come from drift's shipped class tables (IO LULC, ESA WorldCover)
- For production COGs on S3, `dft_map_interactive()` serves tiles via titiler — set `options(drift.titiler_url = "...")`
- See the [drift vignette](https://www.newgraphenvironment.com/drift/articles/neexdzii-kwa.html) for a worked example (Neexdzii Kwa floodplain, 2017-2023)


# Code Check Conventions

Structured checklist for reviewing diffs before commit. Used by `/code-check`.
Add new checks here when a bug class is discovered — they compound over time.

## Shell Scripts

### Quoting
- Variables in double-quoted strings containing single quotes break if value has `'`
- `"echo '${VAR}'"` — if VAR contains `'`, shell syntax breaks
- Use `printf '%s\n' "$VAR" | command` to pipe values safely
- Heredocs: unquoted `<<EOF` expands variables locally, `<<'EOF'` does not — know which you need
- Pass-through-ssh args: `printf '%q'` escapes per-arg so workload paths with spaces / quotes / metacharacters survive the local-shell → ssh-argv → remote-shell round-trip. Without it, `ssh host 'cmd' "$path"` joins args with spaces on remote and re-parses, losing argument boundaries.

### Heredoc precedence in pipelines
- `cmd1 | cmd2 <<EOF` — the heredoc binds to `cmd2` (the rightmost simple command). If you intended `cmd1` to receive it, put `<<EOF` on cmd1 explicitly: `cmd1 <<EOF | cmd2`.
- Symptom when wrong: ssh body silently echoed by tee/cat/etc, ssh side gets empty stdin, exits 0 (or near-0) without doing anything. Caught the hard way 2026-05-01 in cypher_restore-fwapg.sh.

### pipefail with ssh+tee
- `set -eu` does NOT propagate exit codes through pipelines. `ssh ... | tee log` returns tee's exit (always 0 for healthy tee), masking ssh failure.
- Use `set -euo pipefail` for any script that pipes a meaningful command into tee/cat/grep/etc. Or check `${PIPESTATUS[0]}` explicitly.
- Symptom when wrong: task notifications report "exit 0 / completed" while remote work was actually skipped or errored.

### Paths
- Hardcoded absolute paths (`/Users/<user>/...`) break for other users
- Use `REPO_ROOT="$(cd "$(dirname "$0")/<relative>" && pwd)"`
- After moving scripts, verify `../` depth still resolves correctly
- Usage comments should match actual script location

### Silent Failures
- `|| true` hides real errors — is the failure actually safe to ignore?
- Empty variable before destructive operation (rm, destroy) — add guard: `[ -n "$VAR" ] || exit 1`
- `grep` returning empty silently — downstream commands get empty input

### `mktemp` template needs enough X's, and a failed `mktemp` leaves an empty var
- BSD/macOS `mktemp -d -t <name>` requires the template to contain at least 3 `X`s (`XXXXXX` is the safe default). Without them, mktemp errors to stderr (`too few X's in template`) and **prints nothing to stdout**.
- Pattern: `SCRATCH=$(mktemp -d -t aider-smoke) && cd "$SCRATCH" && <destructive>`. When mktemp fails, `$SCRATCH=""`. `cd ""` is a no-op that **leaves you in the caller's cwd**. The destructive command (`rm`, `git init`, `git add+commit`) then runs in cwd instead of a throwaway tmpdir.
- Caught the hard way 2026-05-13: a Claude smoke test inside the rtj checkout did exactly this, accidentally committed a `demo.R` to the active feature branch, which then rode the squash-merge into rtj/main and had to be cleaned up post-merge.
- Fix patterns:
  - Always use `XXXXXX` (6 X's) in the template: `mktemp -d -t aider-smoke.XXXXXX`.
  - Guard the result: `SCRATCH=$(mktemp -d ...) || exit 1; [ -n "$SCRATCH" ] || exit 1`.
  - Use `set -euo pipefail` so the failed command-substitution kills the script.

### BSD vs GNU sed/grep portability (macOS hits this constantly)
- macOS ships BSD `sed`/`grep`. Linux CI/cloud-init hosts ship GNU. Snippets that work on one silently misbehave on the other.
- **`\+` and `\|` are GNU BRE extensions.** On BSD they're treated as literal `+` and `|`, so the regex still "matches" but matches nothing useful — leaving raw input unchanged.
  - Symptom seen 2026-05-28: `sed 's/[^a-z0-9]\+/-/g'` on macOS left spaces in an issue-title slug, producing an invalid git branch name.
  - Fix: use `sed -E` (POSIX ERE) so `+`, `|`, `?`, `(...)` all work without escapes on both flavors. The same regex becomes `sed -E 's/[^a-z0-9]+/-/g'`.
- **`s|pat|repl|` delimiter conflicts with `|` in alternation/replacement on BSD.** Pick a delimiter that does not appear in pattern or replacement (`#`, `,`, `:` are common choices). Compound `s|x|y|; s|^| /||` chains where the trailing `||` looks like an empty delimiter break on BSD sed even when GNU accepts them.
- **Don't parse `ls`.** BSD `ls` emits ANSI colour codes when stdout is a TTY *or* when `CLICOLOR_FORCE` is set in env (often by shell rc files), and the codes leak through pipes. Downstream `grep`/`sed` chokes on the embedded escapes (`[01;31m...[0m`).
  - Use `find <dir> -maxdepth 1 -mindepth 1 -type d -exec basename {} \;` for directory listings, or `printf '%s\n' <dir>/*/` for a glob, or `for d in <dir>/*/; do basename "$d"; done`.
- **When writing a snippet you expect to ship in a `skills/` SKILL.md or any cloud-init runcmd**: it must be POSIX-portable. Default to `sed -E`, avoid `\+`/`\|`, and don't pipe `ls`.

### Process Visibility
- Secrets passed as command-line args are visible in `ps aux`
- Use env files, stdin pipes, or temp files with `chmod 600` instead

## Cloud-Init (YAML)

### ASCII
- Must be pure ASCII — em dashes, curly quotes, arrows cause silent parse failure
- Check with: `perl -ne 'print "$.: $_" if /[^\x00-\x7F]/' file.yaml`

### YAML flow-mapping in runcmd
- Any runcmd item containing both `{` and `:` is at risk of being parsed as a YAML flow-mapping (dict), not a literal string. Cloud-init's shellify hits a non-string and throws TypeError, **aborting all subsequent runcmd steps silently** while `final_message` still fires.
- Don't write: `- test -s /file || { echo "FATAL: ..." }` — the `:` inside braces makes YAML see a dict.
- Do write: use `- |` block scalar with explicit `if/then/fi`:
  ```yaml
  - |
    if [ ! -s /file ]; then
      echo "FATAL: ..." >&2
      exit 1
    fi
  ```
- Validate post-edit: `python3 -c "import yaml; runcmd=yaml.safe_load(open('cloud-init.yaml').read().split(chr(10),1)[1])['runcmd']; print([type(x).__name__ for x in runcmd if not isinstance(x,str)] or 'all strings')"`. If the output is anything other than `all strings`, the runcmd will fail.

### State
- `cloud-init clean` causes full re-provisioning on next boot — almost never what you want before snapshot
- Use `tailscale logout` not `tailscale down` before snapshot (deregister vs disconnect)
- Wipe `/var/lib/tailscale/*` before snapshot too — `tailscale logout` deauthorizes server-side but local node identity blob persists in tailscaled.state. Snapshot restored elsewhere inherits prior key material until `tailscale up` runs again.
- Wipe `/etc/ssh/ssh_host_*` before snapshot — otherwise droplets spawned from the same image share host identity.

### Template Variables
- Secrets rendered via `templatefile()` are readable at `169.254.169.254` metadata endpoint
- Acceptable for ephemeral machines, document the tradeoff
- Heredocs in runcmd that write secrets: `<<'EOF'` (quoted) prevents bash from re-expanding `$X` sequences in already-substituted credential strings. AWS keys rarely contain `$` but base64-padded secrets might.

### Repo + key install ordering
- `apt-key adv --keyserver` is deprecated on Ubuntu 24.04 noble — silently fails AND APT ignores resulting keyring. Use `gpg --dearmor` + `signed-by=` keyring file pattern.
- Repo .list files in `write_files:` trigger the implicit `package_update` BEFORE runcmd installs the keyring → first apt-get update fails with NO_PUBKEY. Put the repo line in runcmd alongside the key install, not in write_files.

### Cloud-init users vs DO SSH key injection
- DO injects `ssh_key_ids` only into `/root/.ssh/authorized_keys` (cloud-init's `cc_ssh` module). Cloud-init `users:` block with `ssh_authorized_keys: []` does NOT pick those up.
- Non-root users that need SSH access must copy from root's keys in runcmd:
  ```yaml
  - mkdir -p /home/<user>/.ssh
  - cp /root/.ssh/authorized_keys /home/<user>/.ssh/authorized_keys
  - chown -R <user>:<user> /home/<user>/.ssh
  ```
- Guard with `test -s /root/.ssh/authorized_keys` to fail loudly if `cc_ssh` hasn't run before runcmd (rare race).

## OpenTofu / Terraform

### State
- Parsing `tofu state show` text output is fragile — use `tofu output` instead
- Missing outputs that scripts need — add them to main.tf
- Snapshot/image IDs in tfvars after deleting the snapshot — stale reference

### Destructive Operations
- Validate resource IDs before destroy: `[ -n "$ID" ] || exit 1`
- `tofu destroy` without `-target` destroys everything including reserved IPs
- Snapshot ID extraction by name: use `awk -v n="$NAME" '$2 == n {print $1}'` (exact match on column 2). `grep -F "$NAME"` is substring-match and can grab a stale snapshot whose name contains the new name as a substring.

### "Has been deleted" in plan output is not authoritative — verify against the cloud API first
- The AWS provider (5.x and some 6.x) has a known class of bug where a transient read error (false 404, regional-endpoint hiccup) is interpreted as "resource deleted outside of OpenTofu." The plan will show the resource and any children scheduled for destroy + recreate (`forces replacement` cascades through children that interpolate the parent's id/arn).
- If you didn't delete the resource and the plan says it's gone, **verify against the cloud API before applying**: `aws s3 head-bucket --bucket X`, `aws iam get-role --role-name X`, etc. A `tofu plan -refresh=true` re-run a moment later often reports "No changes."
- Caught 2026-05-14 in rtj env/prod for stac-era5-land: bucket fully intact (60 objects, 307 MB) but plan said deleted with 5 child resources "must be replaced." Apply would have clobbered the policy + lifecycle configs against the still-existing bucket. Recovery via `-target` on the unrelated resource being added (rtj#157 then codifies `lifecycle { prevent_destroy = true }` on the bucket + load-bearing children).
- **Belt-and-suspenders defense:** add `lifecycle { prevent_destroy = true }` to high-value resources (S3 buckets, RDS instances, anything irreplaceable) in their module. Tofu will refuse to plan a destroy until the lifecycle line itself is removed in config — converts the failure mode from "apply silently clobbers" into "plan errors with `Instance cannot be destroyed`." Don't apply it to count-based resources where `count: 1 → 0` is a legitimate transition.

## DigitalOcean

### Snapshot disk-size constraint
- DO snapshots include the source droplet's disk size. New droplets from a snapshot must have disk **>=** snapshot disk. Resize **up** is fine; resize **down** below the snapshot disk is impossible without rebuilding.
- Build the snapshot at the smallest droplet size you'd ever want to spin from it. Sizes vs disks at writing: `g-4vcpu-16gb` = 50 GB, `g-8vcpu-32gb` / `m-4vcpu-32gb` = 100 GB, `m-8vcpu-64gb` = 200 GB.
- If your workload requires X GB RAM minimum, your snapshot floor is whatever droplet has X GB AND the smallest disk class.

### Reserved IP detach behavior
- Targeted destroy (`tofu destroy -target=module.droplet -target=...assignment...`) preserves the reserved IP at $4/mo. Full `tofu destroy` releases it (next apply gets a NEW IP).

### Reserved IP assignment race (rtj#55, rtj#85)
- DO returns 422 "Droplet already has a pending event" when reserved IP assignment fires immediately after droplet+firewall creation. The droplet's internal event queue takes time to drain.
- **Every DO droplet module that uses a reserved IP MUST have:**
  1. `time_sleep` resource between droplet creation and IP assignment, with `create_duration ≥ 60s` (10s and 30s have both been observed to race; 60s has more headroom)
  2. `depends_on = [time_sleep.<name>]` on the `digitalocean_reserved_ip_assignment` resource
  3. A retry fallback in the wrapping shell script (`up.sh` style) that detects the 422 in tofu output and uses `doctl compute reserved-ip-action assign <ip> <droplet-id>` to recover. Tofu doesn't retry; it leaves state half-applied (assignment recorded but DO didn't actually attach).
- **Snapshot-based spins are MORE prone to the race** than first-boot from blank Ubuntu (more startup events compete for the droplet's event queue).
- **Audit existing modules:** `grep -L 'time_sleep' env/do/*/<host>/main.tf` finds modules missing the gate. As of 2026-05-02, openclaw and geoserv have no `time_sleep` — they will race eventually.

## Docker / Postgres

### Postgis init time
- `imresamu/postgis` (and similar postgis images) on first cold start (empty data volume) take **5-12 min** to install all extensions — varies with disk IO and noisy-neighbor lottery on cloud hosts. Health-wait scripts must allow 15 min minimum, ideally with hard-fail + log dump on timeout.

### Tuning vs host RAM
- fresh's `docker/docker-compose.yml` defaults are tuned for a 128 GB host (`shared_buffers=32GB`, `shm_size=36gb`). On smaller hosts, postgres OOMs at startup with "could not map anonymous shared memory".
- 32 GB host floor: use the M1/cypher 32 GB-host preset (`scripts/fwapg/compose.override.m1.yml`) which sets `shared_buffers=8GB, shm_size=12gb`.
- Below 32 GB: postgres can technically start with smaller `shared_buffers` but fwapg work becomes painful. Don't run fwapg pipelines on <32 GB hosts.

### `search_path` is data, not config
- `ALTER DATABASE <db> SET search_path TO ...` is a database-level setting **stored in the postgres data dir**. Wiped with `docker compose down -v`. Must be re-applied on every restore.
- Codify in your restore script, not in cloud-init or compose env (those don't apply to db-level settings).

### `pkill <R/Python/etc. client>` does NOT cancel its Postgres query
- Killing the client (R, Python, psql) closes its connection. The libpq backend on the server keeps running the in-flight query until it finishes — **server-side orphan**. The orphaned backend holds whatever locks it had (table, view, advisory). Every later `DROP VIEW` / `LOCK TABLE` / `ALTER` on the same object blocks behind it indefinitely — *silent hangs* indistinguishable from a slow query.
- Caught 2026-05-25 in link#205: a `pkill`'d `wsg_run_one.R` left a `frs_network_features` SELECT running 1h45m; subsequent recomputes wedged on `DROP VIEW barriers_bt_access` for 1h08m before someone noticed.
- **Always terminate the server-side backend**, not just the client:
  ```sql
  SELECT pid, pg_terminate_backend(pid)
  FROM pg_stat_activity
  WHERE datname='<db>' AND state='active' AND now()-query_start > interval '3 minutes'
    AND pid <> pg_backend_pid();
  ```
  Then kill the client. Order matters when you don't know which side will block.

### Set `statement_timeout` + `lock_timeout` on long DB ops
- Any long-running DB op from an R/Python/etc. client should set both at session start, ideally via env (`PGOPTIONS='-c statement_timeout=600000 -c lock_timeout=60000'`) or on the connection itself (`DBI::dbExecute(conn, "SET statement_timeout = '600000'")`). A runaway query then cancels server-side (no orphan); a blocked `DROP VIEW` gives up rather than wedging behind a zombie lock. Without it, silent hangs become indistinguishable from "still working" and you wait hours.
- Pick a generous-but-bounded timeout (10× expected query time). The point isn't tight enforcement — it's "fail loud instead of fail silent."

### Function-as-join-predicate: index visibility depends on inlineability
- `JOIN b ON some_function(a.cols, b.cols)` — Postgres can only use the underlying indexes if `some_function` is `LANGUAGE sql` (inlineable). `plpgsql` functions are opaque and force per-row evaluation → seq scan / nested loop without indexes. Verify with `\df+ <function>` (look at `Language`) and `EXPLAIN` (look for the function body expanded into Filter / Index Cond).
- Caught in link#205 with `whse_basemapping.fwa_downstream` — it IS `LANGUAGE sql` + the planner did inline it; the symptom was elsewhere (see below). But if a function-based join is slow and the function is plpgsql, that's the first thing to look at.

### Joining on a per-tenant key (e.g. `id_segment` per-WSG) against a multi-tenant table is cartesian
- `id_segment` in link's persist schema is unique *within* a WSG, not globally (link#203). `WHERE id_segment IN (SELECT id_segment FROM streams WHERE wsg=aoi)` against persist matches access rows from *every* WSG sharing those id_segment values → N(WSGs)× duplicates → PK violations downstream and 50× memory.
- Fix: filter by the full tenant key (`watershed_group_code = aoi`) when the table has it. Pattern: introspect via `information_schema.columns` at runtime and branch — the same function can serve a working schema (single tenant, no WSG col) and persist (multi-tenant, with WSG col).

### View vs. real table changes the planner's join direction
- A `CREATE VIEW v AS SELECT * FROM big_table WHERE … ` carries no row-count statistics. Used as a join input, the planner may pick the other side (big) as the outer driver, blowing nested-loop cost ~1000× — the symptom looks like "the indexes aren't being used" but it's actually a wrong-direction nested loop.
- Caught in link#205: AOI-scoping streams via a `VIEW` left Postgres thinking the 26k FINA segments were as big as the 800k persist barriers; it picked barriers as outer; 71M estimated result rows; >10 min wall.
- Fix when AOI-scoping into a smaller dataset: **materialise as a real `CREATE TABLE` with indexes + `ANALYZE`**. The planner then sees the small row count and picks it as outer. Drop the table on `on.exit` if it's transient.

### Two-statement DELETE/INSERT into a persist table is not atomic
- A "DELETE WHERE wsg='X'; INSERT …" pair into a persist table from an orchestration script: if the INSERT fails (e.g. duplicate key from a subtle JOIN bug), the DELETE already ran → **data loss for that WSG**. Wrap in a single transaction (`BEGIN; … ; COMMIT`) when the persist table is the only source of truth, so a failed INSERT rolls back the DELETE. (link#205 lost FINA's `streams_mapping_code` to this; the surrounding cheap-recompute orchestration in `wsg_recompute_one.R` should wrap both statements in a tx.)

## Tailscale

### ACL "users" semantics
- Tailscale SSH ACL `"users": ["autogroup:nonroot"]` for `tag:compute` blocks `ssh root@<node>` over the tailnet. Use `ssh <user>@<node>` + sudo for root operations.
- For SSH-as-root from off-tailnet (regular OpenSSH on the public IP), the ACL doesn't apply — but you need the SSH key registered on the node.

### Reusable + ephemeral auth keys
- Cypher-style ephemeral compute droplets need both flags on the auth key: **Reusable** (same key works across destroy/recreate) + **Ephemeral** (tailnet entries auto-clean when offline >5 min).
- Tag the key (e.g. `tag:compute`) at creation time. Nodes joining with that key inherit the tag automatically — no `--advertise-tags` needed at `tailscale up` time.

## Security

### Secrets in Committed Files
- `.tfvars` must be gitignored (contains tokens, passwords)
- `.tfvars.example` should have all variables with empty/placeholder values
- Sensitive variables need `sensitive = true` in variables.tf

### Firewall Defaults
- `0.0.0.0/0` for SSH is world-open — document if intentional
- If access is gated by Tailscale, say so explicitly

### Credentials
- Passwords with special chars (`'`, `"`, `$`, `!`) break naive shell quoting
- `printf '%q'` escapes values for shell safety
- Temp files for secrets: create with `chmod 600`, delete after use

## R / Package Installation

### pak Behavior
- pak stops on first unresolvable package — all subsequent packages are skipped
- Removed CRAN packages (like `leaflet.extras`) must move to GitHub source
- PPPM binaries may lag a few hours behind new CRAN releases

### Reproducibility
- Branch pins (`pkg@branch`) are not reproducible — document why used
- Pinned download URLs (RStudio .deb) go stale — document where to update

### Base name shadowing in formal args
- Avoid `names`, `length`, `data`, `c`, `t`, `T`, `F`, etc. as formal argument names. R's function-lookup fallback often rescues `names(x)` calls inside a function whose arg is also called `names` — but it's a confusing read, breaks under refactors, and generates a real "could not find function" error when the lookup heuristic misses (e.g. inside lapply/vapply/match.fun chains). Prefer descriptive alternatives: `label_names`, `n`, `df`, etc.
- Caught in mc#33 round 1 — `mc_label_ensure(names)` worked by luck when calling `names(existing)` to read a named-vector's names; renamed to `label_names` for safety.

### Cross-function consistency for label/string normalization
- When two functions in the same package both decide whether a string is a "system value" (or any normalized form), they MUST use the same comparison. Mismatches are silent bugs that surface only on edge cases.
- mc#33 example: `mc_label_ensure` used `toupper(nm) %in% sys` (case-insensitive system-label skip), but `resolve_label_names` used `nm %in% sys` (case-sensitive). Result: `add = "inbox"` with `create_missing = TRUE` was silently broken — ensure skipped creation, resolve couldn't match. Fix: both use `toupper(nm) %in% sys` and the resolver normalizes its return to the canonical case.
- Generalized check: when reviewing a diff that adds normalization (case, whitespace, prefix-trim) on one side of an interaction, grep for the other side and align them.

## General

### Adopting Existing Config

When importing config from one location into a canonical one (legacy `~/.bash_profile` → dotfiles repo, old script's env → repo, another project's `settings.json` → soul):

- **Verify every referenced path/binary exists.** Dead PATH exports, missing interpreters, stale env vars should be cut, not codified.
  Shell paths: `for p in $(echo "$PATH" | tr ':' ' '); do [ -d "$p" ] || echo "DEAD: $p"; done`
- **Ask before dropping a reference** — it may be something the user forgot to reinstall on this machine, not something to delete.
- **Curated subset, not verbatim copy.** The diff should reflect what you verified, not the whole source.

### Documentation Staleness
- Moving/renaming scripts: update CLAUDE.md, READMEs, usage comments
- New variables: update .tfvars.example
- New workflows: update relevant README


# NGE Feature Workflow

For non-trivial issue-driven work, follow this checklist. Each step exists for a reason — skipping leads to rework, broken builds, and avoidable bugs that we've hit repeatedly.

## The Sequence

1. **Start with `/planning-init <N>`** — given an issue number, enters plan mode for codebase exploration, presents a phase breakdown for user approval, then scaffolds branch + PWF baseline with the approved phases. One command replaces the manual issue → explore → plan → branch → scaffold dance.
2. **Write robust tests first** — failing tests that reproduce the issue or document the new behavior. Tests are the contract; they fail until the work makes them pass.
3. **Name with intent** — functions, parameters, internal helpers carry the naming style of the package they live in. Look at existing exports as the guide; consistency over cleverness. (Per-package naming convention TBD — see soul issue tracking.)
4. **Examples that run** — every exported function gets a runnable `@examples` block. Pkgdown renders them; CI executes them. An example that doesn't run is documentation rot.
5. **Code-check before each commit** — `/code-check` on staged diff. Catches what tests miss: edge cases, hard-coded paths, unguarded variables, security issues.
6. **Atomic commits** — each commit bundles code change + checkbox flip in `task_plan.md`. The diff and the progress live in the same commit; `git log -- planning/` tells the full story.
7. **`/planning-archive` when complete** — moves PWF to `archive/YYYY-MM-issue-N-slug/`, creates a fresh `active/`. Then `/gh-pr-push` opens the PR; `/gh-pr-merge` handles the release bookkeeping.

## When to Skip

For one-line typo fixes, version-bump-only PRs, or trivial documentation edits, the full workflow is overhead. Use judgment. The threshold is roughly: **multi-step issue, multi-file change, or anything that requires scoping** → use the workflow.

## Skills That Slot In

- `/planning-init <N>` — start
- `/planning-update` — sync checkboxes mid-session
- `/code-check` — before every commit
- `/planning-archive` — when issue closes
- `/gh-pr-push` — open the PR
- `/gh-pr-merge` — merge with release bookkeeping

## Why This Exists

We've hit snags repeatedly when half-doing this — branches that mix concerns, tests bolted on after, code-check skipped (and then a bug ships in the diff), examples that fail in pkgdown. Each step is small; the cumulative reliability gain is real. The convention is here so it becomes the default expectation, not a thing the user has to remind every session about.


# LLM Behavioral Guidelines

<!-- Source: https://github.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md -->
<!-- Last synced: 2026-02-06 -->
<!-- These principles are hardcoded locally. We do not curl at deploy time. -->
<!-- Periodically check the source for meaningful updates. -->

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.


**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.


# Planning Conventions

How Claude manages structured planning for complex tasks using planning-with-files (PWF).

## When to Plan

Use PWF when a task has multiple phases, requires research, or involves more than ~5 tool calls. Triggers:
- User says "let's plan this", "plan mode", "use planning", or invokes `/planning-init`
- Complex issue work begins (multi-step, uncertain approach)
- Claude judges the task warrants structured tracking

Skip planning for single-file edits, quick fixes, or tasks with obvious next steps.

## The Workflow

1. **Explore first** — Enter plan mode (read-only). Read code, trace paths, understand the problem before proposing anything.
2. **Plan to files** — Write the plan into 3 files in `planning/active/`:
   - `task_plan.md` — Phases with checkbox tasks
   - `findings.md` — Research, discoveries, technical analysis
   - `progress.md` — Session log with timestamps and commit refs
3. **Plan-review with the Plan agent before committing the plan** — After scaffolding `task_plan.md` but BEFORE the baseline commit, spawn the Plan subagent (`Agent({subagent_type: "Plan", prompt: "..."}`) and ask it to critically review the task_plan against the issue body + actual codebase. Categorize findings as Blocker / Gap / Ordering / Assumption / Scope / Acceptance. Address each before committing. The agent reads files fresh — it catches what you miss when you've been thinking about the design too long. Real example: caught 21 issues including hardcoded literals across 4 files not listed in the plan, untested DB column mismatches, unfixable test-literal-string assertions, and a baseline-cache-shadow that would have produced a 6-second no-op run. Cost: ~5 min agent. Saves: hours of mid-implementation rework.
4. **Commit the plan** — After Plan-agent review + fixes. This is the baseline.
5. **Work in atomic commits** — Each commit bundles code changes WITH checkbox updates in the planning files. The diff shows both what was done and the checkbox marking it done.
6. **Code check before commit** — Run `/code-check` on staged diffs before committing. Don't mark a task done until the diff passes review.
7. **Archive when complete** — Move `planning/active/` to `planning/archive/` via `/planning-archive`. Write a README.md in the archive directory with a one-paragraph outcome summary and closing commit/PR ref — future sessions scan these to catch up fast.

## Atomic Commits (Critical)

Every commit that completes a planned task MUST include:
- The code/script changes
- The checkbox update in `task_plan.md` (`- [ ]` -> `- [x]`)
- A progress entry in `progress.md` if meaningful

This creates a git audit trail where `git log -- planning/` tells the full story. Each commit is self-documenting — you can backtrack with git and understand everything that happened.

## File Formats

### task_plan.md

Phases with checkboxes. This is the core tracking file.

```markdown
# Task Plan

## Phase 1: [Name]
- [ ] Task description
- [ ] Another task

## Phase 2: [Name]
- [ ] Task description
```

Mark tasks done as they're completed: `- [x] Task description`

### findings.md

Append-only research log. Discoveries, technical analysis, things learned.

```markdown
# Findings

## [Topic]
[What was found, with source/date]
```

### progress.md

Session entries with commit references.

```markdown
# Progress

## Session YYYY-MM-DD
- Completed: [items]
- Commits: [refs]
- Next: [items]
```

## Directory Structure

```
planning/
  active/          <- Current work (3 PWF files)
  archive/         <- Completed issues
    YYYY-MM-issue-N-slug/
```

If `planning/` doesn't exist in the repo, run `/planning-init` first.

## Skills

| Skill | When to use |
|-------|-------------|
| `/planning-init` | First time in a repo — creates directory structure |
| `/planning-update` | Mid-session — sync checkboxes and progress |
| `/planning-archive` | Issue complete — archive and create fresh active/ |


# Reference Management Conventions

How references flow between Claude Code, Zotero, and technical writing at New Graph Environment.

## Tool Routing

Three tools, different purposes. Use the right one.

| Need | Tool | Why |
|------|------|-----|
| Search by keyword, read metadata/fulltext, semantic search | **MCP `zotero_*` tools** | pyzotero, works with Zotero item keys |
| Look up by citation key (e.g., `irvine2020ParsnipRiver`) | **`/zotero-lookup` skill** | Citation keys are a BBT feature — pyzotero can't resolve them |
| Create items, attach PDFs, deduplicate | **`/zotero-api` skill** | Connector API for writes, JS console for attachments |

**Citation keys vs item keys:** Citation keys (like `irvine2020ParsnipRiver`) come from Better BibTeX. Item keys (like `K7WALMSY`) are native Zotero. The MCP works with item keys. `/zotero-lookup` bridges citation keys to item data.

**BBT citation key storage:** As of Feb 2025+, BBT stores citation keys as a `citationKey` field directly in `zotero.sqlite` (via Zotero's item data system), not in a separate BBT database. The old `better-bibtex.sqlite` and `better-bibtex.migrated` files are stale and no longer updated. Query citation keys with: `SELECT idv.value FROM items i JOIN itemData id ON i.itemID = id.itemID JOIN itemDataValues idv ON id.valueID = idv.valueID JOIN fields f ON id.fieldID = f.fieldID WHERE f.fieldName = 'citationKey'`.

## Adding References Workflow

### 1. Search and flag

When research turns up a reference:
- **DOI available:** Tell the user — Zotero's magic wand (DOI lookup) is the fastest path
- **ResearchGate link:** Flag to user for manual check — programmatic fetch is blocked (403), but full text is often there
- **BC gov report:** Search [ACAT](https://a100.gov.bc.ca/pub/acat/), for.gov.bc.ca library, EIRS viewer
- **Paywalled:** Note it, move on. Don't waste time trying to bypass.

### 2. Add to Zotero

**Preferred order:**
1. DOI magic wand in Zotero UI (fastest, most complete metadata)
2. Web API POST with `collections` array (grey literature, local PDFs — targets collection directly, no UI interaction needed)
3. `saveItems` via `/zotero-api` (batch creation from structured data — requires UI collection selection)
4. JS console script for group library (when connector can't target the right collection)

**Collection targeting:** `saveItems` drops items into whatever collection is selected in Zotero's UI. Always confirm with the user before calling it. **Web API bypasses this** — include `"collections": ["KEY"]` in the POST body. Find collection keys with `?q=name` search on the collections endpoint.

### 3. Attach PDFs

`saveItems` attachments silently fail. Don't use them. Instead:

1. **Web API S3 upload (preferred):** Create attachment item → get upload auth → build S3 body (Python: prefix + file bytes + suffix) → POST to S3 → register with uploadKey. Works without Zotero running. See `/zotero-api` skill section 4.
2. **JS console fallback:** Download with `curl`, attach via `item_attach_pdf.js` in Zotero JS console.
3. Verify attachment exists via MCP: `zotero_get_item_children`

### 4. Verify

After manual adds, confirm via MCP:
- `zotero_search_items` — find by title
- `zotero_get_item_metadata` — check fields are complete
- `zotero_get_item_children` — confirm PDF attached

### 5. Clean up

If duplicates were created (common with `saveItems` retries):
- Run `collection_dedup.js` via Zotero JS console
- It keeps the copy with the most attachments, trashes the rest

## In Reports (bookdown)

### Bibliography generation

```yaml
# index.Rmd — dynamic bib from Zotero via Better BibTeX
bibliography: "`r rbbt::bbt_write_bib('references.bib', overwrite = TRUE)`"
```

`rbbt` pulls from BBT, which syncs with Zotero. Edit references in Zotero → rebuild report → bibliography updates.

**Library targeting:** rbbt must know which Zotero library to search. This is set globally in `~/.Rprofile`:

```r
# default library — NewGraphEnvironment group (libraryID 9, group 4733734)
options(rbbt.default.library_id = 9)
```

Without this option, rbbt searches only the personal library (libraryID 1) and won't find group library references. The library IDs map to Zotero's internal numbering — use `/zotero-lookup` with `SELECT DISTINCT libraryID FROM citationkey` against the BBT database to discover available libraries.

### Citation syntax

- `[@key2020]` — parenthetical: (Author 2020)
- `@key2020` — narrative: Author (2020)
- `[@key1; @key2]` — multiple
- `nocite:` in YAML — include uncited references

### Cite primary sources

When a review paper references an older study, trace back to the original and cite it. Don't attribute findings to the review when the original exists. (See LLM Agent Conventions in `newgraph.md`.)

**When the original is unavailable** (paywalled, out of print, can't locate): use secondary citation format in the prose and include bib entries for both sources:

> Smith et al. (2003; as cited in Doctor 2022) found that...

Both `@smith2003` and `@doctor2022` go in the `.bib` file. The reader can then track down the original themselves. Flag incomplete metadata on the primary entry — it's better to have a partial reference than none at all.

## PDF Fallback Chain

When you need a PDF and the obvious URL doesn't work:

1. DOI resolver → publisher site (often has OA link)
2. Europe PMC (`europepmc.org/backend/ptpmcrender.fcgi?accid=PMC{ID}&blobtype=pdf`) — ncbi blocks curl
3. SciELO — needs `User-Agent: Mozilla/5.0` header
4. ResearchGate — flag to user for manual download
5. Semantic Scholar — sometimes has OA links
6. Ask user for institutional access

Always verify downloads: `file paper.pdf` should say "PDF document", not HTML.

## Searching Paper Content (ragnar)

### Setup (per project)
- `scripts/rag_build.R` — maps citation keys to Zotero PDF attachment keys, builds DuckDB
- `data/rag/` gitignored — store is local, not committed
- Dependencies: ragnar, Ollama with nomic-embed-text model
- See `/lit-search` skill for full recipe

### Query
`ragnar_store_connect()` then `ragnar_retrieve()` — returns chunks with source file attribution.

### Anti-patterns
- NEVER write abstracts manually — if CrossRef has no abstract, leave blank
- NEVER cite specific numbers without verifying from the source PDF via ragnar search
- NEVER paraphrase equations — copy exact notation and cite page/section
