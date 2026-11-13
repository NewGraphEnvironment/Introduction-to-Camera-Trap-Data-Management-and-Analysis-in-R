# Code-check review, round 3: `newgraph/check_ch9_season.R`, its log, findings.md "Measured"

## Checklist read

- code-check.md (read by heading): all 14 H3s under `## Mechanisms` read as prose, table rows
  skipped. 24 not read (Rules that stand alone, Security, Spreadsheets and PDFs): none names a
  tool or shape this diff uses.
- code-check-r.md (read by heading): 6 read: `match()` treats NA as a matchable VALUE;
  `ifelse()` with an all-NA test; `system2(stdout = TRUE)` warns on a non-zero exit; `$` on a
  list partial-matches; as.POSIXct on a Date pins UTC midnight; `sort()` and `order()` collate
  by `LC_COLLATE`. 115 not read.
- code-check-shell.md (read by heading): 0 read, 71 not read. The only shell is the
  `2>&1 | tee` usage line; covered by code-check.md "A wrapper's exit is not the work" (the log
  ends on the script's last `cat`, with no `Error`/`Execution halted`).
- code-check-spatial.md (read by heading): 0 read, 94 not read (no sf, terra or GDAL).

## The mechanism behind rounds 1 and 2

One shared assumption: **a number in findings.md is right because it was right when it was
written.** The prose is a second, hand-kept copy of facts whose producer is the log (or, for a
few, the data). When the producer moved (re-run, new RNG stream) or the copy was assembled from
a different population than its sentence names (image-level null for an event-level claim; all
camera sites for deer sites; -6 values inside a "-7 and DST" range), nothing compared the copy
to its producer. code-check.md "One fact derived twice" and "Written data outlives the fix"
("enumerate every artifact quoting it ... verify by parsing"). Generating table 1 closes it for
24 cells. It still reaches every other number and every quantifier in the section.

## Every place it reaches, checked against the log (`newgraph/logs/20261113_check_ch9_season.txt`)

- Table 1 (24 cells): re-checked by hand against log lines 30-37, 60-67, 89-96. All match.
- Share table (12 cells): log lines 39-42, 69-72, 98-101. All match.
- Pooled vs within-season table, tz -6 (18 values): log lines 44-55. All match; p shown at
  2 dp (0.375 -> 0.38, 0.535 -> 0.54, 0.915 -> 0.92, 0.855 -> 0.86).
- Range sentence: species pooled p 0.440 / 0.250 / 0.370 -> 0.25-0.44; feature pooled
  0.915 / 0.910 / 0.950 -> 0.91-0.95; feature summer 0.130 / 0.065 / 0.075 -> 0.065-0.13.
  "No variant reaches 0.05" holds for all 24 event-shuffle p values except deer winter vs summer
  (which the bullets single out).
- Season mix: deer 27/52/21, caribou 8/69/23 (log 14, 20). HumanUse 154/571 = 27.0%, Offline
  654/2053 = 31.9% (log 24, 26).
- 9 HumanUse and 9 Offline deer sites: not in the log; re-probed from the joined data: 9 / 9
  (NatRegen 9). Holds.
- "image-level pNull is 0.000": caribou images pNull 0.000 under all three variants. "p 0.26 at
  best": 0.260 / 0.850 / 0.965. "12 winter events at 6 sites": log 18-19.
- "69% summer, deer 52%": log 14, 20.
- "1.0 h / 1.9 h": 0.269 rad x 12/pi = 1.03 h; 1.89 h (log 117-118).
- "caribou 0.45 -> 0.73": caribou images obs, -6 vs DST.
- "deer winter vs summer significant everywhere": event-shuffle p 0.000 in all three variants.
- "nothing else at event level anywhere": every other event-shuffle p (21 values) and the caribou
  one-image-per-event pNull (0.155 / 0.485 / 0.700) are above 0.05.
- "share directions unchanged" (Decision 3's trigger): winter vs summer and sunrise vs sunset
  directions are the same in all three variants for both species; the closest, deer DST sunrise
  25% vs 24%, still has winter above summer at full precision (rounding bounds).
- "deer winter sunset 15% at -6, 10% at -7": log 39, 69.
- Inputs: md5 of both data files today equals the log's; script mtime 18:04:38 UTC precedes the
  run stamp 18:04:44 UTC; nothing unstaged.

Script re-checked: `activity:::get_suntimes` returns hours (`(n - that)/60 - lon_h + offset`),
so `hdist(clock_h, sun$sunrise)` compares hours with hours; `solartime()` validates a tz vector's
length and type; no NA or empty `event_id` or `feature_type`; each `event_id` has one placename
and one species (1,543 events); `$` reads are on exact names.

## Findings

- **[severity: fragile]** planning/active/findings.md:104-105 — "deer vs caribou (0.78, p
  0.25–0.44) and HumanUse vs Offline (0.83, p 0.91–0.95)" pairs the tz -6 (and DST) observed
  overlap with a p range taken across all three variants. Under -7 the observed values are 0.76
  and 0.81 (log 74, 80), and p 0.25 is the -7 species value, so the 0.78 never occurs with
  p 0.25. Read as "obs 0.78, p between 0.25 and 0.44", the pair names a population no single run
  produced: the same shape as round 2's range sentence. The conclusion (neither survives the
  event-level null) is unaffected. Either say "0.76–0.78" and "0.81–0.83", or label the obs as
  the chapter's tz -6 value.
  - **Rule:** code-check.md "One fact derived twice" ; code-check.md "A guard's scope, escape hatches, and remedies"

No other issue: every other number and quantifier in the diff follows from the log or, for the
site count, from the data.
