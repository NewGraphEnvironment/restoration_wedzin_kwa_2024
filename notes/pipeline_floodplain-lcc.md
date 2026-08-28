# Floodplain land cover change pipeline — operational notes

Companion to the pipeline table in `CLAUDE.md` and the script-level README at
`scripts/floodplain_lcc/README.md`. Those cover *what each script does*. This covers the
decisions and traps that are not visible from reading the code.

## `area_ha` is pre-intersection — recompute it

`drift::dft_transition_vectors(zones = ..., zone_col = ...)` computes `area_ha` from
`sf::st_area()` on the **pre-intersection** patch polygons, then intersects with zones
afterward. A 100 ha patch straddling two sub-basins becomes two rows, **both carrying
`area_ha = 100`**. Summing rows gives 200 ha.

Always recompute from geometry after the call:

```r
patches$area_ha <- as.numeric(sf::st_area(patches)) / 1e4
```

Applied in `scripts/floodplain_lcc/03_lulc_classify.R` and `inspect_sieve_thresholds.R`.

Found 2026-05-13 while wiring the sieve threshold inspection (#142): the inspection reported
976.8 ha gross Trees→non-Trees while the underlying sieved raster (`terra::freq` × pixel area)
said 899.7 ha. The ~77 ha gap was boundary-straddle double counting. The fix belongs upstream
in drift — worth filing there when convenient.

## Sieve threshold — why 1 ha

`03_lulc_classify.R` applies `dft_rast_transition(patch_area_min = 10000)`, dropping transition
patches under 1 ha to suppress class-boundary noise from sub-pixel registration drift between
years. The threshold was chosen by rendering 0.5 ha (the BC VRI minimum mapping unit) and 1.0 ha
layers in QGIS during v0.2.9 prep and comparing them visually.

`scripts/floodplain_lcc/inspect_sieve_thresholds.R` re-runs that comparison.

Sieving matters to the headline number: net floodplain tree loss 2017–2023 is roughly 746 ha in
patches ≥ 1 ha, against roughly 758 ha for the unsieved class delta. Do not quote either figure
from here — the report derives it inline from `floodplain_landcover.gpkg` so prose and tables
cannot drift apart.

## QGIS promotion is deliberate, not automatic

Scripts `01` and `02` copy their gpkg outputs to `params$path_gis` automatically. Script `03`
is gated behind a `copy_to_qgis` flag defaulting to `FALSE`, so re-running the classification
never silently overwrites live QGIS data mid-session. Promotion is a manual `cp`.

## Scenarios

Three nested flood factors: `ff=2` channel margin, `ff=4` functional floodplain, `ff=6` valley
bottom. `ff=4` is what the report uses. For reference, `ff=3` approximates Hall's historical
floodplain on a 10 m DEM.

The floodplain extent is scoped conservatively — coho-accessible streams of 3rd order and
larger, with lakes and wetlands included only where they connect to the fish-accessible network.
