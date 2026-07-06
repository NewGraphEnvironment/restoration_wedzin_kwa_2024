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

## Phase 1: Network delta (measure the fix before cascading) — DONE
- [x] Copy current `data/lulc/aquatic_network.gpkg` aside as the link-0.43.0 baseline (scratch, not committed)
- [x] Install `link` >= 0.44.1 (installed 0.44.1); bump the `01_network_extract.R` version comment to `>= 0.44.0`
- [x] Re-run `scripts/floodplain_lcc/01_network_extract.R` — 1936 segments, 678.2 km (unchanged)
- [x] Compute accessible-km delta vs 678: **~0** (spatially identical, 106 BLKs, per-BLK delta <5e-5 km). Barrier classification: 94% of CO-blocking gradient barriers are on order<3 streams (excluded by our order>=3 filter); falls survived as hypothesized. See findings.md.
- [x] **RESULT: no material change.** Network unchanged -> floodplain/LULC/numbers unchanged. Phases 2/4/5 not required; see revised Phase 3.

## Phase 1 outcome (pivot)
The v0.2.11 coho order>=3 network is NOT over-stated — the link#223 fix does not change our
floodplain-input geometry (678.2 km identical). BUT the stored `aquatic_network.gpkg` was built
with the buggy 0.43.0 and is incorrect as a general-purpose layer (id_segment labels + BULK-wide
segmentation reflect the pre-fix state; may feed bull trout / other work later). Per user
decision: **store the correct 0.44.1 network and remodel the floodplain from it**, verifying the
floodplain output is genuinely unchanged (do not assume) before overwriting.

## Phase 2: Replace network + remodel floodplain, with a verification gate — DONE
- [x] Regenerated `aquatic_network.gpkg` under link 0.44.1 — geometrically IDENTICAL to committed (1812 DRM breakpoints setequal=TRUE, 678.1774 km; only id_segment labels differ)
- [x] Backed up committed floodplain outputs with checksums (/tmp/152_floodplain_baseline)
- [x] Re-ran `02` (VCA, MRDEM-30) then `03` (1 ha sieve, co_ff04)
- [x] Verification gate: report numbers IDENTICAL (tree loss 943.13 ha both, floodplain 171.0 km² both). Only delta = ~7 edge pixels / 0.004% VCA run-to-run noise (network feeding VCA is byte-identical -> not the fix). See findings.md.
- [x] **Decision (user): committed network was never incorrect -> REVERT ALL, record only.** Reverted `data/lulc` to committed v0.2.11; kept only the `01` link-version comment bump.

## Phases 3-5: NOT REQUIRED (no numeric change)
- [x] Phase 3 (report rebuild/version bump): moot — no report content changed. Recorded verification in memory + #152 close comment instead.
- [x] Phase 4 (Mergin push): moot — layers unchanged.
- [x] Phase 5 (recommendations app): moot — sub-basin numbers unchanged.

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

## Validation (revised — hypothesis was NOT confirmed; numbers unchanged)
- [x] `01` runs clean via `link` 0.44.1; `streams_co3` = 678.2 km UNCHANGED (fix does not reach order>=3 coho; gradient barriers on excluded order<3 fabric, falls survived)
- [x] `02`->`03` regenerate; floodplain km² + total tree loss IDENTICAL (943 ha, 171.0 km²); only 0.004% VCA run noise, not the fix
- [x] Report content unchanged -> no rebuild / version bump needed (recorded verification instead)
- [x] `/code-check` clean on the kept change (01 comment) + planning; PWF checkboxes match landed work
- [ ] `/planning-archive` on completion, then close #152 with the finding
