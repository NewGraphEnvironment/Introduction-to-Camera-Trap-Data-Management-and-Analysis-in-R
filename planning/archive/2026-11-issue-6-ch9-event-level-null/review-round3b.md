# Review round 3b: 09-activity.Rmd (branch ch9-event-level-null)

Diff: scratchpad/diff_round2.txt (staged, against master). Evidence: rendered
scratchpad/branch/09-activity.md, the activity 1.3.4 source (`compareCkern` printed in R),
the data in data/processed_data (read-only R), and the seed figures supplied by the caller.

## Checklist read

- **code-check.md**: read the prose of all 14 H3 under `## Mechanisms` (tables skipped), plus
  "Documentation Staleness" and "An assertion that matches an interpolated value cannot see
  the claim around it". 16 read, 22 not read (security, spreadsheets/PDF, YAML, credentials,
  URL, release: nothing in this diff uses them).
- **code-check-r.md**: read "A duplicate knitr chunk label fails the build...",
  "Reproducibility", "`match()` treats NA as a matchable VALUE...", "Base name shadowing in
  formal args", "`data.frame()` recycles a scalar against a zero-length column". 5 read,
  116 not read (packages, testthat, SQL, duckdb/arrow, glue/cli, file I/O: none used here).
- **code-check-shell.md**: 0 read, 71 not read (the diff has no shell, sed or git code).
- **code-check-spatial.md**: 0 read, 94 not read (no spatial code. `solartime` is upstream
  and outside the diff).

Code checks I ran because of those headings:
- Duplicate chunk labels across the whole Rmd: none (`grep ... | uniq -d` returned nothing).
- `match()` on NA keys in `event_shuffle`: `event_id`, `placename`, `feature_type` and `sp`
  have 0 NA or blank values in the merged frame (10,219 rows), so the NA-matches-NA trap
  cannot fire on this data.
- Is `event_id` unique across the whole dataset? Yes. It is a global serial (`E000001`...).
  Each of the 562 deer events has exactly one `placename`, and each of the 1,543 events has
  exactly one `sp`, so the one-label-per-event guard holds and the event counts in the table
  are true counts.

## Mechanism behind round 1's defect

Round 1's sentence ("a test that shuffled whole sites could only weaken the result further")
came from a **directional extrapolation to an analysis nobody ran**. It rested on one shared
assumption: a null's location depends only on how coarse its resampling unit is
(images, then events, then sites), so a coarser unit always gives a lower mean null and a
higher p. The run showed otherwise. 18 sites gave a mean null of about 0.80 to 0.81, which is
higher than the 0.76 the events gave, and p fell from about 0.93 to about 0.80. My hypothesis,
which I did not measure, is that a site shuffle also changes the group sizes: each shuffled
group gets about half the images, while the event shuffle keeps HumanUse at only 87 events.
The underlying error is reading an expectation from intuition, or from a different null,
instead of measuring it.

Where that mechanism could reach in the new prose:
- a. Line 181. The sentence treats compareCkern's image-level null (about 0.95) as **the**
  expectation under "same activity pattern". **FINDING 1.**
- b. Line 181, "too quick to call a difference". This is directional, but it was measured:
  `ch9_null_5` gives p 0.47 (seeds 0.33 to 0.43) against compareCkern's 0. Holds.
- c. Line 234, "which is why its null sits so close to 1". This is causal. Round 2 measured
  it: an image-level shuffle gives a mean null of 0.942 with p 0. Holds.
- d. Line 270, "tens or hundreds of events are much noisier". This is the unit-count
  reasoning itself. It holds for events against images (0.76 against 0.94, measured). It does
  **not** extend to sites, where 18 units gave a higher null (0.81). The prose does not extend
  it (line 279 says only "a different null"), so it holds as written.
- e. Line 279, "different null, but the same answer". Measured (0.81 against 0.76; p 0.78,
  seeds about 0.82). Holds.
- f. Line 288, "or each site's when the label belongs to the site". This is advice, and it
  implies that an event-level null is enough for a label that is not tied to a site (species).
  That was never measured, because a species label cannot be shuffled among sites. No
  conclusion depends on it, since the species p is already non-significant at the event
  level. Not a finding.

## Enumeration of new or changed claims

Line numbers refer to the worktree 09-activity.Rmd. Source "R" means the rendered output,
"pkg" means the activity source, "data" means a read-only R measurement I ran, and "seed"
means the caller's seed runs.

1. L179 "`pNull` = probability observed index arose by chance." Source: none. This is the
   textbook misreading of a p-value, and it contradicts the chapter's own correct definition
   at L236. **Does not hold. FINDING 2** (the wording comes from upstream, but the diff edits
   this exact bullet).
2. L179 "Low pNull means the patterns differ (but see the end of the treatment comparisons
   below)." Hedged and points forward. Holds as hedged.
3. L181 "The observed overlap (0.78)": R obs 0.7847. Holds.
4. L181 "...is lower than we would expect if deer and caribou had the same activity pattern
   (about 0.95)". Source: R null 0.954, which is compareCkern's image-level null. The chapter
   itself (L288, `ch9_null_5`) measures the expectation under the same pattern as about 0.79.
   **Does not hold. FINDING 1.**
5. L181 "none of the randomisations produced an overlap this low (pNull < 0.01)". R pNull 0
   with 100 reps. obs is about 18 null SDs below the mean, so this is stable across seeds.
   Holds.
6. L181 "`compareCkern` builds its null by resampling single images". pkg: `sample(1:length(y),
   reps*length(y), replace=T)` over the pooled observations. Holds.
