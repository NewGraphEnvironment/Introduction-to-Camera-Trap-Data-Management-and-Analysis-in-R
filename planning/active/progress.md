# Progress — Ch 12 independence step and the weekly frame's time zone (#1)

## Session 2026-11-11

- Plan-mode exploration — phases approved by user
- Created branch `newgraph` off origin/master (`2c79f0e`); PWF lives here, not on the concern branches
- Scaffolded PWF baseline from issue #1 with approved phases
- Next: start Phase 2 (measurement script)
- Phase 1 done: `newgraph` pushed with the baseline
- Phase 2: `newgraph/check_fixes.R` written. `/code-check` ran 4 rounds (review-round1..4.md). Round 1: git stderr could reach the sha and chapter text (fixed). Round 3: the data came from the working tree and the ref was resolved three times (fixed: one sha for chapters and data). Rounds 2 and 4 were clean, and no defect was found inside a fix.
- Baseline at `2c79f0e`: 69,096 images, 852 events, 831 written; 35 of 831 week labels differ under Vancouver; the weekly frame differs between zones
- Phase 3 and 4: concern branches `ch12-independence-gap` and `weekly-detection-tz` cut from `2c79f0e`, each a single commit with no planning files and no `#N`. One `/code-check` covered both diffs over 4 rounds: round 1 found that concern 2's message cited the 4,939 figures, which need concern 1 (amended to `18165f5`); round 3 found that concern 1's message left out "identified to species" on 69,096 (amended locally to `8278ddc`); round 4 enumerated every figure and found nothing.
- Measured: concern 1 (`8278ddc`) 5,027 events, 4,939 written, 258 of 4,939 differ; concern 2 (`18165f5`) 831 written, 0 / 0 differ, weekly frame identical. A local preview merge of the two (not pushed) gave 4,939 written, 0 / 0 differ, weekly frame identical.
- Fork PR 2 (`weekly-detection-tz` into `newgraph`) is open.
- Blocked: the fork has concern 1 at `39cc573` (old message). The force-push of `8278ddc` (same tree) was denied by the auto-mode classifier, so the owner's call is pending.
- Owner approved the force-push: the fork's `ch12-independence-gap` is now `8278ddc`. Fork PRs 3 and 2 merged into `newgraph` (`4b96c1c`, `0471220`); concern branches kept.
- `newgraph` measured: 4,939 written, 0 / 0 of 4,939 differ, weekly frame identical, weekly total 4,939 under both zones. Table in findings.md.
- Next: comment on fork issue 1; then the owner decides on upstream.
- Commented on fork issue 1 with the table, the branches and two wording points for the draft. Labels unchanged; nothing upstream. Next: the owner decides on upstream; `/planning-archive` after that.
