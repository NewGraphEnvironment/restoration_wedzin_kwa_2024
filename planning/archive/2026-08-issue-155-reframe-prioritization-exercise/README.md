# Reframe prioritization as exercise superseded by gates and governance (#155)

External review of the executive summary (N. Newman, 2026-03-16) asked two questions: list the
six ranking parameters and map them to the four workshop priorities, and give site counts plus a
map of preliminary high-priority sites. Tracing both into the data surfaced problems larger than
the questions. Cultural significance was defined in the parameter set but never scored — it is
`rank = NA`, which `prioritize.R:554` filters out — while the executive summary claimed the
workshop priorities were "built into the weighting system" and the appendix claimed cultural
significance carried the highest weight (land ownership does, at 10 against 5). The report also
never stated that the 208-site ranking predates the gates and governance model, nor the finding
that produced them: that list-and-rank was insufficient because the determining constraints sit
outside the scored layers and no forum existed to resolve them.

Resolved by reframing rather than expanding. The requested site counts and priority map were
declined and deferred to #156, since both would pull the summary toward a leaderboard reading of
an exercise the work found inadequate, and the map would rest on tiers that do not exist — 48% of
sites score in the top band, 60 tied at one value. Scope grew during review at the user's request
to close three further gaps: floodplain and riparian function was never explained anywhere in the
report despite the whole floodplain analysis resting on it (#159); conservation of intact areas
was absent (#158); and the seed collection program was undocumented (#129, closed). The scoring
principles announced seven and listed six — wrong since the original commit — now eight with
"Protection of what remains" and "Connection to place".

Citations for the new background section were verified against Zotero PDFs with ragnar rather
than assumed, and citekeys read from `zotero.sqlite` rather than guessed.

Closed by PR from `155-reframe-prioritization-exercise` at v0.3.0.

Follow-ups: #156 (map, deferred with conditions), #157 (populate cultural significance),
#158 (conservation, principle added — broader treatment outstanding), #159 (done),
#111 (salmon above obstructions, related), #151 (pre-existing citekey typo, untouched).
