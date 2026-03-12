# Findings: Floodplain Scenario Modelling & Prioritization

**Purpose:** Research discoveries, ecological rationale, and technical details for issues #123 and #125.

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

---

## Stream Network Selection

**Decision:** Use `bcfishpass.streams_co_vw` (coho salmon potential habitat)

**Rationale:**
- Floodplain modelling is scoped to fish habitat restoration
- Coho view has 6,030 1st-order segments (1,832 km)
- Full streams table has 23,707 1st-order (8,713 km) — too broad
- Coho are the target species for off-channel rearing habitat

**Query used:**
```sql
SELECT stream_order, COUNT(*), SUM(length_metre)/1000 AS km
FROM bcfishpass.streams_co_vw
WHERE watershed_group_code = 'BULK'
GROUP BY stream_order ORDER BY stream_order;
```

---

## References by Scenario (to populate after Zotero search)

### Bankfull (flood_factor 1-2)
- Eaton et al. 2002 — BC bankfull regression
- Rosgen 1996 — channel classification

### Rearing (flood_factor 3-4)
- Beechie et al. 2005 — off-channel rearing
- Morley et al. 2005 — side-channel habitat
- Opperman et al. 2010 — floodplain connectivity

### Functional Floodplain (flood_factor 6)
- Beechie et al. 2010 — process-based restoration
- Cluer & Thorne 2014 — stage-0
- Roni et al. 2019 — floodplain reconnection

### Channel Migration Zone (flood_factor 8-12)
- Rapp & Abbe 2003 — CMZ methodology
- Montgomery et al. 2003 — LWD & channel complexity

### Cross-cutting
- Nagel et al. 2014 — VCA methodology
- Wheaton et al. 2019 — low-tech PBR
- Pollock et al. 2014 — beaver dam analogues
- Brandt 2005, Zhang & Montgomery 1994 — DEM resolution

---

## Exploitation Caveat (draft for Recommendations preamble)

Habitat restoration in the Neexdzii Kwah is necessary but not sufficient for salmon population recovery. NuSEDS escapement data for Bulkley chinook and coho show sustained declines that are consistent with exploitation rates exceeding what these populations can sustain — a pattern documented across Skeena stocks more broadly. Restoring floodplain function, reconnecting off-channel rearing habitat, and protecting riparian vegetation will increase the watershed's capacity to produce juvenile salmon. But whether improved freshwater production translates to more returning adults depends on marine survival and harvest management decisions that are outside the scope of this project. This framing is not a reason to delay restoration — degraded habitat compounds the effects of overexploitation, and rebuilding habitat capacity now is the prerequisite for population recovery when exploitation is eventually reduced. It is, however, a reason to be honest: the prioritization framework that follows identifies where and how to invest in habitat, but it cannot promise population recovery without parallel action on harvest.

---

## Discoveries Log

| Date | Finding | Source | Implications |
|------|---------|--------|--------------|
| 2026-03-11 | Precip term critical for bankfull — ~4x underestimate without MAP | Cloud conversation | Must use `map_upstream` in VCA |
| 2026-03-11 | streams_co_vw has 6,030 1st-order vs 23,707 full | DB query | Coho view is right scope |
| 2026-03-11 | flooded default flood_factor=6 = functional floodplain, NOT regulatory | Cloud conversation | Document clearly in methods |
