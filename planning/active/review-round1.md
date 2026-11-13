# Code-check review, round 1: `newgraph/check_ch9_season.R`, its log, findings.md "Measured"

## Checklist read

- code-check.md (read by heading): all 14 H3s under `## Mechanisms` read as prose (table rows
  skipped): A guard that fails toward pass; A fixture that cannot reach the failure mode; A proxy
  is not the property; Verification that reads its own output; A guard's scope, escape hatches,
  and remedies; A fix lands in one of two callers that share a harness; Restore the bug and prove
  the guard fires; A shared working tree, and what generators leave in it; A wrapper's exit is not
  the work; Zero-length, empty, and unset are three different things; The probe is broken before
  the world is; Written data outlives the fix; Serialization loses meaning silently; One fact
  derived twice. Not read: the 24 H3s under "Rules that stand alone", Security, and Spreadsheets
  and PDFs (none names a tool or shape this diff uses).
- code-check-r.md (read by heading): read 6 sections: `system2(stdout = TRUE)` warns on a non-zero
  exit; `ifelse()` with an all-NA test; `match()` treats NA as a matchable VALUE;
  `sample.int(prob =)` without replacement; Rscript reads a script as it runs; A dot-prefixed
  column name can be swallowed. 115 not read (index only).
- code-check-shell.md (read by heading): 0 read, 71 not read (the only shell is the `| tee` usage
  line, covered by code-check.md "A wrapper's exit is not the work").
- code-check-spatial.md (read by heading): 0 read, 94 not read (no sf/terra/GDAL; lat/lon only
  feed `get_suntimes`).

## What was checked and holds

- Join and solar time match ch9_2/5/6 (UTC parse, `left_join` on `project_id, placename`, 38
  unique placenames, 10,219 rows kept; `solartime(tz = -6)` over all images). `solartime()` does
  not pass its `tz` to `as.POSIXlt`, so the stored clock is read as UTC in every variant, as the
  chapter does.
- DST variant: Alberta MDT = UTC-6, MST = UTC-7; transition instants are wall-clock 02:00 on the
  stored clock; data span 2018-04-08 to 2019-11-21, so every boundary that matters is inside the
  window. Only the repeated 01:00-02:00 hour on the fall-back days is ambiguous (negligible).
- `first_of_event`: event_ids are globally unique, and every event is one site, one species and
  one month (1,543 of 1,543), so "first image" and the event's season are well defined.
- `block_null`: permutes season labels across events (counts of events per season fixed), maps
  them back to every image of the event, refits both curves the same way as `obs`; p =
  `mean(null <= obs)` is the correct lower tail (low overlap = different).
- `hdist` circular hour distance is correct, including unwrapped sunrise values.
- Log arithmetic in findings: season mixes (27/52/21, 8/69/23), HumanUse 27% / Offline 32% winter,
  -6 vs -7 max 0.269 rad = 1.03 h, -6 vs DST 1.89 h, every table cell, and "Decision 3's trigger
  is not met" (no share direction flips; no event-shuffle p crosses 0.05) all follow from the log.

## Findings

- **[severity: bug]** planning/active/findings.md:93-94 (new "What it says", fourth bullet) —
  "The feature-type difference is not a season artefact: it is at least as large within each
  season" is not supported by the log, and a probe contradicts it. The log tests HumanUse vs
  Offline only against compareCkern's image-resampling null, which the very next-but-one bullet
  (caribou) says is invalid because it treats an event's frames as independent. Applying the
  script's own event-shuffle null to feature type (shuffle `feature_type` across deer events,
  tz -6, 200 reps, seed 20261113, chapter data):

  | | obs | event-shuffle null (5th pct) | p | events HU vs Off |
  |---|---|---|---|---|
  | pooled | 0.83 | 0.75 (0.67) | 0.960 | 87 vs 254 |
  | winter | 0.72 | 0.60 (0.44) | 0.895 | 21 vs 74 |
  | summer | 0.63 | 0.70 (0.61) | 0.105 | 54 vs 129 |

  So once events are kept whole there is no detectable feature-type difference pooled or within
  either season, and the lower within-season overlaps (0.72, 0.63) are about what the smaller
  event counts alone produce (null means 0.60, 0.70). "At least as large within each season"
  compares raw overlaps whose no-difference baselines differ by sample size. (Also only 6 HumanUse
  sites in winter, 8 in summer, so site clustering would widen the null further.) This matters
  for Phase 3, whose planned prose says the pooled feature-type comparison "mixes seasons": the
  same caution the findings give caribou applies to the chapter's 0.83 itself. The deer-vs-caribou
  within-season overlaps (0.73 summer, 0.52 winter) carry the same caveat, since they too were
  tested only at image level.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: bug]** planning/active/findings.md:89-90 (second bullet) — "12 winter events at 6
  sites, in one winter, carry it" is wrong. The 12 caribou winter events fall in two winters: 6
  between 2018-11-04 and 2019-03-02 (ALG032, 037, 035, 073, 070) and 6 between 2019-11-14 and
  2019-11-20 (ALG073, 070, 038), half of them in one week of November 2019. The log does not
  report years, so the claim came from neither it nor the script. The corrected fact (half of
  caribou "winter" is one November week) strengthens the caution, and is what Phase 3's prose
  should say if it describes the 12 events.
  - **Rule:** none
