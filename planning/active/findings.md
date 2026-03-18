# Findings: Multi-Scenario Floodplain Modelling & Zone-Stratified LULC

**Purpose:** Research discoveries, ecological rationale, and technical details for #123.

---

## Ecological Basis for Nested Flood Zones

### flood_factor = 1-2 (Bankfull)
Active channel extent. Where water goes during ~1.5-2 year recurrence flow. Defines the channel itself and immediate riparian fringe. Baseline for understanding channel capacity.

### flood_factor = 3-4 (Off-channel Rearing)
Alcoves, side channels, floodplain ponds that activate at moderate flows. Critical for juvenile salmon (especially coho) overwinter rearing. These habitats are disproportionately productive — small areas support large numbers of juveniles.

### flood_factor = 6 (Functional Floodplain)
Active valley flat / functional floodplain. Where the river does its geomorphic work — sediment storage, nutrient exchange, riparian recruitment. This is the default `flood_factor` in flooded and represents the restoration target zone.

### flood_factor = 8-12 (Channel Migration Zone)
Historic and potential future channel positions. Where the river has been and could go over decades to centuries. Important for long-term planning — infrastructure in this zone is at risk; restoration here has highest potential for self-sustaining outcomes.

**Important:** The mapping of specific flood_factor values to ecological processes is our interpretive framework informed by literature, not empirically calibrated thresholds. Methods text must be clear about this.

---

## References by Scenario

### Bankfull (flood_factor 1-2)
- `@hall_etal2007Predictingriver` — PNW bankfull regression (drainage area + MAP → depth/width)
- `@davies_etal2007ModelingStream` — DEM-derived channel characteristics, Puget Sound
- `@beechie_imaki2014Predictingnatural` — channel pattern prediction from slope, discharge, confinement
- `@bair_etal2021newdatadriven` — height-above-river zonation for riparian design (detrended DEM)

### Rearing (flood_factor 3-4)
- `@rosenfeld_etal2008EffectsSide` — side channel structure → coho productivity (Chilliwack R.)
- `@morley_etal2005Juvenilesalmonid` — constructed/natural side channel use by juvenile salmonids
- `@beechie_etal2005ClassificationHabitat` — large river habitat types and juvenile salmonid use
- `@sommer_etal2001Floodplainrearing` — floodplain rearing = enhanced growth/survival (Sacramento)
- `@katz_etal2017Floodplainfarm` — farm fields as novel rearing habitat when inundated
- `@knox_etal2022Leveesdont` — levees disconnect floodplains; coho smolt production comparison

### Functional Floodplain (flood_factor 6)
- `@opperman_etal2010EcologicallyFunctional` — ecologically functional floodplains: connectivity, flow regime, scale
- `@beechie_etal2010ProcessbasedPrinciples` — process-based restoration principles
- `@cluer_thorne2014StreamEvolution` — stream evolution model (Stage 0)
- `@hauer_etal2016Gravelbedriver` — gravel-bed floodplains as ecological nexus
- `@fogel_etal2022Howriparian` — riparian condition mapping

### Channel Migration Zone (flood_factor 8-12)
- `@rapp_abbe2003FrameworkDelineating` — CMZ delineation framework (WDFW)
- `@obrien_etal2019Mappingvalley` — network-scale confinement mapping
- `@wheaton_etal2019LowTechProcessBased` — low-tech PBR design manual (valley-scale thinking)

### VCA Methodology (cross-cutting)
- `@nagel_etal2014LandscapeScale` — original VCA algorithm
- `@gilbert_etal2016ValleyBottom` — V-BET implementation of VCA
- `@gallant_dowling2003multiresolutionindex` — MRVBF (multiresolution valley bottom flatness)
- `@zhang_montgomery1994Digitalelevation` — DEM resolution effects on terrain analysis
- `@dakinkuiper_etal2022Characterizingstream` — DEM resolution sensitivity for fish habitat/flood mapping
- `@pollock_etal2014UsingBeaver` — beaver dam analogues (connectivity restoration)

### VCA Parameter Rationale (sourced from Nagel et al. 2014 RMRS-GTR-321 fulltext)

#### `flood_factor` (we use 1-12; Nagel default = 5)

The flood factor is a **dimensionless multiplier on predicted bankfull depth**. It has no direct ecological meaning — it's a DEM compensation parameter.

