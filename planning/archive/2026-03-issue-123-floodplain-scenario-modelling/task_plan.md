# Task Plan: Floodplain Scenario Modelling Pipeline

**Goal:** Build a multi-scenario floodplain modelling pipeline using `flooded` VCA at different `flood_factor` values, each representing a distinct ecological process. Research-first approach: add references to Zotero, semantic search to build rationale, then parameterize, run, and report.

**Status:** `in_progress`
**Created:** 2026-03-11
**Issue:** [#123](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/123)
**Branch:** `123-floodplain-refinement`
**SRED Tracking:** Relates to NewGraphEnvironment/sred-2025-2026#4

---

## Phase 1: Research & References
**Status:** `in_progress`

### 1.1 Add papers to Zotero (25 references) ✓ COMPLETE
Papers from cloud conversation covering:
- Off-channel habitat & floodplain connectivity
- Process-based restoration (NRCS, Beechie, Wheaton)
- LWD/beaver dam analogues
- Valley confinement & bankfull geometry
- Lidar resolution effects on flood modelling
- Fish habitat & salmon lifecycle

**Reference list (DOIs from cloud conversation):**

| # | Key topic | First author | Year | Zotero key | Status |
|---|-----------|-------------|------|------------|--------|
| 1 | Off-channel rearing | Beechie et al. | 2005 | V5TB9WSZ | [x] in Zotero (pre-existing) |
| 2 | Floodplain connectivity | Opperman et al. | 2010 | JIT4EFQ9 | [x] PDF attached |
| 3 | Side-channel habitat | Morley et al. | 2005 | 7INMABI2 | [x] in Zotero (pre-existing) |
| 4 | Process-based restoration | Beechie et al. | 2010 | 9ZU9P92W | [x] in Zotero (pre-existing) |
| 5 | Low-tech PBR | Wheaton et al. | 2019 | MYHDLARR | [x] in Zotero (pre-existing) |
| 6 | Stage-0 restoration | Cluer & Thorne | 2014 | KN976MGF | [x] in Zotero (pre-existing) |
| 7 | Floodplain reconnection | Roni et al. | 2019 | UA7RI236 | [x] in Zotero (pre-existing) |
| 8 | Beaver dam analogues | Pollock et al. | 2014 | 43UKF3PG | [x] in Zotero (pre-existing) |
| 9 | Valley confinement algo | Nagel et al. | 2014 | TE78VAJT | [x] PDF attached |
| 10 | VCA implementation | Gilbert et al. | 2016 | AF4WVTDV | [x] URL + abstract |
| 11 | Bankfull regression PNW | Hall et al. | 2007 | WP79Z9X7 | [x] URL + abstract |
| 12 | Channel migration zones | Rapp & Abbe | 2003 | Z7CMN8ME | [x] PDF attached |
| 13 | DEM resolution effects | Zhang & Montgomery | 1994 | 4HMFR6VL | [x] in Zotero (pre-existing) |
| 14 | DEM flood sensitivity | Dakin Kuiper et al. | 2022 | 7HMBEIT2 | [x] URL + abstract |
| 15 | Fish barriers & connectivity | Kemp & O'Hanley | 2010 | 5AUDDRAR | [x] in Zotero (pre-existing) |
| 16 | Side-channel productivity | Rosenfeld et al. | 2008 | 28GANINW | [x] PDF attached |
| 17 | Coho smolt production | Knox et al. | 2022 | FZ37XRI8 | [x] URL + abstract |
| 18 | Process-based principles | Beechie et al. | 2013 | W3ICV3R9 | [x] URL + abstract |
| 19 | Restoration + population | Beechie et al. | 2023 | ZRE4Z65R | [x] URL + abstract |
| 20 | Floodplain restoration | Beechie et al. | 2021 | ST2KZK8G | [x] PDF attached |
| 21 | WDFW side channels | WDFW | 2009 | 4CUNR42Z | [x] PDF attached |
| 22 | Floodplain mapping | Fogel et al. | 2022 | 8MQCQAEX | [x] PDF attached |
| 23 | Landscape change + fish | Aristizabal et al. | 2024 | TB7NN94Z | [x] PDF attached |
| 24 | Juvenile salmon habitat | Sommer et al. | 2001 | ZQAM35LS | [x] in Zotero (pre-existing) |
| 25 | Floodplain rearing | Katz et al. | 2017 | GFGBG2AT | [x] in Zotero (pre-existing) |

### 1.2 Semantic search for ecological rationale
- [ ] Search Zotero for each scenario's ecological basis
- [ ] Build citation strings for each `flood_factor` level
- [ ] Document rationale in findings.md

---

## Phase 2: Scenario CSV Design
**Status:** `pending`

### 2.1 Create `data/floodplain_scenarios.csv`
Columns: `scenario_id`, `flood_factor`, `ecological_process`, `description`, `citations`, `stream_filter`

Planned scenarios:
| scenario_id | flood_factor | ecological_process |
|-------------|-------------|-------------------|
| bankfull | 1-2 | Active channel / bankfull extent |
| rearing | 3-4 | Off-channel rearing habitat |
| functional | 6 | Functional floodplain / active valley flat |
| migration | 8-12 | Channel migration zone |

### 2.2 Parameterize from CSV
- [ ] Update `scripts/lulc_network-extract.R` to read scenarios CSV
- [ ] Loop VCA over each `flood_factor`
- [ ] Use `bcfishpass.streams_co_vw` (coho potential habitat)
- [ ] Switch to order >= 3 for VCA / order >= 1 for anchors

---

## Phase 3: Run VCA Scenarios
**Status:** `pending`

- [ ] Run flooded VCA for each scenario
- [ ] Export layers to GIS project
- [ ] Validate against known features (e.g., Bulkley floodplain extent)

---

## Phase 4: LULC Change Detection
**Status:** `pending`

- [ ] Run drift classification per scenario AOI
- [ ] Compare land cover change across nested zones
- [ ] Generate summary statistics

---

## Phase 5: Report Integration
**Status:** `pending`

- [ ] Update methods: describe nested scenario approach
- [ ] Fix "watershed picker" → break points reference
- [ ] Document FWA input (streams_co_vw)
- [ ] Update results: summary table of scenarios
- [ ] Update appendix 2043 with new figures

---

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| (none yet) | | |

---

## Key Technical Notes

- **VCA bankfull regression:** `bankfull_depth = (upstream_area^0.280 * 0.196 * precip^0.355)^0.607 * 0.145`
- **Precipitation critical:** Without real MAP from `map_upstream`, flood depth underestimated ~4x on Bulkley
- **Stream network:** `streams_co_vw` = 6,030 1st-order segments (1,832 km) — scoped to coho potential habitat
- **DB tunnel:** localhost:63333 → bcfishpass/fwapg
- **Reminder:** Run `claude mcp remove db-newgraph` when done