7. L181 "many of our images are frames from the same burst". data: 4,790 deer images in 562
   events and 787 caribou images in 119 events. The median deer event lasts 8 s (95th
   percentile 8.3 min). Holds.
8. L181 "That makes the test too quick to call a difference." R `ch9_null_5` p 0.47 against
   pNull 0. Round-2 image shuffle 0.942. Holds.
9. L214 "observed overlap (0.83) is lower than `compareCkern` expects ... (about 0.96)". R obs
   0.8267, null 0.9605. Holds, and it correctly attributes the expectation to compareCkern.
10. L214 "none of its randomisations produced an overlap this low". R pNull 0. Holds.
11. L234 "571 deer images on HumanUse lines come from only 87 detection events". R table.
    Holds.
12. L234 "2,053 on Offline lines from 254". R table. Holds.
13. L234 "a deer walking past a camera triggers a burst of frames". data: median event
    duration 8 s, about 6.6 to 8 images per event. Holds.
14. L234 "treats every frame of a burst as a separate, independent observation". pkg (i.i.d.
    resampling of individual observations). Holds.
15. L234 "With thousands of such observations, two curves drawn from the same pattern almost
    always overlap closely, which is why its null sits so close to 1". The image counts are
    2,624 and 5,577. R nulls 0.954 and 0.960, seNull about 0.01. Round 2: an image-level
    shuffle gives 0.942. Holds.
16. L234 "almost any difference looks significant". R: null 0.95 to 0.96 with seNull about
    0.01, so any obs below about 0.93 gets pNull of about 0. This is a general quantifier
    derived from the printed spread. Holds loosely; not flagged.
17. L236 "`p` is the share of shuffles that give an overlap as low as the observed one or
    lower". code `mean(null <= obs)`. Holds.
18. L240 code comment "observed overlap: the coefficient compareCkern reports as obs". pkg obs
    = `ovl4(fit1, fit2)`. R 0.83 matches 0.8267. Holds.
19. L263 comment "n_a and n_b count the events (or sites) in each group". code
    `sum(g[[col]]==a)` over the deduplicated id table. R 87/254 and 9/9. Holds.
20. L270 "two random groups overlap by only about 0.76 on average". R mean_null 0.76; seed
    0.76. Holds.
21. L270 "curves fitted to tens or hundreds of events are much noisier than curves fitted to
    thousands of frames treated as independent". 87 and 254 events. Event null 0.76 against
    image-level 0.942 (round 2). Holds (see mechanism item d).
22. L270 "The observed 0.83 is higher than most shuffles, so p is high." R p 0.91; seeds
    0.92 to 0.96. Holds.
23. L270 "A high p means there is no evidence of a difference, not that the two feature types
    are more alike than chance." This reads the one-sided test correctly. Holds.
24. L270 "So the data do not show that deer change their activity pattern between HumanUse
    and Offline lines." Follows from 22. Holds.
25. L272 "Feature type belongs to the camera site". The function's one-label-per-id guard
    passed with `id = "placename"` (R rendered without stop). Holds.
26. L272 "detected at only 9 HumanUse and 9 Offline sites". R table, sites 9 and 9. Holds.
27. L279 "Shuffling sites gives a different null". R 0.81 against 0.76; seeds 0.80 against
    0.76. Holds.
28. L279 "but the same answer: p is high, and there is no evidence of a difference". R p
    0.78; seeds 0.82 to 0.825. Holds.
29. L288 "The observed overlap (0.78) is about the same as that of two random groups of
    events". R obs 0.78 against mean_null 0.79; seeds 0.78 against 0.80. Holds.
30. L288 "`p` is well above 0.05". R 0.47; seeds 0.33, 0.38, 0.43. Holds.
31. L288 "the difference compareCkern reported between deer and caribou does not survive
    either". Follows from 30. Holds.
32. L288 "always test them against a null that keeps each event's images together, or each
    site's when the label belongs to the site". This is prescriptive. Mechanism item f
    applies; no measured claim. Not flagged.

## Findings

- **[severity: bug]** 09-activity.Rmd:181. The sentence "The observed overlap (0.78) is lower
  than we would expect if deer and caribou had the same activity pattern (about 0.95)" states
  as fact that 0.95 is the expected overlap under "same pattern". The chapter's own later
  test (`ch9_null_5`, L288) shows the expectation under a same-pattern null that respects
  bursts is about 0.79, which is the same as the observed value. The rest of L181 hedges, but
  this clause is the same mechanism as round 1: it takes a particular null's expectation as
  the truth. It is also inconsistent with L214, which this diff reworded to "lower than
  `compareCkern` expects" for exactly this reason. Fix: attribute the 0.95 to compareCkern, as
  at L214.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (the "never
    measured" justification and the "compression runs both ways" paragraphs: a
    present-tense causal claim with no measurement behind it, contradicted by the chapter's
    own measurement).
- **[severity: fragile]** 09-activity.Rmd:179. The edited bullet keeps "`pNull` = probability
  observed index arose by chance". That is the standard misreading of a p-value, and it now
  sits beside the chapter's correct definition of `p` at L236 ("the share of shuffles that
  give an overlap as low as the observed one or lower"). The chapter therefore defines the
  same quantity two incompatible ways. The words are upstream's, but the diff edits this
  bullet, so it is in scope. Fix: e.g. "share of randomisations giving an overlap as low as
  the observed one".
  - **Rule:** none

Verdict: 2 findings (1 bug, 1 fragile). The code is clean: no duplicate chunk labels, no NA
keys, ids are global and single-label, and the function reproduces compareCkern's `obs`.
