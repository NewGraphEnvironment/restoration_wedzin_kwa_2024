## Outcome

Investigated whether the v0.2.11 floodplain/LULC numbers were over-stated by the `link` 0.43.0
access-segmentation over-credit bug (link#223, fixed in link 0.44.0/0.44.1). **They were not.**
Re-ran `01_network_extract.R` under link 0.44.1 (fix confirmed active — `lnk_pipeline_prepare.R`
unions the full per-model gradient+falls set as break sources) and did a full `02`→`03` remodel.
The Neexdzii **coho order≥3 network is geometrically identical** pre/post fix — same 1812 DRM
breakpoints (`setequal` TRUE), same 678.1774 km; only internal `id_segment` labels differ. Report
numbers came out **identical** (floodplain tree loss 943.13 ha, extent 171.0 km²); the only delta
was ~7 edge pixels / 0.004% VCA-rasterization run-to-run noise, which rounds away and (since the
network feeding VCA is byte-identical) cannot come from the fix. **Mechanism:** 94% of
coho-blocking gradient barriers (53,071 / 56,284 BULK-wide) sit on order<3 streams excluded by the
order≥3 floodplain-input threshold; falls govern the order≥3 network and always survived as the
downstream-most barrier — so the fix cannot reach our extract.

Per user decision, no data was re-committed (the committed network was never incorrect). Kept only
the `01` link-version requirement bump to `>= 0.44.0`. The `floodplain-numbers-provisional` memory
was resolved and renamed `floodplain-numbers-verified`. No report rebuild / version bump (no
content changed). Phases 3–5 (report, Mergin push, recommendations app) were moot.

Closed by: commit 58c5c7f (+ PWF baseline e0cb229). Related: #148, NewGraphEnvironment/link#223, #228.
