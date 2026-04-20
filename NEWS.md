
# restoration_wedzin_kwa_2024 DRAFT 0.2.8 (2026-04-20)

- correct chinook exploitation scoping in background: Wedzin Kwa (Morice) vs Neexdzii Kwa treated as distinct populations, with Neexdzii Kwa modern ER modelled low (~6%) and historical in-river harvest identified as the dominant driver of decline
- drop unverified coho claim and reframe fisheries-pressure framing in executive summary to reflect Neexdzii Kwa-specific story (local chinook fishing ban since 1998)
- add coho 1997 crisis context ("perilous" upper Bulkley; earliest-ever North Coast gillnet closure) and clarify that Neexdzii Kwa coho are grouped within the Middle Skeena coho CU rather than assessed as a distinct population
- trim "Implications for Restoration" paragraph; remove editorial "one of the few interventions" framing
- add 5 Skeena coho references to Zotero group library (DFO Coho Response Team 1998, Walters et al. 2008 ISRP, Korman & English 2013 benchmark, English 2013 time-series, Porter et al. 2014 habitat cards)
- build local ragnar lit-search store (`data/rag/coho_refs.duckdb`, 8 PDFs, 2,647 chunks) used to verify all new fisheries claims against source PDFs before drafting
- remove `breaks` and `diggs` shiny apps from executive summary (inline mentions and tools list); re-label "Tools as deliverables" to "Open-source software and data products" — apps pulled pending hosting/maintenance funding, packages and STAC catalogs retained

# restoration_wedzin_kwa_2024 DRAFT 0.2.7 (2026-03-30)

- clarify that gate examples in recommendations are preliminary candidates, not approved sites
- add package links (fresh, flooded, drift) to methods land cover section
- reorder methods to match pipeline flow (network → floodplain → classification)
- define Impact Observatory land cover imagery (was IO LULC acronym)

# restoration_wedzin_kwa_2024 DRAFT 0.2.6 (2026-03-19)

