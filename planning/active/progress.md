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

## Session 2026-11-12 (later): ready the in-person heads-up

- Decided with the owner, who is at the course in person: tell the author about the ch 12 slip privately, at a break. Nothing public mid-course. The time-zone item waits until after the course. Nothing is filed upstream unless it is still useful afterwards.
- History: the slip came from `b8a5ca3` (2026-11-05). It replaced the event loop, which compared `abs(duration)`, with `duration > threshold` in both chapters, and fixed the sort and gap in ch 3 only.
- Fork issue 1 is rewritten as the ch 12 item alone. The time-zone item is split out to fork issue 4. Both are labelled `upstream-draft` and `upstream-held`.
- Upstream PR bodies drafted, not opened: `planning/active/upstream/`.
- In-person line: "Small thing on ch 12 before people do 'On your own': I think last week's ch 3 change to the independence step didn't make it into ch 12. It still sorts by deployment only and has the gap the old way round, and without the old `abs()` it undercounts: on Los Amigos I get 831 detections versus 4,939 with ch 3's lines. Happy to show you or send a PR, whatever's easiest."
- To show him: https://github.com/NewGraphEnvironment/Introduction-to-Camera-Trap-Data-Management-and-Analysis-in-R/compare/master...ch12-independence-gap

## Session 2026-11-13: one checkout, CLAUDE.md

- The session's worktree (`.claude/worktrees/detect`) was removed; the main checkout is now on `newgraph`, and the owner works the course from its `WildCo_Data_Analysis.Rproj`. The cause was a `read.csv` failing in ch 5: the downloaded covariates file sat in the main checkout's `data/processed_data/` while R ran in the worktree.
- `CLAUDE.md` added on `newgraph` (`9c703e3`) with `.claude/visibility` = public and `<!-- conventions-branch: newgraph -->`, so convention syncs never touch `master`.
- The notes-repo entry revision is filed in the notes repo (fix branches, measurements, rewrite was pre-course).
- Still owed: the owner's upstream decision (in-person mention of ch 12 first), then `/planning-archive`.
