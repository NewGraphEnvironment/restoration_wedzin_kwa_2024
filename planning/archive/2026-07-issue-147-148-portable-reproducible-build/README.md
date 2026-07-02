## Outcome

Made the Neexdzii Kwa restoration report and its floodplain LULC pipeline **reproducible and machine-portable** (#147 portability, #148 `link` modernization). The pipeline now sources the DEM from the national **MRDEM-30** via `flooded::fl_dem_aoi()` (was a hand-placed 25 m bcfishpass `habitat_lateral` DEM), builds the coho-accessible network with **`link`** (default config) against a local **`fwapg`** DB via standard libpq env vars (was `fresh` over an SSH tunnel), reads parameter CSVs from the `fresh` package, gates the GIS copy behind `update_gis`, and syncs the Mergin project via a public-safe `mergin` CLI script (no private `rfp`). `scripts/packages.R` was completed + de-duplicated (missing packages added; `ggdark` moved to GitHub after CRAN archival; CRAN-mirror guard for bare `Rscript`; `update_bib: FALSE` default), and the 22 MB `data/lulc` outputs were committed — so the report now builds from a clean `git clone` + `scripts/run.R` with **no fwapg DB, DEM fetch, STAC, or Zotero required**. Headline floodplain tree loss revised **~647 → ~746 ha**, driven primarily by DEM resolution (30 m vs 25 m); the `link` accessibility recompute reproduces bcfishpass within ~2% and is a minor secondary factor. Methods + LULC appendix updated to match.

## Key learnings

- **Served ~647 ha baseline is authoritative** — confirmed via Mergin sync (the Mergin file was *current*, not stale; an earlier "-1108 ha" scare was a misread of a pre-intersection area column on the wrong layer).
- **Network-difference root cause corrected (retraction):** the served `co_ff04` floodplain was the March-2026 `fresh`-over-tunnel build; `link`'s bcfishpass parity is a *recent* development, so the ~56 km accessibility delta is fresh-vintage drift — **not** a single `frs_break_find` gradient-algorithm change (that earlier "island-based #87" conclusion was over-confident and was retracted in findings.md).
- **`dft_transition_vectors` clips, not drops:** it uses `st_intersection`, so patches straddling a sub-basin boundary keep their in-study-area portion (verified: only ~10 ha of change trimmed outside the sub-basins, which is correct). The 346 ha floodplain-outside-subbasins is 3 chunks at the reach extremities — expected.
- **`pak` stops on the first unresolvable package**, silently skipping the rest — an archived-from-CRAN package (`ggdark`) blocked the whole install until moved to GitHub source. (Generalizes the existing CLAUDE.md note.)
- **Two versioning systems, complementary:** git versions `data/lulc` for build reproducibility (full binary blobs — don't churn), Mergin versions the same layers efficiently (geodiff) as the canonical GIS home.

## Follow-ups (non-blocking)

- Stale citation key `smith_gaboury2016BUILTREPORT` (not in references.bib, not cited) — clean up.
- Adopt a declarative `update_qgis` manifest param + shared copy helper (replaces the manual `cp` of LULC layers into the GIS project) — [mybookdown-template#92](https://github.com/NewGraphEnvironment/mybookdown-template/issues/92).

Closed by: PR #150 (merge `7301e5e`), tag `v0.2.11`. Related: `mybookdown-template#92`, `NewGraphEnvironment/sred#15`.
