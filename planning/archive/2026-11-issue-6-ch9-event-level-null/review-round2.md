## Checklist read

- code-check-shell.md: 0 headings read; 71 not read. The diff contains no shell, git or sed.
- code-check-spatial.md: 0 headings read; 94 not read. The diff contains no spatial code.
- code-check.md: read the prose of all 14 H3 under `## Mechanisms`, skipping the table rows ("A guard that fails toward pass", "A fixture that cannot reach the failure mode", "A proxy is not the property", "Verification that reads its own output", "A guard's scope, escape hatches, and remedies", "A fix lands in one of two callers that share a harness", "Restore the bug and prove the guard fires", "A shared working tree, and what generators leave in it", "A wrapper's exit is not the work", "Zero-length, empty, and unset are three different things", "The probe is broken before the world is", "Written data outlives the fix", "Serialization loses meaning silently", "One fact derived twice"); 24 not read.
- code-check-r.md: read "Reproducibility" and "A duplicate knitr chunk label fails the build, and reading the diff will not find it"; 119 not read.

## Clean

No issues found.

### What was checked

**The round-1 fix (site-level shuffle, ch9_null_4).**
- `event_shuffle(..., id = "placename")` renders 0.83 / 0.81 / p 0.78 with 9 vs 9 sites. The independent log gives p 0.82–0.825 at 200 reps. "Shuffling sites gives a different null, but the same answer: `p` is high" holds.
- feature_type is constant within each placename: all 38 sites in `locs` carry exactly one value, and the function's own guard would stop otherwise.
- "detected at only 9 HumanUse and 9 Offline sites" matches the `sites` row of ch9_null_1.
- The fix did not carry an unmeasured directional claim over to the species comparison. The closing advice ("or each site's when the label belongs to the site") is prescriptive and makes no claim about which way the result moves.

**Attributing the high compareCkern null to burst pseudoreplication** (":181", the paragraph after ch9_null_1, and the 0.76 paragraph).
- `activity::compareCkern` source: it pools `fit1@data` and `fit2@data` and resamples single observations with replacement into groups of the original sizes. "resampling single images" is accurate.
- Measured: running the chapter's `event_shuffle` with a per-image id (`id = row_id`, 40 reps, seed 1) gives a mean null of 0.942 and p = 0. With per-event ids the mean null is 0.76. The only thing that changes is the grouping, so the gap between 0.96 and 0.76 comes from keeping events together, as the prose says. A difference in bandwidth handling (compareCkern fixes `bw = fit1@bw`) does not explain it.

**Numbers in the prose against the render** (`.../scratchpad/branch/09-activity.md`) and the seed log:
- 0.78, about 0.95 (0.954), 0.83, about 0.96 (0.960), pNull < 0.01 (0/100) all match.
- 571/87 and 2,053/254 match the table, and about 0.76 matches.
- "higher than most shuffles" fits p 0.91–0.96.
- In ch9_null_5: 0.78 vs mean_null 0.79, and p 0.33–0.47 is "well above 0.05".
- n_a = 562 equals the deer event total (87 + 221 + 254). n_b = 119 equals the caribou event count.
- The function comment "the coefficient compareCkern reports as obs" is true: both call `ovl4()` on default-bandwidth fits, so the observed values agree (0.8267 / 0.7847).

**Data assumptions in `event_shuffle`.**
- `event_id` is globally unique: 0 ids appear at more than one site and 0 under more than one species.
- `event_id` has 0 NAs, so neither `match()` nor the `!=` guard meets an NA.
- The shuffle permutes event labels, so group sizes in events are kept, as the n_a/n_b comment states.

**Build.** Chunk labels ch9_null_1 to ch9_null_5 are unique in the file. Each stochastic chunk is preceded by `set.seed(9)`. The default `id = "event_id"` keeps the sibling-branch call `event_shuffle(cs, "season", "winter", "summer")` working.
