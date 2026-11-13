# Task: Ch 12 independence step and the weekly frame's time zone (#1)

Fork issue 1 is a draft report (labels `upstream-draft`, `upstream-held`) on two defects in
the course book at `2c79f0e`. That commit is the tip of both `origin/master` and upstream
`master` (checked by API 2026-11-11).

1. Ch 12's independence step sorts by `deployment_id` only and takes
   `int_length(timestamp %--% lag(timestamp))`. That is negative for rows in time order, so on
   Los Amigos (69,096 mammal images, OFF067 removed) ch 12 writes 831 independent detections;
   ch 3's method writes 4,939.
2. The weekly frame labels effort weeks with `tz = "UTC"` and detection weeks in the machine's
   time zone. On Pacific time, 258 of the 4,939 detections get the previous week's label.

Goal: fix both on the fork, one branch per concern, and measure each fix on the book's own
Los Amigos data. Ch 12 should write 4,939, and under `TZ=America/Vancouver` no detection should
get a different week label than it does under UTC. Nothing is posted upstream; the owner then
decides whether to send the issue and offer a pull request.

## Decided at the gate (approved by the user, 2026-11-11)

1. **Integration branch `newgraph`**, cut from `origin/master` (`2c79f0e`). It holds
   `planning/` (PWF), the measurement script and its logs, and both concern branches merged in.
   It never goes upstream, so its commits may name fork `#1`.
2. **Concern branches**, each cut clean from `2c79f0e`, with no planning files and no `#N` in
   any commit:
   - `ch12-independence-gap`: ch 12's two lines take ch 3's method.
   - `weekly-detection-tz`: `tz = "UTC"` on the detection-week line in ch 12 and in ch 3.
   Commits keep the `Co-Authored-By: Claude` trailer. No session link. Upstream items, if named
   at all, go in backticks.
3. **Minimal diffs.** Concern 1 changes only the `arrange()` line and the `mutate()` line,
   copying ch 3's code and comments, which also replaces the truncated comment
   `# Calculate the gap bet`. Ch 3's `ungroup()` is left out, because the 4,939 figure was
   measured without it. The rendered `docs/` and `_book` are not touched.
4. **Fork PRs, not upstream PRs.** Each concern branch goes to `newgraph` as a fork PR. Every
   `gh` write passes
   `--repo NewGraphEnvironment/Introduction-to-Camera-Trap-Data-Management-and-Analysis-in-R`.
   Bodies say Claude Code helped, carry no session link, link no private repos, and keep
   upstream references in backticks.
5. **The measurement goes in the fork.** The script and its log are committed on `newgraph`,
   with a comment on fork issue 1 giving the table and branch names. No text names or links
   private repos.

## Phase 1: Integration branch and PWF baseline
- [x] `git checkout --no-track -b newgraph origin/master` (at `2c79f0e`)
- [x] `planning/README.md` and `planning/{active,archive}/.gitkeep`, then commit "Initialize planning directory structure"
- [x] `planning/active/{task_plan,findings,progress}.md` from this plan, then commit "Initialize PWF baseline for #1"
- [x] Push `newgraph` to origin

## Phase 2: Measurement script (on `newgraph`), baseline run on master
- [x] `newgraph/check_fixes.R <git-ref>` reads `12-on_your_own.Rmd` and `03-error-checking.Rmd`
      at that ref (`git show <ref>:<file>`). It copies `data/raw_data/your_data/` to a temp
      dir and runs ch 12's chunks there by phrase: read, dates, remove OFF067, species list,
      filter, effort lookup, threshold, the hidden `animal_count` chunk, independent
      detections. Nothing is patched except the package-install line. Any phrase or
      substitution that does not match exactly once stops the run.
- [x] It reports the images entering the independence step (expected 69,096), the event IDs
      (`_raw_detections.csv`), and the rows in the written `_30min_independent_detections.csv`.
