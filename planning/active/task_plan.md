# Task: Does pooling seasons in ch 9 hide changes in daily activity? (#5)

Ch 9 fits one activity curve per species over every month of the year. `solartime()` (`09-activity.Rmd:101`) puts sunrise and sunset at the same place on the axis all year, so a winter dusk is not lost to the short day. But does pooling the seasons hide how the animals actually change their daily timing, and does it change what the deer-vs-caribou and feature-type comparisons mean?

## Context

Ch 9 (`09-activity.Rmd`) fits one activity curve per species over the whole year, in solar
time (`solartime()`, line 101, `tz = -6`). Issue 5's first look (from `images.csv`) found that
deer and caribou keep different daily timing in winter and summer (winter vs summer overlap 0.53
for deer, 0.44 for caribou), and the dusk peak is mostly a summer one. Because each species'
detections are spread unevenly over the year, a pooled curve leans toward one season. The issue
asks for a seasonal section in ch 9, run on the chapter's own processed detections, and a check
of the fixed `tz = -6`.

What exploration found:

- Ch 9 is identical on `master` (`2c79f0e`, = upstream) and `newgraph`. It reads
  `data/processed_data/AlgarRestorationProject_raw_detections.csv` (10,219 rows, one per image,
  with `event_id`), which is present locally.
- On that file, winter (Nov–Mar) and summer (May–Aug) image counts are close to the issue's:
  deer 1,271 / 2,514, caribou 65 / 542. **Caribou winter is 65 images from 12 events at 6 sites**,
  so its curve rests on very few events. Deer winter is 137 events at 18 sites.
- `solartime(dat, lat, lon, tz)` takes the wall-clock time as given (`gettime`) and places
  sunrise and sunset using `tz`. So `tz` moves only the solar axis. If the cameras kept MST
  (UTC−7) all year, `tz = -6` puts every anchor an hour off; if they followed DST, it is right
  in summer only. Nothing in the data says which: `deployments.csv` and `projects.csv` have no
  time-zone field, the cameras are Browning BTC-5HDX, and there are no images on the DST-start
  days that a probe could test. That makes it a sensitivity analysis plus a question for the
  author.
- Fork rules (`CLAUDE.md`): the work goes on its own branch cut clean from `master`, with no
  planning files and no `#N` in its commits, and is merged into `newgraph` by a fork PR. The PWF
  lives on `newgraph`. `planning/active/` currently holds fork #1's PWF, which still owes the
  owner's upstream decision.
- The owner runs the course from this checkout on `newgraph`, so this checkout is not switched.
  Skill step 1b's move to `origin/master` is skipped for the same reason.

## Decided at the gate (approved by the user, 2026-11-13)

1. **#1's PWF is archived first** to `planning/archive/2026-11-issue-1-…/`, with
   `## Owed: the owner's upstream decision (ch 12 in person; tz after the course)`. Fork issues
   1 and 4 stay open. This frees `planning/active/` for #5.
