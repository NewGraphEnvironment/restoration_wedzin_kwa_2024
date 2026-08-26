# Task: Reframe prioritization as exercise superseded by gates and governance (#155)

Responds to external review of the executive summary (N. Newman, 2026-03-16). Two review
questions traced into the data surfaced two larger issues: cultural significance is defined
but not scored, and the report never states that the 208-site ranking predates the gates and
governance model — nor the finding that list-and-rank proved insufficient.

Reframe rather than expand. Adding site counts and a high-priority map (as requested in
review) would pull the executive summary toward a leaderboard reading and cement the
approach the work found inadequate — deferred to #156 with reasoning recorded.

## Phase 1: Executive summary reframe

- [x] Replace "These perspectives are built into the weighting system" — priorities and gates post-date the scoring run
- [x] Add "Why a framework rather than a ranked list" paragraph stating the finding
- [x] Point to worked gate examples without naming sites (two of three sit above Bulkley Falls)

## Phase 2: Appendix accuracy

- [x] State that the ranking run predates the gates and governance structure
- [x] Correct the "highest individual score" claim (land ownership is 10, cultural significance 5)
- [x] Add "What the Exercise Covered" subsection mapping four workshop priorities onto scored parameters

## Phase 3: Recommendations caveat

- [x] Retitle "Applying the Gates: Project Types That Pass" -> "Worked Examples"
- [x] Add above/below-falls caveat, noting it is an open question for the Stewardship Council (Relates to #111)

## Phase 4: Rolled-in small items

- [x] Link executive summary PDF from gitbook chapter (matches fish passage / NRP pattern)
- [x] Generalize AI disclosure from pinned Claude version (index.Rmd, _executive_summary_pdf.Rmd)

## Phase 5: Release

- [x] Bump DESCRIPTION 0.2.11 -> 0.3.0 BEFORE rebuild
- [x] Add NEWS.md entry
- [x] Rebuild via `Rscript scripts/run.R`
- [x] Commit docs/ separately as "rebuild book v0.3.0"

## Validation

- [x] Report builds with no rendering errors
- [x] Cross-references resolve; appendix table renders with new subsection
- [x] No hardcoded stats introduced in prose
- [x] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion
