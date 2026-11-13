# Code check review, round 1: 09-activity.Rmd (ch9-event-level-null)

## Checklist read

- **code-check.md**: read the prose (no table rows) of all 14 H3s under `## Mechanisms`: "A guard that fails toward pass", "A fixture that cannot reach the failure mode", "A proxy is not the property", "Verification that reads its own output", "A guard's scope, escape hatches, and remedies", "A fix lands in one of two callers that share a harness", "Restore the bug and prove the guard fires", "A shared working tree, and what generators leave in it", "A wrapper's exit is not the work", "Zero-length, empty, and unset are three different things", "The probe is broken before the world is", "Written data outlives the fix", "Serialization loses meaning silently", "One fact derived twice". I also read "An assertion that matches an interpolated value cannot see the claim around it" and "Documentation Staleness". That is 16 read and 22 not read.
- **code-check-r.md**: read "A duplicate knitr chunk label fails the build, and reading the diff will not find it", "Reproducibility", "`match()` treats NA as a matchable VALUE, so two unknowns join to each other", "`$` on a list partial-matches, so a longer sibling key answers for a missing one", and "`data.frame()` recycles a scalar against a zero-length column". That is 5 read and 116 not read.
- **code-check-shell.md**: 0 read and 71 not read. The diff has no shell.
- **code-check-spatial.md**: 0 read and 94 not read. The diff has no spatial code.

## Findings

- **[severity: bug]** 09-activity.Rmd:267. The sentence "And this test is still generous: feature type belongs to the camera site ... so a test that shuffled whole sites could only weaken the result further" makes a directional claim that nobody measured, and a measurement contradicts it. The sentence says a site-level shuffle can only make a difference look less significant than the event-level test does. I ran exactly that test: same data, same `fitact`/`ovl4` statistic, feature-type labels shuffled among the 18 deer sites (9 HumanUse, 9 Offline; the site count is correct), 200 reps, seeds 1 to 3. It gave obs 0.827, mean_null about 0.80 (sd about 0.037) and p = 0.82, 0.825 and 0.825. The event-level test gives p 0.91 to 0.96. So the site-level null has a higher mean than the event-level one (0.80 against 0.76), and p goes *down*. That is the opposite of "could only weaken". The chapter's conclusion still holds, since there is no evidence of a difference either way. But the sentence teaches readers a false general rule: a coarser shuffle is not guaranteed to move p up. The words "could only" turn an untested intuition into a guarantee. Fix: drop the clause. Or say what is true: feature type is assigned per site, these deer were detected at only 9 HumanUse and 9 Offline sites, and a test that shuffled whole sites (p about 0.8 here) also finds no difference.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

## Checked and holding (no action)

- I compared every number and quantifier in the new prose with the rendered `branch/09-activity.md`:
  - 571/87 and 2,053/254 images/events: correct.
  - compareCkern nulls 0.956 and 0.960 against "about 0.95": correct.
  - pNull 0, "none of its randomisations": correct.
  - mean_null 0.76, "about 0.76": correct.
  - p 0.91, "most shuffles ... p is high": correct.
  - Species obs 0.78 against mean_null 0.79, p 0.47, "about the same" and "well above 0.05": correct.
  - These also hold at seeds 1 to 3 (0.80; p 0.33 to 0.43).
  - "Thousands" of images holds: deer have 4,790 images and caribou 787.
- The description of `compareCkern` matches the activity 1.3.4 source. It draws single data points with replacement from the pooled images, refits, and takes `pNull = ecdf(null)(obs)`, which is the same lower-tail direction as `event_shuffle`'s `p = mean(null <= obs)`. So the new `p` and the upstream `pNull` line do not contradict each other.
- `event_shuffle` code:
  - No NA in `sp`, `event_id` or `feature_type`, so the `match()` NA trap and the logical-NA row trap in `deer <- img_locs[img_locs$sp==..., ]` cannot fire.
  - No event spans two species or two sites, so the one-label guard is correct and does not fire.
  - `$solar` and `$event_id` are exact column names, so there is no partial match.
  - `obs` matches compareCkern's obs (0.7847 and 0.8267), because it uses the same default-bandwidth `ovl4`.
- Chunk labels `ch9_null_1` to `ch9_null_4` are unique across all book .Rmd files. The new globals `deer` and `event_shuffle` collide with nothing in later chapters.
