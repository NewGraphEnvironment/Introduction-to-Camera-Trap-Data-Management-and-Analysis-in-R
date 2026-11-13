# Does pooling seasons in ch 9 hide changes in daily activity? (#5)

## Outcome

Pooling blends two different deer curves, though overlap cannot say why; caribou's apparent
shift is not supported. Ch 9 now has a "Season comparisons" section, on branch
`ch9-activity-season` (`20cbecf`, then `6bfa636`, fork PR 7 into `newgraph`). It splits deer and caribou into
winter (Nov–Mar) and summer (May–Aug), compares the curves, and tests the caribou difference with
a null that shuffles the season label across whole detection events. Three lessons came out of
it:

- `compareCkern`'s null resamples single images. On raw detections, where one visit is several
  frames, that makes almost any difference look significant. Kept to whole events, only the deer
  seasonal shift survives. The chapter's own species and feature-type differences (0.78, 0.83) do
  not, which is filed as fork #6 (option 2, its own branch, decided by the owner).
- Solar time is not a neutral axis between seasons. Average anchoring squeezes the long winter
  night and the short summer night onto the same stretch, so a deer keeping one clock routine all
  year would show a seasonal overlap of 0.45–0.59 on it, about the real deer's 0.52. A clock-time
  comparison (0.66 against 0.95) rules a fixed clock routine out. A routine timed from dusk would
  fail both tests too, so overlap cannot say what the deer do instead.
- The `tz` offset moves magnitudes but no conclusion.

Wrong turns, kept as evidence:
- The plan assumed a constant `tz` change would cancel out of double-anchored solar time. The
  first run showed it does not: the stored clock stays put while sunrise and sunset move.
- The first draft described the deer plot without looking at it.
- A splice that regenerated a table duplicated half of `findings.md`; it was restored from the
  index.
- The day-length baseline was first a "sun-blind" deer with uniform clock times (about 0.7), read
  as showing the deer's 0.52 was a real shift. A realistic clock routine gives 0.45–0.59, and a
  dusk-timed one fails both axes; the chapter, PR 7 and #5's body were corrected (second review
  pass, rounds 3 and 4, after the archive).

## Measurement

On the Algar raw detections (10,219 images), tz -6, 200 reps:

- **Deer, winter vs summer:** overlap 0.52. compareCkern's null is 0.96 and the event-shuffle
  null 0.78 (p 0.000). On clock time 0.66 (null 0.95). A simulated deer keeping one clock
  routine gives 0.45–0.59 on solar time; one timing its day from dusk gives solar 0.53–0.57 and
  clock 0.60–0.67. Night share of events rises from 20% in summer to 75% in winter, which a fixed
  clock routine also produces (72–78%).
- **Caribou, winter vs summer:** overlap 0.45. The event-shuffle null is 0.51 (p 0.26), on 12
  winter events at 6 sites.
- **Chapter comparisons at event level:**
  - deer vs caribou: 0.78 against a null of 0.79 (p 0.44)
  - HumanUse vs Offline: 0.83 against 0.76 (p 0.92)
- **tz -6 / -7 / DST-following:**
  - Deer seasonal p is 0.000 under every variant.
  - Caribou overlap ranges 0.45 to 0.73.
  - No event-level p other than deer's reaches 0.05.
  - So the chapter keeps `tz = -6`, and the decision-3 trigger (a separate `tz` fix) was not met.

What changed because of these numbers: the section teaches the event-level check instead of
reporting a caribou shift, and fork #6 exists.

## Evidence

- `newgraph/logs/20261113_check_ch9_season*`: the measurement log
- `newgraph/check_ch9_season.R`: the script that produced it
- `review-*.md` here: the plan review and six code-check rounds, three on the script and three on
  the chapter

## Owed

- Reconcile with fork #6: whichever of fork PR 7 and fork #6's branch merges into `newgraph` second explains the event shuffle once and reuses it
- Merge the fork PR into `newgraph` (`/gh-pr-merge`, on the owner's word)
- Ask the author how the Algar cameras kept time (MST all year, or DST)
- The owner decides whether any of it goes upstream

Closed by: fork PR 7 (`ch9-activity-season`, `20cbecf`), open; measurement in `cf9a3da` on `newgraph`.
