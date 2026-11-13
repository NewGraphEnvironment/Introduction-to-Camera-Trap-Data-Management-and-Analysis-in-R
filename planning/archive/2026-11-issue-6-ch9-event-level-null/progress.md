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
- Phase 3: chapter edited in the worktree (`:181` reading, images-vs-events chunk,
  `event_shuffle()`, feature-type and species calls, `:224` reading). Function returns a one-row
  data frame (a named vector printed counts as `87.00`)
- Phase 4: branch renders clean (62 s); acceptance holds against the log and under seeds 1-3.
  `/code-check`'s gate `file:NAMESPACE|glob:*.R` skips `code-check-r.md` on an `.Rmd`-only
  branch; added by hand for these rounds. Readability pass (blind) and round 1 running
- Readability pass (blind Plan agent): "optimistic" came before its explanation; "9 sites" had no
  output behind it; `ovl4` not tied to the coefficient; "about 0.95" for a printed 0.960; the
  upstream pNull line ("Low pNull means the patterns differ") contradicted the new reading. All
  taken; upstream wording outside the diff left
- `/code-check` round 1: one bug, the site-level sentence (an unmeasured direction, and wrong:
  reproduced site null 0.80, p 0.82-0.825 at seeds 1-3). Fixed by showing the site-level shuffle
  (`id = "placename"`, rendered p 0.78). Round 2 running
- `/code-check` round 2: clean (measured image-level shuffle 0.942, so the burst explanation holds)
- Round 3 lost to a network error (no file); re-run as 3b. It named round 1's mechanism (one
  null's mean stated as *the* expectation) and enumerated 32 claims: 30 hold. Fixed the two:
  `:181` now attributes 0.95 to `compareCkern` (inside round 1's rewrite of that line), and the
  `pNull` line now gives `compareCkern`'s definition (`ecdf(null)(obs)`, the same as `p`). The
  sweep found no other unattributed expectation. Loop ended by that enumeration
- Phase 5: `aa7ee42` on `ch9-event-level-null`, fork PR 8 into `newgraph`. Reviewer agents this
  task: 1 plan review, 1 readability pass, 4 code-check spawns (3 rounds + 1 lost re-run)
