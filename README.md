# Neexdzii Kwah Restoration Planning — 2024

> Living restoration plan for the Neexdzii Kwah (Upper Bulkley River) watershed in the Skeena basin, prepared with Wet'suwet'en knowledge and stewardship for the Wet'suwet'en Treaty Office Society (WTOS) on behalf of the Society for Ecosystem Restoration in Northern BC (SERN).

**Read the report:** <https://newgraphenvironment.com/restoration_wedzin_kwa_2024>
&middot; **Source:** [`NewGraphEnvironment/restoration_wedzin_kwa_2024`](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024)
&middot; **Current draft:** v0.2.9 (see [`NEWS.md`](NEWS.md) for version history)

## What this is

A reproducible, web-first restoration-planning report integrating ecological science, Indigenous stewardship knowledge, and quantitative spatial analysis to identify, prioritize, and sequence restoration interventions across the Neexdzii Kwah watershed. The report is iterated as new data, monitoring results, and partner input land — version-controlled, open-source, and rebuildable end-to-end from raw data.

The report is structured as a [bookdown](https://bookdown.org/) gitbook (HTML-first, with PDF + EPUB outputs). Interactive maps, sortable tables, citation tooltips, and embedded climate / hydrology figures are first-class — the report is meant to be *used* by managers and stewardship staff, not just printed.

## Companion artefacts

| Artefact | Role |
|---|---|
| [`restoration_wedzin_kwa_2024_recomendations`](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024_recomendations) | Shiny app — interactive, sortable recommendations table with [xciter](https://github.com/NewGraphEnvironment/xciter)-powered citations. Linked from the main report. |
| [`bc_climate_anomaly`](https://github.com/NewGraphEnvironment/bc_climate_anomaly/tree/newgraph) (newgraph branch) | Fork of `bcgov/bc_climate_anomaly`; precursor to [`cd`](https://github.com/NewGraphEnvironment/cd). Climate-departure analysis appendix is fed from this fork. |
| [`new_graphiti`](https://github.com/NewGraphEnvironment/new_graphiti) blog posts | `2024-06-19-precipitation` (3D interactive precipitation) and `2024-06-30-land-cover` (baseline land-cover classification — proof of concept for the LULC change detection used in this report). |
| [`neexdzii_kwa_benthic_2025`](https://github.com/NewGraphEnvironment/neexdzii_kwa_benthic_2025) | Standalone benthic-macroinvertebrate effectiveness monitoring report — referenced from the monitoring appendix. |

## Build

```r
source("scripts/run.R")
```

`run.R` is the canonical entry point — it sources `scripts/staticimports.R` (which inlines `my_tab_caption()` / `my_dt_table()` and other helpers via the [staticimports](https://github.com/wch/staticimports) package) and then runs `bookdown::render_book()`. Bypassing `run.R` and calling `bookdown::render_book()` directly produces *undefined-function* errors.

`scripts/` also contains the LULC + floodplain pipeline (`scripts/floodplain_lcc/`) and one-shot analyses that produce the data underlying the appendices. Each pipeline writes `data/` outputs that the Rmd chunks then read — so a clean rebuild from raw inputs is a sequenced run, not a single `render_book()` call.

## R&D drawn into this report (the package ecosystem)

This report is the most ambitious integration target for the New Graph Environment R&D stack — every package below contributes content or methodology:

| Package | Contribution |
|---|---|
| [`fresh`](https://github.com/NewGraphEnvironment/fresh) | FWA-grounded stream-network primitives + habitat classification (sub-basin breaks, accessible / spawning / rearing layers). |
| [`link`](https://github.com/NewGraphEnvironment/link) | Cross-system crossing matching + barrier-override resolution for the fish-passage sections. |
| [`flooded`](https://github.com/NewGraphEnvironment/flooded) | Floodplain delineation from DEM + stream network, feeding the LULC change-detection extent. |
| [`drift`](https://github.com/NewGraphEnvironment/drift) | LULC change detection in floodplains (the v0.2.9 sieve-threshold work landed here first). |
| [`cd`](https://github.com/NewGraphEnvironment/cd) | Climate-departure analysis for the climate appendix (ERA5-Land via STAC). |
| [`fly`](https://github.com/NewGraphEnvironment/fly) | Historic-airphoto selection for the long-baseline change-detection context. |
| [`gq`](https://github.com/NewGraphEnvironment/gq) | Cartographic style registry across the report's maps, the recommendations app, and the QGIS project. |
| [`ngr`](https://github.com/NewGraphEnvironment/ngr), [`fpr`](https://github.com/NewGraphEnvironment/fpr) | Reporting + fish-passage utilities used across the chunks. |

Each piece is independently usable; this report exercises them together against a real watershed problem.

## Versioning

Version tracking uses the [`fledge`](https://fledge.cynkra.com/) package. Commit messages starting with `-` or `*` get pulled into [`NEWS.md`](NEWS.md) by `fledge::finalize_version()`. The changelog is reachable from the report's Methods chapter under "Open Source Reporting."

## License

MIT (see [`LICENSE`](LICENSE)).
