# Task: Ch 9's species and feature-type differences do not survive an event-level null (#6)

## Context

Ch 9 tests deer vs caribou (`09-activity.Rmd:169`, read at `:181`) and deer HumanUse vs Offline
(`:221`, read at `:224`) with `compareCkern()`, and reads both as real differences. Its null
resamples single images. Ch 9 uses raw detections (one row per image, bursts of frames per
event), so the null sits near 1 (0.95–0.96) and almost any difference reads as significant.
Shuffling the label across whole events (`newgraph/check_ch9_season.R`, log
`newgraph/logs/20261113_check_ch9_season.txt`, 200 reps, tz -6): deer vs caribou 0.78 vs null
0.79 (p 0.44, 562 vs 119 events); HumanUse vs Offline 0.83 vs null 0.76 (p 0.92, 87 vs 254
events). Neither survives under tz -6, -7 or DST-following, pooled or within a season.

What exploration found:

- `:181` also carries a copy error: it reads the deer vs caribou result as "if deer had the same
  activity pattern on both feature types". The log's image-level null for that comparison is
  0.95, the prose says 0.96 (compareCkern's null is unseeded, so it moves between renders).
- Fork PR 7 (`ch9-activity-season`, `20cbecf`, open, not yet in `newgraph`) adds a
  `## Season comparisons` section after `:224`, with the event shuffle written inline in its
  caribou chunk (`ch9_season_6`: `ev <- cs[!duplicated(cs$event_id), …]`, `replicate(100, …)`,
  `ovl4(fitact(…), fitact(…))`), plus a bullet "Try the event shuffle above on them" and an
  "On your own" line. Both branches touch the text right around `:224`.
- The worktree's `data/processed_data` is already a symlink to the main checkout's, so ch 9
  renders here. No other chapter uses `ch9_*` labels.
- `planning/active/` on `newgraph` is empty; no `planning/backlog.md`, so no claim (MOVE=0).

## Decided at the gate (approved by the user, 2026-11-13)

1. **Option 2** (owner, 2026-11-13, in #6's body): show the event shuffle on the feature-type
   comparison itself, and correct the readings at `:181` and `:224` to match what it shows.
2. **Own branch, self-contained** (owner, 2026-11-13): `ch9-event-level-null`, already cut from
   `origin/master` (`2c79f0e`) in the worktree `.claude/worktrees/issue6`. Skill steps 1b and 5
   skipped; the main checkout stays on `newgraph`.
3. **PWF on `newgraph`** in the main checkout's `planning/active/`, committed with
   `git -C <main checkout>`. Nothing of planning on this branch; no `#N` in its commits.
4. **The shuffle is a small function, `event_shuffle()`**, defined once in the treatment
   section (proposed here, approve or edit): it takes the data, the label column and the two
   labels, and returns observed overlap, mean null and p. One function is what lets the
   chapter explain the shuffle once and the season section (PR 7) call it in the reconcile,
   rather than carrying two inline copies.
5. **The species comparison is tested with the same function**, one call after the feature-type
   one, so the corrected reading at `:181` rests on a number the render prints. `:181` points
   forward to it rather than repeating the explanation.
6. **Chapter style as in #5**: `class.source="Rmain"`, `reps = 100`, `set.seed()` in the chunk,
   new labels `ch9_null_*` (nothing renumbered), prose figures taken from the render and worded
   to survive the seed ("well above 0.05", "about"). `docs/` and `_book` untouched.
7. **Reconcile**: whichever of PR 7 and this branch merges into `newgraph` second carries the
   reconcile commit (season section calls `event_shuffle()`, its "try the event shuffle on
   them" bullet goes, since this branch does that). Not done on this branch now.
8. **Nothing upstream.** Renders go to the scratchpad only (output_dir and intermediates_dir
   outside the repo, knit_root_dir this worktree).

## Phase 1: Baseline on `newgraph`
- [ ] Scaffold `planning/active/{task_plan,findings,progress}.md` in the main checkout; commit
      there with `git -C`, push `newgraph`
- [ ] Plan review (Plan agent, background) of this plan against the issue and the chapter;
      findings to `planning/active/review-plan.md`, folded in

## Phase 2: Render `master`'s ch 9 as the baseline
- [ ] Render `09-activity.Rmd` from the worktree, untouched, into the scratchpad
      (`rmarkdown::render(..., output_dir=<scratch>/base, intermediates_dir=<scratch>/base_int,
      knit_root_dir=<worktree>)`); keep its warnings, both `compareCkern` outputs and run time
- [ ] Count sites per feature type for deer (the issue's "9 HumanUse and 9 Offline") in R,
      read-only, before any prose uses it

## Phase 3: Chapter edits (branch `ch9-event-level-null`)
- [ ] `:181`: say what the deer vs caribou test compares (fix the "feature types" copy error);
      read `pNull` as what the image-level null says, flag it as optimistic, point to the
      treatment section's event-level check
- [ ] After `ch9_16`: a chunk printing images vs events for deer on each feature type
      (571 / 87, 2,053 / 254), and two or three sentences on why resampling frames of one burst
      makes the null near 1
- [ ] `ch9_null_*` chunk defining `event_shuffle()` (one label per event, shuffle labels among
      events, refit with `fitact()`, `ovl4()`), then run on HumanUse vs Offline
- [ ] Reading: observed 0.83 sits above the event-shuffle null (~0.76), because curves fitted to
      fewer events are noisier, so random groups of events overlap less than random frames; no
      evidence the feature types differ. One sentence: feature type belongs to the site and
      deer were at only ~9 sites per type, so a site-level shuffle would be stricter still
- [ ] Run `event_shuffle()` on deer vs caribou; one reading sentence
- [ ] `:224` rewritten to match the event-level result
- [ ] "On your own" left as is (PR 7 edits the same spot; the reconcile handles it)

## Phase 4: Render and check
- [ ] Render the branch's ch 9 the same way into `<scratch>/branch`; no new warnings or errors
      against Phase 2; run time noted (shuffle adds ~2 × 100 × 2 fits)
- [ ] Every number and quantifier in the new prose checked against the render output; read the
      plots
- [ ] `ch9_null_*` labels unique across the book
- [ ] `/code-check` on the diff, three-round floor (as #5), ended by enumerating every claim

## Phase 5: Commit, PR, report
- [ ] One commit on `ch9-event-level-null`: `09-activity.Rmd` only, no `#N`, attribution lines
- [ ] Push; fork PR into `newgraph` (`--repo NewGraphEnvironment/…`), body names the overlap
      with PR 7 and who carries the reconcile
- [ ] `/planning-archive` on `newgraph`; report with links

## Owed at the end (reported, done after merge)
- [ ] Reconcile with PR 7: whichever merges into `newgraph` second makes the season section call
      `event_shuffle()` and drops its duplicate explanation
- [ ] Merge the fork PR into `newgraph` (`/gh-pr-merge`, on the owner's word)
- [ ] The owner decides whether any of it goes upstream

## Validation
- [ ] Ch 9 renders clean from the branch into the scratchpad; baseline from `master` for comparison
- [ ] `/code-check` clean (three rounds on the chapter diff)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved: the branch render prints every figure the prose quotes (event counts,
observed overlap, shuffle null, p for both comparisons); the Phase 2 render shows nothing else
in the chapter changed; `git diff origin/master...ch9-event-level-null --stat` shows
`09-activity.Rmd` only; the numbers agree in direction with the measurement log.