- [x] Time zone: it pulls the detection-week expression out of the weekly chunk text of ch 12
      and of ch 3 (the `strftime(ind_dat$timestamp …)` call) and evaluates each on `ind_dat`
      under `Sys.setenv(TZ = "UTC")` and then `"America/Vancouver"`. A guard confirms the TZ
      switch took effect, using a known Sunday 03:00 UTC timestamp. It counts the detections
      whose label differs.
- [x] It runs ch 12's analysis-frames chunk (the total, monthly and weekly frames) under both
      TZs, reports the weekly observation totals, and says whether `week_obs` is identical
      under the two.
- [x] Baseline run on `2c79f0e`, log to `newgraph/logs/<yyyymmdd>_check_fixes_master.txt`.
      Expected: 852 events, 831 written. The label difference on 831 detections is reported,
      with no expected value.
- [x] `/code-check`, then commit on `newgraph`

## Phase 3: Concern 1, `ch12-independence-gap`
- [x] Branch from `2c79f0e`. In `12-on_your_own.Rmd:446,448`, use ch 3's
      `arrange(deployment_id, sp, timestamp)` and `int_length(lag(timestamp) %--% timestamp)`,
      with ch 3's comments
- [x] `/code-check`, then commit (message names no issue). One review covered both concern diffs over 4 rounds (review-concerns-round1..4.md)
- [x] Measure: `check_fixes.R ch12-independence-gap`: 5,027 events, 4,939 written, 258 of 4,939 differ (local `8278ddc`)
- [x] Push, then open a fork PR into `newgraph` that carries the measured numbers (fork PR 3; the
      amended `8278ddc` was force-pushed over `39cc573` with the owner's go-ahead, 2026-11-12)

## Phase 4: Concern 2, `weekly-detection-tz`
- [x] Branch from `2c79f0e`. Add `, tz = "UTC"` to the detection-week `strftime` at
      `12-on_your_own.Rmd:627` and `03-error-checking.Rmd:1441`
- [x] `/code-check`, then commit (message names no issue)
- [x] Measure: `check_fixes.R weekly-detection-tz`: 831 written, 0 / 0 differ, weekly frame identical (`18165f5`)
- [x] Push, then open a fork PR into `newgraph` that carries the measured numbers (fork PR 2)

## Phase 5: Integrate and measure together
- [x] Merge both fork PRs into `newgraph` (merge commits), then pull
- [x] Measure: `check_fixes.R newgraph`: 4,939 written, 0 / 0 of 4,939 differ, `week_obs` identical, weekly total 4,939 under both TZs (`0471220`)
- [x] Commit the logs and the four-run table in `findings.md`
- [x] Comment on fork issue 1 with the table and the two branch names, with nothing upstream.
      Leave the labels as they are; the owner decides whether to send the issue

## Owed at the end (reported, done after merge)

- [ ] The owner decides whether to send the upstream issue and offer the PR. If yes: post the
      issue text as approved, and offer the `Assisted-by` reword in any PR (no Claude
      co-authored commit is merged upstream)
- [ ] Revise the upstream-projects notes entry for this book (fix branches, measured results,
      the pin option), in the notes repo, not from here. Filed there 2026-11-13, with the
      correction that the rewrite (`b8a5ca3`, 2026-11-05) was pre-course
- [ ] Any downstream harness that patches these two spots may read this fork's `newgraph`
      instead; that is the harness owner's call, reported there

## Validation

- [x] Tests pass (the measurement script's asserts; all four runs exit 0)
- [x] `/code-check` clean (script: 4 rounds, ended clean; concern diffs: 4 rounds, ended by enumerating every figure)
- [x] PWF checkboxes match landed work
- [x] `/planning-archive` on completion
- [x] Measurement table, written / labels differing: master 831 / 35;
      concern 1 4,939 / 258; concern 2 831 / 0; newgraph 4,939 / 0
- [x] `git diff 2c79f0e <concern>` touches only the intended lines, and `git ls-tree` shows
      no `planning/` and `git log` shows no `#N` on either concern branch

Verification is the measurement script run against four git refs, all from the Rmd text at
each ref, on the book's own data, in a temp dir. It writes nothing into the checkout except
its logs.
