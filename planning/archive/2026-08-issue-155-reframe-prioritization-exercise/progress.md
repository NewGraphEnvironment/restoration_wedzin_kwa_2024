# Progress — Reframe prioritization as exercise superseded by gates and governance (#155)

## Session 2026-08-26

- Extracted reviewer comments from `hold/executive_summary_UBR restoration plan review_NN.pdf`
  (qpdf + QuadPoints matching); 8 highlights, 2 written comments
- Traced both review questions into the data; surfaced findings 1-3 (see findings.md)
- Filed #155 (this work), #156 (map deferred), #157 (cultural significance data gap)
- Drafted and reviewed all replacement text with user before touching files
- Dropped two proposals during review: site counts in executive summary, and the "Max Score"
  column in the mapping table
- Created branch `155-reframe-prioritization-exercise` off main
- Pushed two prior git-cleanup commits to main first so they stay out of this PR
- Next: Phase 1
- Phase 1 complete: executive summary reframed — sequencing corrected, "Why a framework
  rather than a ranked list" paragraph added, gate examples referenced without site names
- Phase 2 complete: appendix states the run predates the gates, corrects the "highest
  individual score" claim, and adds the priority-to-parameter mapping
- Phase 3 complete: gate examples retitled to "Worked Examples" with above/below-falls caveat
- Phase 4 complete: PDF link added (gated to gitbook so it does not appear inside the PDF
  itself, which child-includes 0050), AI disclosure generalized off the pinned version
- Phase 5 complete: bumped to 0.3.0 before rebuild, NEWS entry added, rebuilt via
  scripts/run.R (exit 0), committed docs/ as "rebuild book v0.3.0"
- Verified in rendered output: all six items present, mapping table renders, PDF link gated
  out of the standalone PDF as intended, version reads 0.3.0
- Build warning `citation smith_gaboury2016BUILTREPORT not found` is pre-existing (#151)
- Next: /planning-archive, then PR
- Scope expanded during review at user request: floodplain/riparian function (#159),
  conservation principle (#158), connection-to-place principle, seed collection (#129)
- Citations verified against Zotero PDFs via ragnar (data/rag/vca_refs.duckdb) rather than
  assumed; citekeys read from zotero.sqlite rather than guessed
- Found "Seven principles" listed only six since the original commit (21c385d) — now eight
- Seed inventory (4 lots) does not cover all reported collections; text names what was
  collected and the table shows what is stored, without speculating on the gap
