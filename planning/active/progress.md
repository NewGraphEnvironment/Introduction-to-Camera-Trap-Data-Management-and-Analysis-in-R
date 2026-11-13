# Progress — Does pooling seasons in ch 9 hide changes in daily activity? (#5)

## Session 2026-11-13

- Plan-mode exploration — phases approved by user
- #1's PWF archived to `planning/archive/2026-11-issue-1-ch12-independence-tz/` (`16ccf29`)
- PWF for #5 lives on `newgraph`; the chapter work goes on `ch9-activity-season`, cut from
  origin/master (`2c79f0e`) in a worktree, so this checkout stays on `newgraph` for the course
- Scaffolded PWF baseline from issue #5 with approved phases
- Next: Phase 2 (measurement script)
- Plan review (Plan agent): no blockers; dispositions in `review-plan.md`. Added an event-shuffle
  null, a core-months check, a tz-vector guard
- Phase 2: `newgraph/check_ch9_season.R`, log `newgraph/logs/20261113_check_ch9_season.txt`.
  Deer winter vs summer differ under every tz variant and against the event-shuffle null; caribou's
  shift does not survive it (12 winter events). Nothing else does either: the chapter's own species
  and feature-type differences (0.78, 0.83) fall at event level, filed as fork #6
- `/code-check` 3 rounds: round 1, two unsupported claims in findings; round 2, table cells left
  stale by the re-run (inside round 1's fix); round 3 named the mechanism (hand copies of the log)
  and enumerated every number and quantifier, one pairing fixed. Table 1 is now generated from the log
- tz: no conclusion flips between -6, -7 and DST-following, so decision 3 is not triggered
- Next: Phase 3 (chapter section, drafted and rendered in the worktree)
