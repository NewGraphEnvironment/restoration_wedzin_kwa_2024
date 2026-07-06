# Progress — Rerun coho network + floodplain LULC with `link` 0.44.1 (#152)

## Session 2026-07-06

- Plan-mode exploration — confirmed the fix is entirely inside `link` (no `01` logic change),
  report numbers are computed from `data/lulc/*` (auto-refresh on rebuild), prereqs satisfied
  on M1. Phases approved by user.
- Created branch `152-rerun-coho-network-floodplain-lulc-with-l` off main
- Scaffolded PWF baseline from issue #152 with approved phases
- Next: start Phase 1 — copy the 0.43.0 network aside, install link >= 0.44.1, re-run `01`
