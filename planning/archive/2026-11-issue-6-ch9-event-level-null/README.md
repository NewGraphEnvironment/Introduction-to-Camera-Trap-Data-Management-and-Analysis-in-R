# Ch 9's species and feature-type differences do not survive an event-level null (#6)

## Outcome

Ch 9 now tests its two activity comparisons against a null that keeps each detection event's images together. The change is on branch `ch9-event-level-null` (`aa7ee42`, fork PR 8 into `newgraph`).

- **What changed.** A small function, `event_shuffle()`, shuffles the label among whole events, or among whole sites with `id = "placename"`, and refits both curves. The chapter runs it on deer HumanUse vs Offline and on deer vs caribou, and both readings now say there is no evidence of a difference.
- **Why the old test failed.** `compareCkern()` resamples single images, so frames from one burst count as independent observations and its null sits near 1. Its `pNull` is `ecdf(null)(obs)`, the same quantity the new `p` reports.

What was learned:

- **A coarser shuffle does not always push p up.** The plan assumed a site-level shuffle "could only weaken the result". Measured, the site null is higher than the event null (0.80 against 0.76) and p is lower (about 0.8 against 0.92–0.96). The chapter now runs the site-level test rather than asserting its direction.
- **A null's mean is not *the* expectation.** "Lower than we would expect (0.95)" read `compareCkern`'s null as the truth. The prose now attributes each expected value to the null that produced it.

Wrong turns, kept as evidence:

- The plan's first reading of obs 0.83 above the event null 0.76 blamed small-sample noise. That noise explains why the event null sits below the image null, not where obs falls; obs is one draw from the same null (plan review).
- The first single-chapter render used the book's gitbook format from `_output.yml`, which split pages into the worktree (`404.html`, `activity.html`, `libs/`). They were removed, and renders now pass `output_format = html_document`.
- `/code-check`'s gate (`file:NAMESPACE|glob:*.R`) does not load `code-check-r.md` on an `.Rmd`-only branch, so it was added by hand.

## Measurement

From the chapter's own render on the Algar raw detections: seed 9, 100 reps, `tz = -6`.

| comparison | groups | obs | `compareCkern` null | shuffle null | p |
|---|---|---|---|---|---|
| deer HumanUse vs Offline, by event | 87 vs 254 events | 0.83 | 0.96 | 0.76 | 0.91 |
| same, by site | 9 vs 9 sites | 0.83 | | 0.81 | 0.78 |
| deer vs caribou, by event | 562 vs 119 events | 0.78 | 0.95 | 0.79 | 0.47 |

Under seeds 1–3 the results hold:

- **Feature type, by event:** p 0.92–0.96.
- **Deer vs caribou:** null 0.80, p 0.33–0.43.
- **Feature type, by site (200 reps):** null 0.80, p 0.82–0.825.
- **Image-level control:** the function with one id per image gives a null of 0.942 and p 0, which reproduces `compareCkern`'s inflation (round 2).
- **Run time:** ch 9 renders in about 64 s, against 41 s on `master`; each shuffle call takes about 6 s.

What changed because of these numbers: both readings were corrected, and the site-level test is shown in the chapter instead of claimed.

## Evidence

- `newgraph/logs/20261113_check_ch9_season*`: the measurement behind the issue (200 reps, three `tz` variants).
- `review-*.md` here: the plan review, round 1, round 2 and round 3b. Round 3b enumerates 32 claims, each with its source. Round 3 was lost to a network error and re-run as 3b.

## Owed

- Reconcile with PR 7, by whichever merges into `newgraph` second (expect a textual conflict
- Merge the fork PR into `newgraph` (`/gh-pr-merge`, on the owner's word)
- The owner decides whether any of it goes upstream

The reconcile in full, if PR 8 lands first:

- The `ch9_season_5` paragraph stops re-explaining the image-level null.
- `ch9_season_6` becomes `event_shuffle(cs, "season", "winter", "summer")`, and its "about 0.5" and "about a third" are rechecked under `set.seed(9)`.
- "Swap the species in the chunk above" changes.
- The bullet "Try the event shuffle above on them" goes.
- The "On your own" line points to the treatment section.

Fork PR 8 lists the same items.

Closed by: fork PR 8 (`ch9-event-level-null`, `aa7ee42`), open.
