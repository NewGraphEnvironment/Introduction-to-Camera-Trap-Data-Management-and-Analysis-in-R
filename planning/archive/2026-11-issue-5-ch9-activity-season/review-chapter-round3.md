# Review: ch 9 "Season comparisons" diff, round 3

## Checklist read

- code-check.md (read by heading): I read the prose of all 14 H3s under `## Mechanisms`, skipping the `|` table rows. The ones that apply here are "A proxy is not the property" (a sentence describing a figure is a claim about the criterion the figure stands in for), "A guard's scope, escape hatches, and remedies" (a sentence that gains a quantifier or causal link is unsupported until checked; terminate by enumerating claims), "The probe is broken before the world is" (before attributing a difference, enumerate everything else that differs between the two sides) and "Written data outlives the fix" (ask what is in the denominator). I read none of the ~20 headings under "Rules that stand alone", Security, or Spreadsheets and PDFs, because none names a tool or shape this diff uses.
- code-check-r.md (read by heading): I read 2 sections: "A duplicate knitr chunk label fails the build, and reading the diff will not find it" and "`match()` treats NA as a matchable VALUE, so two unknowns join to each other". I did not read the other 119, because no other heading names a tool or shape in the diff.
- code-check-shell.md (read by heading): I read 0 sections. The diff has no shell.
- code-check-spatial.md (read by heading): I read 0 sections. The diff has no spatial operations, and `solartime` is pre-existing code.

## Mechanism behind round 1's finding

The shared assumption is that **the solar-time density curve can be read directly as behaviour**. A word describing the curve's shape ("rarely", "moves into", "the same routine") was written as a statement about the animal, with no anchor for what it is being compared against. In round 1 the missing anchor was night's share of the day: 23% of summer images are at night, and night is 32% of a summer day. The same assumption also affects any sentence whose baseline is the solar axis itself. Average anchoring maps every image's own sunrise and sunset onto fixed mean times (6.59 h and 20.37 h). So the winter night, which is 67% of the day, gets 43% of the axis (24 h minus 13.78 h of mean day), while the summer night, which is 32% of the day, also gets 43%. An animal that changes nothing on the clock therefore produces different winter and summer solar curves.

## Probes (scratch only, read-only data, activity 1.3.4)

Scripts: `/private/tmp/claude-501/-Users-airvine-Projects-repo-Introduction-to-Camera-Trap-Data-Management-and-Analysis-in-R/7ceaa123-144e-482b-893b-86b66548dceb/scratchpad/cc_ch_r3/probe/q1.R` and `q2.R`. They reuse round 2's `img_locs.rds`, which is built exactly as the chapter builds it (tz = -6).

- Night is defined as outside each image's own sunrise and sunset, from `get_suntimes`.
  - Deer winter: 77.1% of images and 75.2% of events at night. Night is 67.0% of the day.
  - Deer summer: 23.5% of images and 20.4% of events at night. Night is 32.3% of the day.
  - Caribou winter: 73.8% of images and 66.7% of events at night. Night is 67.4% of the day.
- Per-hour night:day detection rate for deer, by events: 0.54 in summer and 1.50 in winter. The preference flips.
- Seasonal share of **events**: deer winter 24.4% and summer 55.7%; caribou winter 10.1% and summer 62.2%.
- `compareCkern` on the caribou winter vs summer fits: obs 0.447, null 0.869, seNull 0.028, pNull 0. The observed value is about 15 null SEs below the null mean.
- **Light-indifferent deer** (q2.R): I kept the same dates and sites, drew each image's clock time uniformly over the 24 h, and then ran the chapter's `solartime` (tz = -6), `fitact` and `ovl4`. Over 5 draws the winter vs summer overlap was 0.698, 0.717, 0.709, 0.690 and 0.682, so about 0.70.
- The share of winter images taken in November: deer 55% of images (66% of events); caribou 82% of images (67% of events).
- Chunk labels: none duplicated across `*.Rmd`. `event_id` is a global cumulative counter (ch 3, line 1195), so `unique(event_id)` cannot merge events across sites.

## Findings