From Nagel 2014:
> "Rosgen (1994, 1996) defined the flood prone extent of a valley as the width measured at an elevation twice the maximum bankfull depth. This value roughly corresponded with the 50-year flood stage or less."

> "Using 10-m DEM data, Hall and others (2007) found that an elevation of **three times the bankfull depth** provided the best results for estimating the historical floodplain width."

> "Clarke and others (2008) used a factor of **five times** the bankfull depth to estimate the elevation for measuring valley-floor width when using 10-m DEM data."

> "The VCA flood factor parameter **defaults to a value of 5**; however, a value of **5-7 is recommended** based on the user's familiarity with the terrain and field observations."

> "Comparison of predicted and observed valley extent for field sites in central Idaho indicates that **a flood factor of seven is most appropriate for 30-m DEMs**. The coarser vertical resolution of 30-m DEMs relative to 10-m data requires a larger flood factor (7 vs. 5) to obtain similar results."

**Our interpretation:** We use ff=1-12 to define nested ecological zones. This is **our interpretive framework** — no paper maps specific flood_factor values to ecological processes. The literature establishes that:
- ff=2 ≈ Rosgen flood-prone width (≈50-yr flood)
- ff=3 = Hall's best fit for historical floodplain (10m DEM)
- ff=5-7 = Nagel's recommended range for valley bottom delineation
- Our ff=6 default aligns with Nagel's recommendation for functional valley bottom

#### `slope_threshold` (we use 9; Nagel default = 9%)

**CORRECTION: This is 9% slope, NOT 9 degrees.** 9% = ~5.1°.

From Nagel 2014:
> "A default **slope threshold of 9%** [is used]."

> "The **9% ground slope threshold was chosen based on empirical evidence** indicating that slopes less than 9% in the DEM likely correspond to unconfined valleys."

Need to verify: does `fl_valley_confine()` in flooded expect percent or degrees? If degrees, our 9 is actually ~15.6% — substantially different from Nagel's 9%.

#### `cost_threshold` (we use 2500; Nagel default = 2500)

From Nagel 2014:
> "A slope cost distance threshold of **2,500** adequately captures an initial valley bottom domain that can be refined by further processing. **This variable has no physical meaning** and is simply an empirical rule that is used to set the initial processing domain for subsequent operations in the algorithm."

> "The variable is intended to capture a relatively low-sloped domain near the stream network and eliminate low slope features outside of valleys."

This is a processing parameter, not an ecological one. No unit — it's cost-weighted distance (slope × distance).

#### `max_width` (we use 2000m; Nagel examples use 500-1000m)

From Nagel 2014:
> "This parameter allows the user to select a width (m) for clipping the extent of the valley floor orthogonal to the channel."

Nagel's examples use **500m and 1000m**. We use 2000m — double their maximum example. This is a project decision to ensure wide valleys like the Bulkley mainstem are fully captured. Should document why.

> "The 1000 m maximum width is an arbitrary measure."

#### `size_threshold` (we use 5000 cells; Nagel uses 10,000 m²)

From Nagel 2014:
> "The minimum polygon **size threshold was set at an arbitrary size of 10,000 m², equal to 1 HA.**"

Note: Nagel specifies area (m²), not cell count. Our 5000 cells at 25m resolution = 5000 × 625 m² = 3,125,000 m² = 312.5 ha. This is vastly different from Nagel's 1 ha. Need to check what flooded's `size_threshold` parameter actually means — cells vs area.

#### `hole_threshold` (we use 2500; not in Nagel 2014)

This parameter is **not from Nagel 2014** — it's a flooded-specific addition for filling holes in the floodplain polygon. Need to document its origin and units.

#### `precip` (MAP raster)

From Nagel 2014:
> "An average annual precipitation value equal to the highest estimate in the watershed is recommended. Using the highest estimate will produce a more liberal valley bottom extent."

The bankfull equation is from Hall et al. (2007): **h_bf = 0.054 × A^0.170 × P^0.215**

Where A = upstream drainage area, P = mean annual precipitation (cm/yr).

