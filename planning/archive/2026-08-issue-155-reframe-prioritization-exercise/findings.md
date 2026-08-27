# Findings — Reframe prioritization as exercise superseded by gates and governance (#155)

## Review source

`hold/executive_summary_UBR restoration plan review_NN.pdf` — 8 highlights, 2 with written
comments, author NEWMANN, created 2026-03-16, edited 2026-03-19. Three highlights are
white/cleared (low signal). Extracted via qpdf `--qdf` + QuadPoints matched against
`pdftotext -bbox-layout` output.

**Comment 1** (p2, on "These perspectives are built into the weighting system"):
> Can you list the 6 parameters (listed in the apprendix - Example of Potential Restoration
> sites Prioritized) used in the ranking system and explain how the four priorities are
> reprented in each of the parameters?

**Comment 2** (p3, on the site-assessment paragraph):
> Can you list the number of sites ranked, and how many sites rated as high? We were thinking
> a map would be helpful, a snapshot in time, that would show the locations of the preliminary
> high priority sites, Could have a caveat that the ranked sites are preliminary and its likely
> to be refined with future consultation.

## Finding 1: cultural significance is defined but not scored

`wet_cultural_site` in `data/restoration_site_priority_parameters.csv` has weights 0/3/5 but
`rank = NA`. `scripts/gis/prioritize.R:554` selects `filter(rank == TRUE)`, so it never enters
scoring. Confirmed absent from output: `data/gis/sites_prioritized.geojson` has 12 score
columns (11 `rank == TRUE` parameters + `total_score`), no `wet_cultural_site_score`.

It is `user_input = TRUE` with no source layer — a knowledge-holder field with no data
collected. So `rank = NA` is not a bug so much as an unpopulated parameter the prose overstates.

Two false claims resulted:
- Executive summary: the four workshop priorities "are built into the weighting system".
- Appendix: cultural significance receives "the highest individual score". It does not —
  land ownership carries the highest weight at 10, against cultural significance's 5.

The reviewer's count of "6 parameters" is correct and is the tell: the appendix table renders
6 rows (5 non-bcfishpass `rank == TRUE` + 1 summarized bcfishpass row) precisely because
cultural significance is filtered out. "Cultural significance" appears in the rendered page
only inside the echoed `case_when` code block, never in the table.

Tracked separately as #157.

## Finding 2: two of three gate examples sit above Bulkley Falls

`0500-recomendations.Rmd:112` "Applying the Gates: Project Types That Pass":

| Example | Position | Salmon |
|---|---|---|
| Cesford-Ailport | Below falls | Largest floodplain below; 60.8 km coho spawning |
| Maxan Creek | Above falls | Not observed in modern record |
| Bulkley River Above Falls | Above falls | Historic use documented, current access limited |

Bulkley Falls is a 12-15 m bedrock cascade (`0200-background.Rmd:210`). Naming these three in
the executive summary would put two upstream sub-basins in front of any reviewer who reads only
the summary, stripped of gate caveats — close to a funding shortlist, pointing largely where
fish currently are not. Hence: point to the examples, do not name sites. Relates to #111.

## Finding 3: framing is mostly right, but the actual finding is missing

The report already avoids reading as "we found the sites":
- Executive summary opens as "a governance and prioritization framework ... a living system"
  and never cites the 208 sites.
- `0400-results.Rmd:258` — "An initial proof of concept for site-level parameter ranking".
- Appendix titled "Example of Potential Restoration Sites Prioritized"; prose says "proof of
  concept run" and "data is preliminary".
- `0500-recomendations.Rmd:125` — "The following recommendations predate the prioritization
  framework above".

What is missing: nowhere does the report say the 208-site run **predates the gates and
governance model**. The explicit "predates" statement exists for the old recommendations but
not for the ranking, so a reader assumes workshops and gates fed into it. They did not.

More importantly the conclusion of the exercise is never stated — that compiling past
prescriptions and brought-forward sites and scoring them showed list-and-rank to be
insufficient. The determining constraints (land ownership and legal access, willingness to
participate, meaningful project size, certainty of diagnosis) are largely absent from the
scored layers, and no forum existed to work them through. Without this, the gates and
governance model read as unmotivated.

## Scoring does not discriminate

208 sites scored, `total_score` range 11-30, median 25. No high/moderate/low tiers exist in the
data. 100 of 208 (48%) score >= 27, with 60 tied at exactly 27 and 38 tied at the maximum 30.
Any "high priority" cut would be arbitrary. This is a substantive argument for the reviewer's
own caveat, and part of why the map is deferred (#156).

## Decision: what not to do

Adding site counts to the executive summary and mapping high-priority sites were both proposed
and rejected. Both pull toward a leaderboard reading of an exercise the work found inadequate,
and the map would rest on tiers that do not exist. Deferred to #156 with conditions to revisit.

## Rejected: "Max Score" column

An earlier draft of the priority-to-parameter mapping table carried a summed "Max Score" per
workshop priority. Dropped — the sums are artifacts of how many parameters happened to land
under each heading, not designed weightings, and they make the exercise look more principled
than it was. Weights were also set before the workshops, so the correspondence cannot exist.
