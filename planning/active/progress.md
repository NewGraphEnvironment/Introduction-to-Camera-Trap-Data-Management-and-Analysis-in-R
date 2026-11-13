# Progress — Ch 9's species and feature-type differences do not survive an event-level null (#6)

## Session 2026-11-13

- Plan-mode exploration — phases approved by user
- Branch `ch9-event-level-null` was already cut from origin/master (`2c79f0e`) in the worktree
  `.claude/worktrees/issue6`; skill steps 1b and 5 skipped, main checkout stays on `newgraph`
- Scaffolded PWF baseline on `newgraph` from issue #6 with approved phases
- Next: plan review in the background, then Phase 2 (baseline render of master's ch 9)
- Plan review (Plan agent): no blockers; dispositions in `review-plan.md`. It corrected the
  plan's reading of obs > event null (obs is one draw from that null, not evidence of noise),
  and set numeric acceptance against the log
- Phase 2: `master`'s ch 9 renders clean into the scratchpad (41 s; image-level nulls 0.954,
  0.960). The first try rendered with the book's gitbook format, which wrote `404.html`,
  `activity.html` and `libs/` into the worktree; removed, and renders now pass
  `output_format = html_document`. Deer sites: 9 HumanUse, 9 Offline
- Next: Phase 3 (chapter edits)
