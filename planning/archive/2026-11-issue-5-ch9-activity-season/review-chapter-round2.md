# Review: ch 9 "Season comparisons" diff, round 2

## Checklist read

- code-check.md (read by heading): I read the prose of all 14 H3s under `## Mechanisms`, skipping the `|` table rows. The ones I applied: "A proxy is not the property" (a sentence describing a figure is a claim, so compute the share it claims), "A guard's scope, escape hatches, and remedies" (a reviewer's prescribed wording is an unexecuted claim, and the class recurs one axis over), "The probe is broken before the world is" (write the numbers last, against the final tree) and "A fixture that cannot reach the failure mode" (samples that share one value of a variable cannot say whether it matters). I did not read about 20 headings: everything under "Rules that stand alone", Security and Spreadsheets and PDFs, since none of them names a tool or shape this diff uses.
- code-check-r.md (read by heading): I read 3 headings: "A duplicate knitr chunk label fails the build, and reading the diff will not find it", "`match()` treats NA as a matchable VALUE, so two unknowns join to each other" and "Moving prose into a code chunk hides it from tools that scan the document". I did not read about 180, since none of them names a tool or shape in the diff. The diff uses base subsetting, `month`, `table`, `sample`, `match`, `replicate`, `set.seed` and activity's `fitact`, `ovl4` and `compareCkern`.
- code-check-shell.md (read by heading): 0 read, about 110 not read. The diff contains no shell.
- code-check-spatial.md (read by heading): 0 read, about 100 not read. The diff has no spatial operations: the `solartime` call is pre-existing.

## Probes run

I ran the chapter's preprocessing (lines 50–109) in the scratchpad against the read-only CSVs, with activity 1.3.4 and R 4.5.2. The probe scripts are `cc_ch_r2/probe/p1.R` to `p4.R` in the session scratchpad.

- I checked that the staged diff is byte-identical to the diff under review. It touches only `09-activity.Rmd`, so no planning files are staged. There are no duplicate chunk labels across `*.Rmd`. There are no NA timestamps, so every row is labelled.
- **Season table:** deer other/summer/winter 1005/2514/1271 and caribou 180/542/65, both reproduced. "About a quarter" holds (26.5%), as does "under a tenth" (8.3%) and "mostly summer" (69%).
- **Fix 1, "most active by day, with peaks after sunrise and in the evening, and less active at night".** I checked it per hour on the solar axis, where the mean anchors are sunrise 6.64 h and sunset 20.32 h.
  - Per hour, mean summer deer density is 0.205 by day and 0.099 at night.
  - Every night-hour bin (maximum 0.075) is below every day-hour bin (minimum 0.088, at 16 h).
  - The peaks fall at 07–08 h (0.40) and 19–20 h (0.34), so the sentence holds per hour as well as in total.
  - Winter: 77% of images are at night, against 43% of the axis, so "moves into the night" holds.
  - In the plot, the summer curve is drawn first and sets `ylim`. The winter maximum (0.36) is below the summer maximum (0.415), so the red curve is not clipped.
- **Fix 2, "about a third … moves a little with the seed, but stays far above 5%".** Seed 9 reproduces observed 0.4467, mean_null 0.5115 and p 0.33.
  - Across seeds 1–200 at 100 reps, p ranges from 0.15 to 0.42: 5th percentile 0.21, median 0.27, no seed below 0.15. "Far above 5%" holds at the worst seed (3x).
  - mean_null ranges from 0.48 to 0.55 across seeds, so "about 0.5 on average" holds.
  - There are 12 winter and 74 summer events, so "a dozen" holds.
- **Fix 3, the lead-in "Three things follow for comparing activity patterns:".** All three bullets are statements about comparing activity patterns, so each fits.
  - The tz bullet's "matters most" is supported by the log. A shift from -6 to -7 moves the caribou season overlap from 0.45 to 0.62 and deer from 0.52 to 0.58. The pooled species and feature comparisons move by 0.02.
- **"pNull says no randomisation came close".** I rebuilt compareCkern's image-level null for caribou (100 reps). Its minimum is 0.763 and its mean 0.869, against an observed 0.447, so the claim holds.
- **Other claims.**
  - "65 images, 12 events, 6 sites" and "137 events at 18 sites" match the log.
  - "`compareCkern` builds its null by resampling single images" matches the source: a with-replacement bootstrap of the pooled observations.
  - "Every comparison so far pools all months" is true: chunks ch9_8–16 have no month filter.
  - "Much larger than any we have seen so far": 0.52 against the chapter's 0.78 and 0.83.
  - "They pass it easily, because…": round 1's deer shuffle gives a null mean of 0.77 and a minimum of 0.67, against an observed 0.52, with p 0. The deer pass despite a higher observed overlap than the caribou, because the null is tighter with more events, so the causal link holds.

## Clean

No issues found.

## Notes (not findings)

- "Moves a little with the seed" understates it slightly. Over 200 seeds, p runs from 0.15 to 0.42, and seed 9's 0.33 sits in the top quarter (median 0.27, log 200-rep 0.26). The sentence is accurate for the shipped seed, and the conclusion holds at every seed.
- "Winter" in these data is mostly November: 53 of 65 caribou winter images and 705 of 1271 deer winter images. So bullet 1's within-season comparison still mixes months differently: caribou winter is 82% November, deer winter 55%. The bullet's literal claim holds, since the winter/summer mix difference is removed.
