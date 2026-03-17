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

## References by Scenario (to populate in Phase 1)

### Bankfull (flood_factor 1-2)
- (BBT keys TBD after Zotero search)

### Rearing (flood_factor 3-4)
- (BBT keys TBD)

### Functional Floodplain (flood_factor 6)
- (BBT keys TBD)

### Channel Migration Zone (flood_factor 8-12)
- (BBT keys TBD)

### Cross-cutting
- (BBT keys TBD)

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
