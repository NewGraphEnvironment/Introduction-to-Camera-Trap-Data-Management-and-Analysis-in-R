# Progress — Ch 12 independence step and the weekly frame's time zone (#1)

## Session 2026-11-11

- Plan-mode exploration — phases approved by user
- Created branch `newgraph` off origin/master (`2c79f0e`); PWF lives here, not on the concern branches
- Scaffolded PWF baseline from issue #1 with approved phases
- Next: start Phase 2 (measurement script)
- Phase 1 done: `newgraph` pushed with the baseline
- Phase 2: `newgraph/check_fixes.R` written. `/code-check` ran 4 rounds (review-round1..4.md). Round 1: git stderr could reach the sha and chapter text (fixed). Round 3: the data came from the working tree and the ref was resolved three times (fixed: one sha for chapters and data). Rounds 2 and 4 were clean, and no defect was found inside a fix.
- Baseline at `2c79f0e`: 69,096 images, 852 events, 831 written; 35 of 831 week labels differ under Vancouver; the weekly frame differs between zones
