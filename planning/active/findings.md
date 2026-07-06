# Findings — Rerun coho network + floodplain LULC with `link` 0.44.1 (#152)

## Issue context

The v0.2.11 floodplain/LULC numbers were built with `link` 0.43.0, which carried the
access-segmentation over-credit bug fixed in NewGraphEnvironment/link#228 (closing link#223),
released in `link` 0.44.1.

Pre-fix, the per-model gradient + falls barriers were reduced to the downstream-most per path
(`fresh::frs_barriers_minimal`) and used as the segmentation source, so the network broke at
only one frontier per path:

- **Falls** (Bulkley/Buck) sit low -> usually the downstream-most -> survived -> above-falls
  stayed correctly blocked (the report's below-falls framing holds).
- **Gradient barriers > 15%** are dense and upstream -> dropped -> reaches above them were
  over-credited as coho-accessible.

Net effect: the coho accessible network (678 km) and the floodplain it drives (headline
746 ha tree loss) are likely over-stated. Follows #148.

## Pre-work exploration (2026-07-06)

- **No `01` logic change needed.** `scripts/floodplain_lcc/01_network_extract.R` already reads
  `neexdzii.streams JOIN neexdzii.streams_access ON access_co IN (1,2)`. The fix lives entirely
  inside `link` (`R/lnk_pipeline_prepare.R`, 0.44.0): it unions the raw per-model gradient +
  falls positions into `gradient_barriers_minimal` so streams break at every frontier, matching
  bcfishpass; `fresh::frs_barriers_minimal()` is now unused. Post-fix, above-gradient reaches
  get `access_co = 0` and drop from the exported `streams_co3`. Only the line-18 version comment
  needs bumping.
- **Report numbers are computed, not hardcoded** — exec summary (`total_loss_exec`,
  `max_loss_pct_exec`), results, LULC appendix (`st_area(floodplain)`, `lulc_summary.rds`,
  `transition_co_ff04_2017_2023`) all read `data/lulc/*`. Rerun + `scripts/run.R` refreshes them.
- **link changelog:** 0.44.0 = the #223 fix (`accessible_km` +40.4% PCEA / +23.6% FINA pre-fix;
  habitat-neutral, byte-identical spawn/rear; segment count grows 2-3.5x). 0.44.1 = PARS vignette
  `accessible_km` demo only. Minimum needed is 0.44.0; installing link main gets 0.44.1.
- **Prereqs on M1:** local fwapg (libpq env vars) for `01`; MRDEM-30 via `flooded::fl_dem_aoi()`
  + fwapg for `02`; Microsoft PC STAC for `03`. Pipeline last ran green here 2026-07-02.
- Current committed `data/lulc/aquatic_network.gpkg` IS the link-0.43.0 (over-credited) network —
  copy aside before rerun to serve as the Phase 1 before-baseline.

## Phase 1 results

_(to be filled: new segment count, accessible km, delta vs 678, barrier-type classification)_

## Phase 2 results

_(to be filled: floodplain km², total tree loss vs 746 ha, per-sub-basin deltas)_
