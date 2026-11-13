# Ch 12 independence step and the weekly frame's time zone (#1, later split into #1 and #4)

## Outcome

Two defects in the course book at `2c79f0e` were fixed on this fork, one branch each, cut clean
from `master`. On `ch12-independence-gap`, ch 12's independence step now uses ch 3's sort and gap.
On `weekly-detection-tz`, the detection-week label is taken in UTC, as the effort weeks already
were. Both were merged into `newgraph` by fork PRs 3 and 2. The fork's work is done. Sending
anything upstream is the owner's call: ch 12 is to be mentioned to the author in person, the
time-zone item waits until after the course, and drafts are in `upstream/`. Fork issues 1 (ch 12)
and 4 (time zone) stay open with `upstream-draft` and `upstream-held`. What we learned: the slip
came from upstream's `b8a5ca3` (2026-11-05). That commit dropped the event loop's `abs()` in both
chapters but fixed the sort and gap in ch 3 only.

## Measurement

Los Amigos, 69,096 mammal images identified to species once OFF067 is removed. Chapter text and
data were read at the same commit (`newgraph/check_fixes.R`).

| ref | written | week labels differing, UTC vs Vancouver |
|---|---|---|
| `master` `2c79f0e` | 831 | 35 of 831 |
| `ch12-independence-gap` `8278ddc` | 4,939 | 258 of 4,939 |
| `weekly-detection-tz` `18165f5` | 831 | 0 |
| `newgraph` `0471220` | 4,939 | 0; weekly total 4,939 in both zones |

Ch 12 undercounted independent detections about 6×. The time-zone item moved 258 detections
into the previous week on a Pacific machine without dropping any, which corrected the draft's
wording ("not counted" was true of the code but not of this data). The review rounds also caught
a draft figure (69,096 is the count identified to species, not all mammal images).

## Evidence

`newgraph/logs/20261112_check_fixes_*`; the review rounds are in `review-*.md` here.

## Owed

- The owner decides whether to send the upstream issue and offer the PR. If yes: post the
  issue text as approved, and offer the `Assisted-by` reword in any PR (no Claude
  co-authored commit is merged upstream)
- Revise the upstream-projects notes entry for this book (fix branches, measured results,
  the pin option), in the notes repo, not from here. Filed there 2026-11-13, with the
  correction that the rewrite (`b8a5ca3`, 2026-11-05) was pre-course
- Any downstream harness that patches these two spots may read this fork's `newgraph`
  instead; that is the harness owner's call, reported there

Closed by: fork PRs 3 (`4b96c1c`) and 2 (`0471220`) into `newgraph`; archived to free
`planning/active/` for #5.
