# Progress Log: Floodplain Scenario Modelling Pipeline

**Issue:** #123
**Branch:** `123-floodplain-refinement`

---

## Session: 2026-03-11 — Research & Setup

### Completed (prior session)
- [x] Branched `123-floodplain-refinement`
- [x] Queried stream counts from `bcfishpass.streams` and `streams_co_vw`
- [x] Decided on coho view for stream network input
- [x] Read existing scripts: `lulc_network-extract.R`, `lulc_classify.R`
- [x] Bumped version to 0.1.9, rebuilt, pushed (separate from floodplain work)
- [x] Read cloud conversation about flooded ecological modelling
- [x] Identified ~17 references to add to Zotero

### Completed (this session)
- [x] Phase 1.1: 25 references in Zotero — 10 pre-existing, 8 with PDFs attached, 7 with URLs + abstracts
- [x] Attached Rosenfeld 2008 PDF from Downloads
- [x] Updated 7 items (Beechie 2013, Beechie 2023, Knox 2022, Hall 2007, Gilbert 2016, Dakin Kuiper 2022, Rosenfeld 2008) with DOI URLs and abstracts
- [x] Deleted confabulated DOI items (user cleaned up 7 wrong entries)
- [x] Corrected reference list: dropped Eaton 2002 (bankfull regression is Hall 2007 / Nagel 2014), added Gilbert 2016, Dakin Kuiper 2022, Knox 2022, Beechie 2013/2021/2023, Aristizabal 2024, Fogel 2022, WDFW 2009

### In Progress
- [ ] Phase 1.2: Semantic search for ecological rationale per scenario

### Next Steps
- Build citation rationale per flood_factor level using Zotero semantic search
- Design scenarios CSV
- Restart Zotero to generate BBT citation keys for new items

---

## Session: 2026-03-12 — Governance & Prioritization Framework

### Completed
- [x] Created issue #125: Governance framework and prioritization principles
  - Four-tier governance structure (Stewardship Council, Technical WG, Implementation, Community Roundtable)
  - Scoring principles (root-cause, scale, passive-first, viability, net benefit, Wet'suwet'en stewardship, learning)
  - Ian's 4-bucket delivery complexity framework
  - Workshop parameter rankings (Wet'suwet'en June 23 + Landowner June 24)
  - Integration path with existing `prioritize.R` spatial scoring
- [x] Designed two-level prioritization framework (area + project)
  - Area level: sub-basin scoring with drift tree loss as empirical input
  - Project level: gates (diagnostic certainty, active degradation, access) + scoring dimensions
  - Active degradation check prevents perverse incentive of funding restoration alongside ongoing clearing
- [x] Built `scripts/prioritization_build.R` — generates CSVs from existing outputs
- [x] Generated `data/prioritization/area_scores.csv` — 9 sub-basins with drift-derived tree loss, floodplain area, barrier position
- [x] Generated `data/prioritization/project_scores.csv` — 208 sites with GIS scores + governance framework scaffold
- [x] Updated issue #125 with concrete CSV implementation details

### Sub-basin split & re-run (completed 2026-03-12)
- [x] User split lower Bulkley from 2 to 5 reaches via breaks app + added Maxan Lake, Foxy Creek
- [x] break_points.csv now 14 rows (was 10): ids 1-10, 12-15
- [x] Regenerated subbasins.gpkg via `fresh::frs_watershed_split(bp)` (no AOI needed)
- [x] Re-ran `lulc_classify.R` with 14 sub-basins (Foxy Creek skipped — no floodplain overlap)
- [x] Fixed barrier_position lookup in `prioritization_build.R` for new sub-basin names
- [x] Regenerated both CSVs — 14 sub-basins, 208 sites, all positions filled
- [x] Created issue #126: Historic air photo integration via STAC airphoto collection
- [x] Updated issue #123 with nested zones × LULC fisheries-specific change detection
- [x] Sketched `scripts/lulc_classify_zones.R` for zone-stratified analysis (pending #123 Phase 3)
- [x] Drafted exploitation caveat in findings.md

### Key findings from drift data (14 sub-basins)
- Aitken Creek: -24.7% tree loss (worst rate)
- Bulkley Byman-JDavid: -14.9% (worst middle reach — confirms hypothesis)
- Bulkley Richfield-Falls: -11.9%
- Bulkley Houston-McKilligan: -11.3%
- Bulkley-Houston: -6.2% (most stable below falls — confirms close-to-town hypothesis)
- Buck Creek below falls: -4.6% (relatively stable)
- Foxy Creek: NA (no floodplain overlap)

### Next Steps
- [ ] Rebuild report with updated lulc_summary.rds (14 sub-basins)
- [ ] Draft model prescription for report (50m setback, 1.5m spacing, mulch, LWD, 2yr irrigation)
- [ ] Score 2-3 example sites through framework as illustrations
- [ ] Move exploitation caveat from findings.md into Recommendations chapter
- [ ] Add `frs_watershed_split` wrapper script to this repo's workflow
- [ ] Populate manual scoring columns in area_scores.csv (Stewardship Council input needed)
