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

## Phase 1 results (2026-07-06) — HEADLINE: our extract is UNCHANGED by the fix

Re-ran `01_network_extract.R` under **`link` 0.44.1** (fix confirmed active — installed
`R/lnk_pipeline_prepare.R` feeds the FULL per-model gradient+falls union into
`gradient_barriers_minimal`, `frs_barriers_minimal()` no longer used as the break source;
BULK-wide segmentation grew — `id_segment` max 42307 → 86927, 55,970 GRADIENT break sources).

**The Neexdzii coho order≥3 accessible network is spatially IDENTICAL pre/post fix:**

| metric | link 0.43.0 (v0.2.11) | link 0.44.1 | delta |
|---|---|---|---|
| accessible km (order≥3, Neexdzii) | 678.18 | 678.18 | ~1e-14 (fp noise) |
| streams_co3 segments | 1936 | 1936 | 0 |
| blue_line_keys | 106 | 106 | 0 |
| per-BLK km deltas | — | — | all < 5e-5 km |

`id_segment` values changed (global re-sequence from the denser segmentation) but every
accessible reach covers the identical geometry. **Zero reaches flipped accessible→blocked.**

**Why our extract is protected (mechanism confirmed):**
- **Falls survived, exactly as hypothesized.** BULK-wide, CO-blocking natural barriers on
  order≥3 streams: 28 FALLS + 3213 GRADIENT; on order<3: 9 FALLS + 53,071 GRADIENT.
- **Gradient barriers concentrate on low-order steep streams** — 94% (53,071/56,284) of
  CO-blocking gradient barriers sit on streams below order 3, which our **order≥3
  floodplain-input threshold already excludes**. The over-credit link measured across all
  orders/species (+40% PCEA) lands overwhelmingly on that excluded low-order fabric.
- Where order≥3 gradient barriers do exist, they produced **no over-credited accessible
  reach in the Neexdzii order≥3 network** — proven directly by the byte-for-geometry identity
  above, not merely inferred.

**Conclusion:** the v0.2.11 floodplain-input network (coho, order≥3) is **not over-stated**;
the link#223 access fix does not change it. Therefore the floodplain extent, tree-loss
(746 ha), and per-sub-basin figures it drives are **unaffected** and require **no numeric
revision**. The `floodplain-numbers-provisional` memory can be resolved to "confirmed, not
provisional." Downstream Phases 2 (floodplain/LULC rerun), 4 (Mergin push), 5 (app rebuild)
are **not required** — their inputs are unchanged. Remaining value: (a) bump the `01` link
requirement + record this verification in NEWS at a patch version, (b) retire the provisional
memory flag.

**Regenerated `aquatic_network.gpkg`:** geometry-identical to committed, differs only in
`id_segment` labels → committing it would churn a 1.8 MB binary for no analytical change.
Recommend reverting it (keep the v0.2.11 file) unless we want the 0.44.1-provenance labels.

## Phase 2 results (2026-07-06) — full remodel from the corrected network

Per user direction ("store the correct network, remodel the floodplain, and PROVE identity —
don't assume"), regenerated `aquatic_network.gpkg` under link 0.44.1, backed up the committed
floodplain outputs, re-ran `02`→`03`, and content-compared new vs backup.

**Network (streams_co3) is geometrically IDENTICAL, not merely same-length:**
- 1936 segments both; **1812 distinct DRM breakpoints, `setequal` = TRUE**; total 678.1774 km both.
- Only the internal `id_segment` labels differ (global re-sequence from the denser BULK-wide
  segmentation). The exported order≥3 coho network is unchanged down to segment boundaries.

**Report-driving numbers IDENTICAL:**
- Total floodplain tree loss (transition_co_ff04, Trees→non-Trees, 1 ha-sieved): **943.13 ha
  old = 943.13 ha new** (Δ 0.000).
- Floodplain extent co_ff04: 171.0134 vs 171.0069 km² → **171.0 km² both** (appendix rounds 1 dp).

**Only difference found = pipeline run-to-run noise, NOT the fix:**
- floodplain.gpkg area co_ff04 17101.34 → 17100.69 ha (−0.65 ha, −0.004%); mask TIFs max|dz|=1
  on ~7 edge pixels; `lulc_summary.rds` mean rel. diff 0.026%. Classified + transition rasters
  identical where they overlap (max|dz|=0); transition layer same 2263 features.
- Since the network feeding VCA is byte-identical geometry, this Δ **cannot** come from
  link#223 — it is DEM re-fetch + VCA rasterization edge variance between runs. It rounds away
  from every reported figure.

**Revised conclusion:** the committed v0.2.11 `aquatic_network.gpkg` was **not incorrect** — its
order≥3 coho streams are geometrically identical to the 0.44.1 output. The link#223 fix does not
reach order≥3 coho reaches (gradient barriers live on the excluded low-order fabric; falls
govern order≥3 and always survived). No stored layer is wrong; no reported number changes. The
premise for replacing/remodelling ("we'd be storing an incorrect layer") does not hold here.

**Open decision (premise changed):** whether to (A) commit the regenerated network for 0.44.1
provenance despite identical geometry + keep committed floodplain (revert the 7-pixel noise),
(B) revert everything and just record the verification (nothing was incorrect — lowest churn),
or (C) commit both regenerated network + floodplain (accepts ~12 MB churn for 0.004% noise).
