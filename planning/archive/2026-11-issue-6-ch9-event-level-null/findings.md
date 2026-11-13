# Findings — Ch 9's species and feature-type differences do not survive an event-level null (#6)

## Issue context

## What we saw

Ch 9 tests its two comparisons with `compareCkern()` and reads both as real differences
(`09-activity.Rmd:181` and `:224`, "This suggests the patterns differ"):

- deer vs caribou: overlap 0.78 against a null of 0.95–0.96
- deer on HumanUse vs Offline lines: overlap 0.83 against a null of 0.96

`compareCkern()` builds its null by resampling single images. Ch 9 uses raw detections, one row
per image, and images come in bursts (deer: 571 HumanUse images from 87 events, 2,053 Offline
from 254). Resampling single frames treats each frame of a burst as an independent observation,
so the null overlap sits near 1 and almost any difference reads as significant.

Shuffling the label across whole events instead, which keeps each event's images together, gives
(`newgraph/check_ch9_season.R`, log `newgraph/logs/20261113_check_ch9_season.txt`, 200 reps,
`tz = -6`):

| comparison | obs | event-shuffle null | p |
|---|---|---|---|
| deer vs caribou | 0.78 | 0.79 | 0.44 |
| deer HumanUse vs Offline | 0.83 | 0.76 | 0.92 |

Neither is distinguishable from chance at event level, pooled or within winter or summer, under
`tz = -6`, `-7` or a DST-following offset. Deer winter vs summer (fork #5) passes the same test
easily (0.52 against 0.78, p < 0.005).

Feature type is a property of the site, and deer were detected at 9 HumanUse and 9 Offline sites,
so a site-level shuffle would be stricter still; it has not been run.

## Options as we see them

1. Leave the chapter's code, and change the two readings to say the image-level test is
   optimistic, pointing to the event-level check in the season section.
2. Show the event shuffle on the feature-type comparison itself, since that is the chapter's
   treatment example.
3. Leave it: the chapter follows Peral et al. in using raw images for the curves, and the null is
   a separate question.

This does not touch the season section (branch `ch9-activity-season`), which already teaches the
event-level check. Nothing upstream; the owner decides after the course.


## Decisions

- **Option 2** (owner, 2026-11-13): show the event shuffle on the feature-type comparison itself,
  and correct the readings at lines 181 and 224 to match what it shows.
- **Its own branch, cut clean from `master`**, self-contained (it introduces the event shuffle
  where it fixes the comparisons). The season section (branch `ch9-activity-season`, fork #5)
  also introduces the shuffle, in its caribou example. Whichever of the two merges into
  `newgraph` second carries a small reconcile commit, so the chapter explains the shuffle once
  and the later section reuses it.