**VERIFIED from Hall et al. 2007 (JAWRA, purchased PDF):**
- Bankfull width: `W_b = 0.196 × A^0.280 × P^0.355` (R² = 0.47, p < 0.001, n = 1,951 field measurements, Columbia River basin)
- Bankfull depth: `H_b = 0.145 × W_b^0.607` (from upper Salmon River basin, Knighton 1998)
- Combined (as Nagel cites): `h_bf = 0.054 × A^0.170 × P^0.215` — confirmed by substitution
- A = drainage area (km²), P = mean annual precipitation (cm/yr)
- **Three times bankfull depth** gave best agreement with historical floodplain width (213 field validation sites)
- R² = 0.47 is moderate — width equation has considerable scatter. Not calibrated for BC interior.
- Depth equation is from upper Salmon River only — one basin in Idaho, not regional.

**Implication for flooded:** The bankfull regression is a PNW equation applied to BC. This is standard practice (no BC-specific regional equations exist for this) but should be stated clearly in methods. The moderate R² means our floodplain extents have inherent uncertainty from the bankfull prediction alone, before flood_factor amplifies it.

#### `min_order` (we use 3) and `anchor_order` (we use 1)

**Project decisions, not from literature.** min_order=3 scopes to streams with coho potential habitat. anchor_order=1 is intended for patch connectivity but is not yet wired into flooded.

### Summary: What's Literature vs What's Ours

| Parameter | Source | Confidence |
|-----------|--------|-----------|
| Bankfull equation (h_bf) | Hall et al. 2007 via Nagel 2014 | **Medium** — equation confirmed in Nagel fulltext but Hall PDF not verified |
| slope_threshold = 9% | Nagel 2014 empirical | **High** — direct quote with rationale. BUT: verify flooded uses % not degrees |
| cost_threshold = 2500 | Nagel 2014 empirical | **High** — direct quote. No physical meaning, processing parameter only |
| flood_factor defaults (5-7) | Nagel 2014, referencing Rosgen, Hall, Clarke | **High** — multiple sources cited with specific values |
| flood_factor = 1-12 as ecological zones | **OUR FRAMEWORK** | **Interpretive** — no paper maps ff values to ecological processes |
| max_width = 2000m | **OUR CHOICE** | Nagel uses 500-1000m. We doubled for Bulkley mainstem |
| size_threshold = 5000 | 5,000 m² (0.5 ha) — flooded default | Nagel uses 10,000 m² (1 ha). Ours is half — reasonable for higher-res |
| hole_threshold = 2500 | 2,500 m² (0.25 ha) — flooded-specific | Not from Nagel 2014. Fills small holes in floodplain polygon |
| min_order = 3 | **PROJECT DECISION** | Coho habitat scope |
| anchor_order = 1 | **PROJECT DECISION** | Not yet functional in flooded |

### Verification Status (all checked 2026-03-17)

- [x] `slope_threshold` is percent slope — confirmed from flooded source (roxygen line 13 + computation lines 136-137)
- [x] `size_threshold` is area in m² — confirmed (line 182: `fl_patch_rm(min_area=)`, line 173: `count * cell_area`)
- [x] `hole_threshold` is area in m² — confirmed (line 173: `count * cell_area < hole_threshold`). Flooded-specific, not Nagel
- [x] Hall 2007 bankfull equation verified from purchased PDF — coefficients match Nagel's citation
- [x] Hall 2007 Zotero abstract fixed — replaced with real CrossRef abstract
- [x] Gilbert 2016 Zotero abstract fixed — cleared fabricated abstract (no real one on CrossRef)
- [x] Dakin Kuiper 2022 Zotero abstract fixed — cleared fabricated abstract
- [x] Rosenfeld 2008 Zotero abstract fixed — replaced with real CrossRef abstract (numbers were correct)
- [x] Knox 2022 Zotero abstract fixed by user — had wrong paper's abstract

---

## Prior Session References (25 items in Zotero, March 2026)

See archived planning: `planning/archive/2026-03-issue-123-floodplain-scenario-modelling/task_plan.md` for the full reference list with Zotero item keys.

---

## Exploitation Caveat (draft for Recommendations preamble)

