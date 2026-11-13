# Plan review (Plan agent, 2026-11-13), with dispositions

No blockers.

| # | Category | Finding | Disposition |
|---|---|---|---|
| 1 | Gap | Deer vs caribou not re-tested by season; report season mix incl. shoulder | Already in the script (section 4, section 1); plan text now says so |
| 2 | Assumption | Phase 3 conclusions written before the data; issue's "lower evening peak ... mostly winter" vs its own sunset shares | Prose comes from the measurement. The issue means the evening *dip* comes from winter (fewer dusk detections), consistent with its shares |
| 2b | Assumption | Define dusk share on the solar axis; "only the solar version responds to tz" | Disproved by run 1: clock-time shares move with tz too (deer winter sunset 15% at -6, 10% at -7). Kept clock time, which is what "within 2 h of sunset" means to a reader |
| 3 | Statistics | compareCkern's null ignores clustering in events | Added a null that shuffles season labels across whole events |
| 4 | Statistics | 12-event caribou curve biased low; need a noise floor | The event-shuffle null is drawn at the same event counts, so its mean and 5th percentile are that floor |
| 5 | Statistics | Caribou winter: 6 sites vs 18, one winter vs two summers | Sites go in the chapter's caution. "One winter" is wrong: 6 of the 12 events are in winter 2018–19 and 6 in one week of November 2019 (checked 2026-11-13; code-check round 1 found the same) |
| 6 | Statistics | reps > 100 in the script | Script uses 200; chapter keeps 100 |
| 7 | Gap | DST variant ill-defined in the plan text | Script already uses the 2018/2019 switch dates; plan text corrected |
| 8 | Assumption | tz vector recycling unverified | Guard added: per-row sunrise equals a single-value call |
| 9 | Assumption | Nov-Mar is a snow season, not a day-length one | Added a core-months check (Dec-Feb vs Jun-Jul) |
| 10 | Acceptance | Decision 3 has no trigger | Trigger: a qualitative conclusion flips between tz variants (direction of the dusk/dawn shares, or the event-shuffle p crossing 0.05) |
| 11 | Acceptance | data/processed_data is branch-independent; add mtime | mtime added beside the md5 |
| 12 | Ordering | Render master's ch 9 without switching the main checkout | Render it in the new worktree before the edit |
| 13 | Scope | `.claude/worktrees/` ignored? Line 181 says "both feature types" for a species comparison | Ignored by the global gitignore (`.claude/*`). Line 181 is left alone (one concern per branch) and reported |
