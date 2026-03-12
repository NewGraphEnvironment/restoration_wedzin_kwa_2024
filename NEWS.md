
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
  