Habitat restoration in the Neexdzii Kwah is necessary but not sufficient for salmon population recovery. NuSEDS escapement data for Bulkley chinook and coho show sustained declines that are consistent with exploitation rates exceeding what these populations can sustain — a pattern documented across Skeena stocks more broadly. Restoring floodplain function, reconnecting off-channel rearing habitat, and protecting riparian vegetation will increase the watershed's capacity to produce juvenile salmon. But whether improved freshwater production translates to more returning adults depends on marine survival and harvest management decisions that are outside the scope of this project. This framing is not a reason to delay restoration — degraded habitat compounds the effects of overexploitation, and rebuilding habitat capacity now is the prerequisite for population recovery when exploitation is eventually reduced. It is, however, a reason to be honest: the prioritization framework that follows identifies where and how to invest in habitat, but it cannot promise population recovery without parallel action on harvest.

---

## Fisheries Connection: Zone × LULC

| Flood zone | Ecological process | Fisheries connection | LULC signal |
|-----------|-------------------|---------------------|-------------|
| ff 1-2 (bankfull) | Active channel / riparian margin | Shade, LWD recruitment, bank stability — spawning habitat quality | Tree loss at channel margin |
| ff 3-4 (off-channel rearing) | Side channels, alcoves, floodplain ponds | Juvenile coho overwinter rearing — disproportionately productive per unit area | Tree to agriculture in rearing zone = direct habitat loss |
| ff 6 (functional floodplain) | Geomorphic work zone | Habitat-forming processes over decades; current default | Broad vegetation trend |
| ff 8-12 (channel migration) | Historic/future channel positions | Long-term side channel formation potential | Infrastructure/agriculture in migration path |

---

## Discoveries Log

| Date | Finding | Source | Implications |
|------|---------|--------|--------------|
| 2026-03-11 | Precip term critical for bankfull — ~4x underestimate without MAP | Cloud conversation | Must use `map_upstream` in VCA |
| 2026-03-11 | streams_co_vw has 6,030 1st-order vs 23,707 full | DB query | Coho view is right scope |
| 2026-03-11 | flooded default flood_factor=6 = functional floodplain, NOT regulatory | Cloud conversation | Document clearly in methods |
| 2026-03-17 | drift needs `dft_rast_zonal()` — no native zone support in summarize | Package review | New function in drift, not project workaround |
| 2026-03-17 | fresh `frs_point_snap()` + `frs_network()` with upstream_measure supports site-level reach extraction | Package review | Ready for Phase 5 site pipeline |
| 2026-03-17 | 1m LiDAR via stac_dem_bc — site-specific, not full sub-basins | Design decision | 200-1000m reaches, 2-3 pilot sites |
| 2026-03-17 | VCA params (slope_threshold, cost_threshold, etc.) are Nagel 2014 PNW defaults — not calibrated for BC interior | Literature review | State clearly in methods; flooded#28 tracks upstream documentation |
| 2026-03-17 | Bair et al. 2021 — height-above-river (detrended DEM) drives vegetation zonation. Conceptually validates using flood_factor as ecological zone proxy | Zotero semantic search | Strongest direct support for our depth-multiplier → zone mapping |
| 2026-03-17 | 27 BBT citation keys resolved for all 6 scenarios + VCA methodology | Zotero lookup | flood_scenarios.csv updated with citations column |
| 2026-03-17 | Hall 2007 bankfull width R²=0.47 (n=1951) — moderate fit, considerable scatter | Hall 2007 PDF | Bankfull prediction has inherent uncertainty; state in methods |
| 2026-03-17 | Hall bankfull depth eq from upper Salmon R. only (one basin in Idaho) | Hall 2007 PDF | Not a regional depth equation — transferred from a single basin |
| 2026-03-17 | flooded `size_threshold` is m² not cells; 5000 m² = 0.5 ha (half of Nagel's 1 ha) | flooded source | Correct as-is; document in flooded#28 |
| 2026-03-17 | flooded `hole_threshold` is m² and is flooded-specific (not from Nagel) | flooded source | Document origin in flooded#28 |
| 2026-03-17 | 5 fabricated Zotero abstracts found and fixed (Hall, Gilbert, Dakin Kuiper, Rosenfeld, Knox) | Zotero audit | LLM-generated abstracts in shared library — cred#22 ragnar integration will prevent this |
| 2026-03-17 | ragnar + Ollama store built (14 PDFs, 2464 chunks) — first successful use for parameter verification | ragnar POC | Document workflow in soul skill, integrate into cred |
