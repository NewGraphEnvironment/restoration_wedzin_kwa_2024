# Archived: Multi-scenario floodplain modelling pipeline (#123)

**Created:** 2026-03-17 · **Archived:** 2026-06-08 · **Branch:** `123-floodplain-refinement`

## Outcome

Archived without formal PWF completion. The core of this work **shipped** through later commits:
floodplain modelling at `flood_factor=4` and sieved (>=1 ha) LULC change detection landed via
[#142](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/142) /
[#146](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/pull/146) (v0.2.9).

The later phases — `dft_rast_zonal()` zone-stratified LULC and the 1 m LiDAR site-specific
restoration design maps — were **not completed** in this cycle.

**Issue #123 remains OPEN** for those outstanding zonal / LiDAR-pilot phases.

Superseded for the immediate LULC work by
[#147](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/147)
(reproducible build: national DEM + Mergin-synced GIS), tracked on branch
`lulc-appendix-streamline`.