- recalibrate floodplain model: flood_factor reduced from 6 to 4, mapping functional floodplain rather than valley bottom extent ([#138](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/138))
- filter waterbodies to coho-accessible network — removes headwater wetlands/lakes that diluted LULC change percentages
- build stream network with `fresh` classification pipeline instead of bcfishpass views, reading project-local habitat threshold parameters
- rename pipeline scripts with numbered prefixes (01–05) for execution order
- CSV-driven flood scenarios with full VCA parameter specification and literature citations
- add aquatic health monitoring results summarizing benthic invertebrate gradient from dedicated report
- update executive summary with revised floodplain tree loss estimate (~760 ha, down from ~1000 ha)
- verify all VCA parameters against source literature via ragnar semantic search ([flooded#28](https://github.com/NewGraphEnvironment/flooded/issues/28), [flooded#29](https://github.com/NewGraphEnvironment/flooded/issues/29))

# restoration_wedzin_kwa_2024 DRAFT 0.2.5 (2026-03-17)

- integrate `frs_watershed_split()` into reproducible pipeline from `break_points.csv` through to report tables ([#135](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/135))
- consolidate scripts: `fwa_extract_flood.R` (subbasins + streams + floodplain), `prioritization_score.R` (all scoring); remove `prioritization_build.R` and `lulc_watershed-picker.R`
- rename sub-basins for clarity, add description and fisheries value columns
- add sub-basin description table and study area map with sub-basin boundaries
- express tree loss and ag gain as % of floodplain in results table and inline text
- rewrite Maxan Creek recommendation: floodplain degradation trajectory, historic fishing sites, process-based restoration potential
- clarify First Nations reserve lands throughout
- remove legacy floodplain gpkg fallback; standardize `name_basin` column across pipeline

# restoration_wedzin_kwa_2024 DRAFT 0.2.4 (2026-03-16)

- align Results section structure with Methods: matching parent headings (Field Assessments, Remote Sensing & Imagery, Background Research & Analysis, Collaborative Data Management) ([#132](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/132))
- move Collaborative Data Management from Methods position 2 to position 4 so both chapters follow the same narrative flow
- reorder appendix files to match Results sequence (Field → Aerial → LULC → Climate → Fish Species → Sites Priority → Historic Data)
- add bridging text connecting appendix site-ranking proof of concept to governance framework and future floodplain type mapping
- fix Zotero title case for smith_gaboury 2016/2017 as-built reports to resolve citeproc citation key warning
- migrate `frs_network()` calls to fresh conn-first API in `prioritization_score.R` and `lulc_network-extract.R` ([#35](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/35))
- update sub-basin names in `break_points.csv` for clarity and add description column

# restoration_wedzin_kwa_2024 DRAFT 0.2.3 (2026-03-13)

- add Research as Territorial Stewardship section to recommendations: UN Decade on Ecosystem Restoration principles, UNDRIP, root causes framing that integrates both habitat degradation and exploitation
- fold exploitation caveat into UN Decade Commitment 1 (address root causes) — habitat loss and fishing pressure as co-equal drivers
- refine executive summary tool descriptions: `fresh` as stream network spatial hydrology, `stac_dem_bc` as provincial LiDAR DEM catalog, `breaks` as interactive sub-basin delineation
- weave territorial stewardship and UN Decade framing into executive summary closing
- tighten executive summary: drop stac_dem_bc detail paragraph, generalize mobile GIS, simplify guideline names, clean airphoto catalog URL
- rewrite acknowledgement: Wet'suwet'en hereditary house system, balhats, clan-based laws, oral tradition (Morin 2016)
- update AI disclosure: "analysis, writing, and code development" across exec summary PDF and main report

# restoration_wedzin_kwa_2024 DRAFT 0.2.2 (2026-03-13)

- rewrite executive summary: framework-first structure with governance, sub-basin delineation, floodplain model sensitivity range (680–1,000+ ha), collaborative GIS, aquatic health monitoring, and tools as deliverables
- add standalone executive summary PDF (`docs/executive_summary.pdf`) built via pagedown on every `scripts/run.R` build, stamped with version, date, and report links
- add `stac_dem_bc` (50,000+ LiDAR DEMs via STAC API) to floodplain modelling and tools list
- add collaborative GIS section to executive summary: Mergin Maps field platform, 45+ provincial layers, spatial integration
- add `breaks` app to sub-basin delineation tools
- weave interdisciplinary education into all three framework examples: restoration sites as shared learning environments for all parties ([#130](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/130))
- add bridging text before recommendations shiny table to connect legacy items to the prioritization framework
- add Toboggan Creek hatchery legacy section to background fisheries: 40 years of enhancement, 38% hatchery proportion, genetic mixing, lapsed reporting ([#131](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/131))
- sharpen exploitation caveat in recommendations: plain language on fishing pressure as precondition for recovery

# restoration_wedzin_kwa_2024 DRAFT 0.2.1 (2026-03-12)

- add historic aerial photograph STAC collection to methods and results (9,741 photos, 1963-2019 via `fly`/`stac_airphoto_bc`) ([#126](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/126))
- reorganize methods: airphoto STAC first, land cover classification, climate; move Open Source Reporting to end; remove Data Sourcing
- add sub-basin prioritization data: fish habitat (bcfishpass), land ownership (PMBC), reserves (CLAB), cultural sites per sub-basin ([#125](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/125))
- add governance framework, diagnostic gates, scoring principles, and workshop rankings to Recommendations
- add exploitation caveat with Skeena chinook/coho decline citations

# restoration_wedzin_kwa_2024 DRAFT 0.2.0 (2026-03-12)

- upgrade floodplain model to coho 3rd order+ streams with waterbodies via `fresh::frs_network()` ([#123](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/123))
- split lower Bulkley into 5 sub-basins (14 total) to isolate degradation hotspots
- add scenario-driven flood modelling framework (`flood_scenarios.csv`) for multi-scale floodplain analysis
- add prioritization framework scaffold: `area_scores.csv` (14 sub-basins) and `project_scores.csv` (208 sites) ([#125](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/125))
- update methods, results, and appendix to document VCA parameters (flood_factor=6, order 3+, waterbodies)

# restoration_wedzin_kwa_2024 DRAFT 0.1.9 (2026-03-11)

- restructure Results: replace layer tracking table with descriptive GIS environment summary
- add STAC cataloging explanation and `stac_uav_bc` repo link to Aerial Imagery section
- move UAV imagery and historic data tables to new appendices
- update lateral connectivity text to reference flooded, fresh, drift repos
- replace raw parameter CSV table with plain-language ranking summary
- strip numbers from all appendix headings
- remove SKT and ESI appendices — cite sources inline instead

# restoration_wedzin_kwa_2024 DRAFT 0.1.8 (2026-03-11)

- use `name_basin` labels from `break_points.csv` for sub-basins ([#120](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/120))
- regenerate `subbasins.gpkg` via `fresh::frs_watershed_split(crs = 3005)`
- add Brewer Set3 palette and legend to interactive LULC map
- add OpenTopoMap basemap option to interactive map
- add timber harvest and watershed function caveats to LULC results
- split results LULC paragraph: findings vs interpretation
- add gross/net transition numbers to results summary

# restoration_wedzin_kwa_2024 DRAFT 0.1.7 (2026-03-10)

- add climate anomaly methods, results summary, and trend table ([#118](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/118))
- extract ERA5-Land anomaly data programmatically from NetCDF for Neexdzii Kwah study area ([NewGraphEnvironment/bc_climate_anomaly#2](https://github.com/NewGraphEnvironment/bc_climate_anomaly/issues/2))
- add Total Change column to trend table so readers see cumulative impact (e.g., +2.3°C) not just per-year rate
- plain-language summary: watershed ~2°C warmer, precipitation unchanged, summer soils drying ~5% from evapotranspiration

# restoration_wedzin_kwa_2024 DRAFT 0.1.6 (2026-03-10)

- add LULC sub-basin analysis appendix with drift/flooded pipeline ([#114](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/114))
- add interactive land cover transition map to appendix using `dft_map_interactive()` with sub-basin overlay ([#116](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/116))
- separate LULC computation into standalone `scripts/lulc_classify.R` gated by `params$update_lulc`
- add dynamic tree loss summary to results with top sub-basins by hectares lost
- add interactive sub-basin picker app for defining analysis units
- integrate LULC methods and results into main report body
- restructure fisheries: barriers, traditional sites, species table to appendix ([#106](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/106))

# restoration_wedzin_kwa_2024 DRAFT 0.1.5 (2026-03-02)

- add study area map with site locations and keymap inset ([#108](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/108))
- add study area map to Results field review section
- expand Appendix 2 with per-site summary tables, photos, and UAV viewer links for all 21 sites
- restructure fisheries: combine Bulkley Falls and Buck Falls into Barriers to Fish Passage section with Wet'suwet'en traditional fishing site names ([#106](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/106))
- move fish species table to Appendix 1b ([#112](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/112))
- add Buck Falls to fwa_query.R upstream fish observation script ([#111](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/111))

# restoration_wedzin_kwa_2024 DRAFT 0.1.4 (2026-02-26)

- rewrite executive summary: remove tools table, streamline prose
- rewrite acknowledgement with Wet'suwet'en territorial context
- add AI disclosure to title block
- remove social media sharing buttons, resize logo
- add second 3D model to Attachment 1 (3 growing seasons), shorten captions
- fix 6 broken citation keys
- add chapter preview utility (scripts/setup.R)

# restoration_wedzin_kwa_2024 DRAFT 0.1.3 (2026-01-16)

- rewrite Field Review with accurate site counts and geojson links ([#102](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/102), [#103](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/103))
- add Site Reviews methods section ([#97](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/97), [#100](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/100))
- add NEWS.md link to Open Source Reporting section ([#105](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/105))
- reorganize report: separate background context from deliverables


# restoration_wedzin_kwa_2024 DRAFT 0.1.2 (2025-06-10)

- update section on traditional fishing sites
- update Wet'suwet'en sections in Executive Summary, Background and Recommendations based on Niwhts'ide'ni Hibi'it'en book
- initial commit of table showing example of potential restoration sites ranked
- Update prioritization ranking system results and table with links to source code
- Include methodology for UAV imagery processing and sharing.
- Update UAV imagery summary table to pull from stac.
- Include links to updated fish passage reporting and details of top priority sites
- add esi data summary and update background lit review details


# restoration_wedzin_kwa_2024 DRAFT 0.1.1 (2025-05-06)

- Update prioritization ranking system results and table with links to source code
- Include methodology for UAV imagery processing and sharing.
- Update UAV imagery summary table to pull from stac.
- Include links to updated fish passage reporting and details of top priority sites
- add esi data summary and update background lit review details


# restoration_wedzin_kwa_2024 DRAFT 0.1.0 (2025-05-06)

- Include methodology for UAV imagery processing and sharing.
- Update UAV imagery summary table to pull from stac.
- Include links to updated fish passage reporting and details of top priority sites
- add esi data summary and update background lit review details


# restoration_wedzin_kwa_2024 DRAFT 0.0.11.9001 (2025-04-03)

- add climate anolalies methods as per https://github.com/NewGraphEnvironment/restoration_framework/issues/25


# restoration_wedzin_kwa_2024 DRAFT 0.0.11.9000 (2025-04-03)

- initial commit of executive summary with links to project resources
- begin to amalgamate 2024 site review and routine effectiveness evaluation monitoring into Appendix of report


# restoration_wedzin_kwa_2024 DRAFT 0.0.11 (2024-12-11)

- first build following use of fledge to dynamically update NEWS and Changelog


# restoration_wedzin_kwa_2024 DRAFT 0.0.10 (2024-12-11)

- link to blog and details for imagery as per #10 (rollback 1)
- remove regex (all brackets) and escape commas and periods to close #77 (rollback 3)
- link verison dynamically to DESCRIPTION file as part of changelog update automation. Add references from Recommendations table. Rollback 1.
- add citations from recommendation table to references and print inline in the recomendations table


# restoration_wedzin_kwa_2024 DRAFT 0.0.9 (20241027)
  - interactive priority table for recomendations!
  - move appendix to before changelog
  - increase width as per https://github.com/NewGraphEnvironment/mybookdown-template/issues/55

# restoration_wedzin_kwa_2024 DRAFT 0.0.8 (20241017)

  - add riparian restoration prescription example as per https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/73
  - add field survey summary to results
  - add water quality info to recommendations
  - add hwy and rail armoring to recommendations
  - add beaver info to recommendations
  - add educational programs to recommendations
  - resort Table 4.7 (params for prioritization).  Add width of buffer


# restoration_wedzin_kwa_2024 DRAFT 0.0.7 (20240814)

  - add detailed prioritization table for Mid-Bulkley Detailed Fish Habitat/Riparian/Channel Assessment for Watershed Restoration.” Nadina Community Futures Development Corporation (NCFDC) 1998.
  - add detail about Price 2014 to results, waypoint table to report and spatialize waypoints in QGIS.
  - update packages conditionally on param


# restoration_wedzin_kwa_2024 DRAFT 0.0.6 (20240809)
  
  - swap in `ncfdc_1998_prescriptions_hand_bomb.csv` 
  - swap in SERNbc logo
  - add a bit of detail on stock assessment data in background and put link to memo on how it was done

# restoration_wedzin_kwa_2024 DRAFT 0.0.4 (20240418)

  - pull DFO stock assessment plots and update tables to include more columns as per https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/issues/42
  - add NEWS.md to the report with `news_to_appendix()` function

# restoration_wedzin_kwa_2024 DRAFT 0.0.4

  - fix duplicate table captions and dark table captions with https://github.com/NewGraphEnvironment/fpr/issues/68

# restoration_wedzin_kwa_2024 DRAFT 0.0.3

  
  - add `sites_restoration_gpkg_tracking.csv` file located [here](https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/blob/main/data/sites_restoration_gpkg_tracking.csv
  - add Gaboury and Smith 2016 report to references via index file


# restoration_wedzin_kwa_2024 DRAFT 0.0.2
  
  - recommendations are now numbered and reordered
  - MIT license
  - recommendations - mention develop and document data management workflows to leverage existing established data storage systems to retrieve data from and load too and build capacity for all interested to do the same
  - methods - include details of Open Source - Iterative Reporting. include aquatic_restoration_resources.csv as example of data management and presentation strategies 
  - issue #42 - turn DFO NuSeds tables and graph generating code to functions with region and data elements etc. as params
  - background - add DFO NuSeds tables and graphs to Neexdzii Kwah section
  - background - create seperate headings for Traditional Fishing sites and upper Bulkley falls
  - background - add detail of upper Bulkley Falls from 2021 Skeena fish passage planning report - issue #
  - background - re-organize background fisheries info to focus on Neexdzii Kwah study area.


# restoration_wedzin_kwa_2024 DRAFT 0.0.1 20240322

  * initial release for update and engagement
  
