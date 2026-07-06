# Task: Rerun coho network + floodplain LULC with `link` 0.44.1 (#152)

The v0.2.11 floodplain/LULC numbers were built with `link` 0.43.0, which carried the
access-segmentation over-credit bug fixed in link#228 (closing link#223), released in
`link` 0.44.0 (current main 0.44.1). Pre-fix, per-model gradient + falls barriers were
reduced to the downstream-most per path (`fresh::frs_barriers_minimal`) and used as the
segmentation source, so the network broke at only one frontier per path: **falls** (low,
usually downstream-most) survived so above-falls stayed correctly blocked, but **gradient
barriers > 15%** (dense, upstream) were dropped so reaches above them were over-credited as
coho-accessible. Net: the coho accessible network (~678 km) and the floodplain it drives
(headline 746 ha tree loss) are likely over-stated. This rerun regenerates the network with
the fix, cascades to the floodplain + LULC, and corrects the report. Follows #148.

## Phase 1: Network delta (measure the fix before cascading)
- [ ] Copy current `data/lulc/aquatic_network.gpkg` aside as the link-0.43.0 baseline (scratch, not committed)
- [ ] Install `link` >= 0.44.1; assert `packageVersion("link") >= "0.44.0"`; bump the `01_network_extract.R` version comment to `>= 0.44.0`
- [ ] Re-run `scripts/floodplain_lcc/01_network_extract.R`; capture new `streams_co3` segment count + total accessible length (order >= 3, Neexdzii)
- [ ] Compute accessible-km delta vs 678; classify accessible->blocked reaches by limiting barrier type (above-gradient>15% vs above-falls); record in findings.md
- [ ] Record go/no-go for Phase 2 (expected: material -> proceed)

## Phase 2: Floodplain + LULC rerun
- [ ] Re-run `scripts/floodplain_lcc/02_floodplain_model.R` (VCA on corrected network, MRDEM-30) -> `floodplain.gpkg` + rasters
- [ ] Re-run `scripts/floodplain_lcc/03_lulc_classify.R` -> `floodplain_landcover.gpkg` + `lulc_summary.rds` (1 ha sieve, co_ff04)
- [ ] Compare floodplain extent (km²) + total tree loss vs 746 ha + per-sub-basin figures; record deltas in findings.md
- [ ] Commit regenerated `data/lulc/*` binary outputs (one data commit)

## Phase 3: Report update
- [ ] Rebuild report (`scripts/run.R`) so computed numbers refresh from new data (gitbook + exec-summary PDF)
- [ ] Adjust methods/appendix wording only if network-definition framing shifts; note v0.2.11 numbers revised down for the link#223 access fix
- [ ] Bump `DESCRIPTION` Version 0.2.11 -> 0.2.12; add matching dated `NEWS.md` entry
- [ ] Update memory `floodplain-numbers-provisional.md` -> numbers now authoritative

## Phase 4: Mergin push
- [ ] With `update_gis=TRUE`, copy corrected layers into `path_gis`, then `Rscript scripts/gis/mergin_sync.R push`
- [ ] Comment on the Mergin tracking issue noting corrected layers pushed

## Phase 5: Recommendations app
- [ ] Update `restoration_wedzin_kwa_2024_recomendations` with corrected sub-basin numbers; rebuild (separate repo)

## Validation
- [ ] `01` runs clean via `link` >= 0.44.0; `streams_co3` accessible km lower than 678, drop classified as above-gradient (not above-falls)
- [ ] `02`->`03` regenerate; floodplain km² + total tree loss shift down from 746 ha, deltas explained by removed above-gradient reaches
- [ ] Report rebuilds with no errors; exec-summary + appendix numbers track new data; version reads 0.2.12
- [ ] `/code-check` clean on each commit; PWF checkboxes match landed work
- [ ] `/planning-archive` on completion, then `/gh-pr-push`
