# Progress — Rerun coho network + floodplain LULC with `link` 0.44.1 (#152)

## Session 2026-07-06

- Plan-mode exploration — confirmed the fix is entirely inside `link` (no `01` logic change),
  report numbers are computed from `data/lulc/*` (auto-refresh on rebuild), prereqs satisfied
  on M1. Phases approved by user.
- Created branch `152-rerun-coho-network-floodplain-lulc-with-l` off main
- Scaffolded PWF baseline from issue #152 with approved phases
- Phase 1 DONE — installed link 0.44.1 (fix confirmed active), re-ran `01`. Network is
  spatially IDENTICAL pre/post fix (678.2 km, 106 BLKs, per-BLK delta <5e-5 km). Mechanism:
  94% of CO-blocking gradient barriers sit on order<3 streams excluded by our order>=3 filter;
  falls (order>=3 governing barriers) survived pre-fix as hypothesized. Reverted the
  regenerated gpkg (geometry-identical, only id_segment labels differ — no churn). Kept the
  `01` link-version comment bump.
- PIVOT: no numeric correction needed. Phases 2 (floodplain/LULC rerun), 4 (Mergin), 5 (app)
  are moot — inputs unchanged. Awaiting user decision on how to close: patch-version NEWS
  entry recording the verification + retire the provisional memory flag.
- Phase 2 DONE — full remodel from the corrected 0.44.1 network. Network geometrically
  IDENTICAL to committed (1812 breakpoints setequal=TRUE, 678.1774 km; only id_segment labels
  differ). `02`->`03` report numbers IDENTICAL (tree loss 943.13 ha, floodplain 171.0 km²); only
  ~7-pixel / 0.004% VCA run-to-run noise, not the fix. Committed network was never incorrect.
- User decision: REVERT ALL, record only. Reverted `data/lulc`; kept `01` link-version comment.
  Memory `floodplain-numbers-provisional` -> renamed `floodplain-numbers-verified` (RESOLVED).
- Phases 3-5 moot (no numeric change). Next: commit, planning-archive, close #152 with finding.