- **[severity: fragile]** 09-activity.Rmd:266. The sentence "The winter and summer curves overlap by only 0.52, against 0.96 expected if deer kept the same routine all year", together with "This difference is much larger than any we have seen so far" and the set-up at line 228 ("Solar time stops the short winter day from squeezing dawn and dusk together, but it cannot tell us whether the animals themselves change their daily routine"), leaves the anchor of "the same routine" unstated.
  - `compareCkern`'s 0.96 is the expected overlap for the same pattern **on the solar axis**, which means the same timing relative to sunrise and sunset.
  - It is not what you would expect for an animal that does the same thing all year. A deer that ignores light completely, with uniform clock activity on the same dates and sites, gives a winter vs summer overlap of about 0.70 on this axis (q2.R). The reason is that average anchoring squeezes the 67%-of-the-day winter night into 43% of the axis and stretches the 32% summer night to fill the same 43%.
  - So about 0.26 of the 0.44 gap between 0.52 and 0.96 would appear for an animal that changed nothing on the clock. Nothing like this applies to the earlier species and feature-type comparisons, because both of their strata pool the same months. "Much larger than any we have seen" therefore compares a gap partly made by the transform with gaps the transform did not touch.
  - The conclusion itself holds. 0.52 is well below 0.70, and the deer's per-hour night:day rate flips from 0.54 in summer to 1.50 in winter (events), which is a real change on any reading. But a student reading the paragraph as written will credit the whole gap to behaviour, and the line 228 sentence tells them solar time has already removed the day-length effect.
  - **Suggested direction (author's call):** say what "the same routine" means, for example "if deer kept the same timing relative to sunrise and sunset all year". Optionally add that day length alone moves the winter and summer curves apart, so the season test asks whether activity tracks the sun, not the clock.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "The probe is broken before the world is"

## Every sentence the mechanism reaches, with verdicts (not findings)

| Line | Claim | Measured | Verdict |
|---|---|---|---|
| 241 | "about a quarter of the deer images ... under a tenth of the caribou images" | images 26.5% / 8.3% (events 24.4% / 10.1%) | Holds as worded (images). By events, caribou is just over a tenth. The sentence says images, so this is not a finding. |
| 266 | "much larger than any we have seen so far" | obs 0.52 vs 0.78 and 0.83 | Holds on the printed numbers, but see the finding: part of the gap comes from the transform. |
| 266 | summer "most active by day, with peaks after sunrise and in the evening, and less active at night" | 76.5% of images by day; peaks 7.73 h and 20.34 h (round 1); night per-hour rate about 0.6 of day | Holds |
| 266 | winter "much of their activity moves into the night" | 75% of winter events at night vs 20% in summer; per-hour preference flips to night (1.50) | Holds. Most of the rise in night share is the longer night (32% to 67% of the day), but the per-hour flip makes the sentence true on any reading. |
| 279 | caribou "looks even lower"; "no randomisation came close" | 0.447 < 0.521; seNull 0.028, about 15 SE below | Holds |
| 285 | "Sixty-five images, but only 12 detection events at 6 sites" | rendered 65/12/6 | Holds |
| 285 | `compareCkern` "resampling single images" | round 1 read the source: a bootstrap of pooled single observations | Holds |
| 303 | "overlap by about 0.5 on average" | mean_null 0.512 | Holds |
| 303 | "about a third ... changes with the seed, but stays far above 5%" | 0.33 at seed 9; 0.15 to 0.42 across seeds (round 2); 0.26 at 200 reps (log) | Holds. The minimum is 3x the threshold. |
| 303 | deer "pass it easily, because their winter curve rests on 137 events at 18 sites" | log: event-shuffle p 0.000, 5th pct 0.71 vs obs 0.52; 137/18 reproduced | Supported by the log and the probe. **Convention note:** the page prints neither the deer shuffle nor 137/18, which breaks the stated "prose avoids statistics the page does not print". It is the author's call whether to print them (one line, as in `ch9_season_5`) or reword. |
| 307 | deer "about a quarter winter", caribou "mostly summer" | 27% / 69% (events 24% / 62%) | Both true. The contrast mixes anchors: the deer sample is also mostly summer (52%), and the real difference is the winter share (27% vs 8%). It is mildly asymmetric but not false, so it is not counted. |
| 307 | "Comparing species within one season removes that difference in seasonal mix" | within winter, November share 55% vs 82% by images, 66% vs 67% by events | Holds for the winter/summer mix it names, and by events for the month mix. This is the accepted tradeoff, so it is not counted. |
| 309 | tz/DST bullet | log: 8270 of 10219 images in the DST period | General claim; holds |