2. **Branch `ch9-activity-season`** (the issue's name) cut from `origin/master` with
   `git branch`, checked out in a worktree at `.claude/worktrees/ch9-season`.
   `data/processed_data` there is a symlink to the main checkout's, so ch 9 reads the same files
   (the cause of the 11-13 `read.csv` failure was a worktree without that data). The main
   checkout stays on `newgraph`.
3. **One concern per branch.** If the `tz` sensitivity shows `-6` changes a conclusion, the fix
   to `solartime()`'s `tz` goes in a new fork issue and branch, not in this one.
4. **The chapter section matches the chapter's style**: `class.source="Rmain"` chunks,
   `reps = 100`, figures quoted in prose (the chapter's existing convention, e.g. the 0.78 at
   line 181), taken from the render. New chunk labels are `ch9_season_*`, so nothing is
   renumbered. `docs/` and `_book` are not touched.
5. **Nothing goes upstream.** The issue's "decide afterwards" stays the owner's call.
   Commits keep `Co-Authored-By: Claude` and carry no session link (public repo).

## Phase 1: Free `planning/active/` and lay the baseline (on `newgraph`)
- [x] `/planning-archive` #1's PWF with the owed upstream decision in its README (`16ccf29`)
- [ ] Scaffold `planning/active/` for #5 with this plan; commit and push `newgraph`
- [x] Plan-agent review in the background (`planning/active/review-plan.md`): no blockers

## Phase 2: Measure on the chapter's own data (`newgraph/check_ch9_season.R`)
- [ ] Script reads `raw_detections.csv` and `camera_locations_and_covariates.csv` exactly as
      ch 9 does, records its git sha and input md5, and sets a seed
- [ ] Per species (deer, caribou) × season: images, events, sites; winter vs summer
      `compareCkern` (obs, null, pNull); share of images within 2 h of sunrise and of sunset
- [ ] The same again with one record per event (the event's first image), to show what the
      12 caribou winter events can carry. A check, not the chapter's method: ch 9 follows Peral
      et al. on raw data
- [ ] Feature types: the season mix of deer images on HumanUse vs Offline, and HumanUse vs
      Offline overlap within summer and within winter, against the pooled 0.83
- [ ] `tz` sensitivity: every figure above under `tz = -6`, `-7`, and DST-following
      (`-6` from 2018-03-11 to 2018-11-04 and 2019-03-10 to 2019-11-03, `-7` otherwise, on
      the stored clock); report the spread. Decision 3's trigger: a qualitative conclusion
      flips between variants (direction of the dawn/dusk shares, or the event-shuffle p
      crossing 0.05)
- [ ] Review additions: a null that shuffles season across whole events, a core-months
      check (Dec–Feb vs Jun–Jul), deer vs caribou within each season, a guard that a `tz`
      vector is applied per row (`review-plan.md`)
- [ ] Log to `newgraph/logs/<yyyymmdd>_check_ch9_season.txt`; table in `findings.md`
- [ ] `/code-check` on the script; commit with the log

## Phase 3: Season section in ch 9 (branch `ch9-activity-season`, worktree)
- [ ] Create branch and worktree, symlink `data/processed_data`
- [ ] Add `## Season comparisons` between "Treatment comparisons" and "On your own":
      a `season` column from the month, deer winter vs summer `fitact` + overlay plot +
      `compareCkern`, then caribou, with the caution that its winter curve rests on 12 events
- [ ] Two or three sentences reading it: the dusk peak is mostly summer, the solar-time
      transform does not remove a real seasonal shift, and the pooled species and feature-type
      comparisons each mix seasons in different proportions (figures from Phase 2)
- [ ] One "On your own" line inviting other strata by season. The `tz` text is left as it is
      unless Phase 2 says otherwise (decision 3)

## Phase 4: Render and check
- [ ] Render `09-activity.Rmd` alone from the worktree into the scratchpad
      (`rmarkdown::render(..., output_dir = <scratch>, knit_root_dir = <worktree>)`); no errors
      or warnings beyond what `master` already gives (render `master`'s ch 9 the same way, in
      the worktree before the edit)
- [ ] Prose figures match the render log; read the plots
- [ ] No `ch9_season_*` label elsewhere in the book (bookdown merges chapters)
- [ ] `/code-check` on the diff (three-round floor)

## Phase 5: Commit, PR, report
- [ ] One commit on `ch9-activity-season`: no planning files, no `#N`, `Co-Authored-By` only
- [ ] Push; fork PR into `newgraph` (`--repo NewGraphEnvironment/…`), body says Claude Code helped
- [ ] Edit fork issue 5's body with the measured table and the `tz` result (the findings are
      the spec), and file the `tz` issue if decision 3 is triggered
- [ ] `/planning-archive`; remove the worktree; report with links

## Owed at the end (reported, done after merge)
- [ ] Merge the fork PR into `newgraph` (`/gh-pr-merge`, on the owner's word)
- [ ] Ask the author how the Algar cameras kept time (MST all year, or DST)
- [ ] The owner decides whether any of it goes upstream

## Validation
- [ ] `/code-check` clean on the script and on the chapter diff
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved: the script's log gives every figure with its input md5 and sha,
under each `tz`; the ch 9 render from the branch runs clean and its log carries the figures the
prose quotes; `git diff origin/master...ch9-activity-season --stat` shows `09-activity.Rmd` only.

