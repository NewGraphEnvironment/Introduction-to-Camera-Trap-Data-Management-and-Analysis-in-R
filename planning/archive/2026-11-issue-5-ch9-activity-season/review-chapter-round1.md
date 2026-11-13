# Review: ch 9 "Season comparisons" diff, round 1

## Checklist read

- code-check.md (read by heading): I read the prose of all 14 H3s under `## Mechanisms`, skipping the `|` table rows. Most relevant here: "A proxy is not the property" (a sentence describing a figure is a claim; compute the share it claims), "A guard's scope, escape hatches, and remedies" (a sentence that gains a quantifier or a causal link counts as unsupported until checked), "The probe is broken before the world is" (write the numbers last, against the final tree) and "A fixture that cannot reach the failure mode" (ask what an id is unique within). I read none of the "Rules that stand alone", Security, or Spreadsheets/PDF sections (about 20 headings). None of them names a tool or shape this diff uses.
- code-check-r.md (read by heading): I read 3 sections: "A duplicate knitr chunk label fails the build, and reading the diff will not find it", "`match()` treats NA as a matchable VALUE, so two unknowns join to each other" and "Moving prose into a code chunk hides it from tools that scan the document". I did not read the other ~180, because no other heading names a tool or shape in this diff. The diff uses base subsetting, `month()`, `table`, `sample`, `match`, `replicate`, `set.seed` and activity's `fitact`/`ovl4`/`compareCkern`.
- code-check-shell.md (read by heading): I read 0 of ~110 sections. The diff contains no shell.
- code-check-spatial.md (read by heading): I read 0 of ~100 sections. The diff has no spatial operations: lat/lon go only into `solartime`, and that code is pre-existing.

## Probes run (scratch copy, read-only data)

All probes were R scripts in the scratchpad (`rev_ch9/probe.R`, `rev_ch9/probe2.R`) that read the processed CSVs in place, using activity 1.3.4.

- Chunk 1 table reproduced: deer 1005/2514/1271, caribou 180/542/65. Deer winter share is 26.5% ("about a quarter" OK). Caribou winter share is 8.3% ("under a tenth" OK). Caribou summer share is 69% ("mostly summer" OK).
- `event_id`: 0 NA, 1543 events, 0 events spanning more than one site, more than one species or more than one season. So `ev` cannot carry an event with two seasons in these data. It is also structurally impossible for a student's data, because `cs` keeps only winter and summer, and those are not adjacent months.
- Chunk 5 reproduced: 65 images, 12 events, 6 sites. Deer winter: 1271 images, 137 events, 18 sites. These match the prose and the log.
- Chunk 6 reproduced exactly under `set.seed(9)`: observed 0.4467, mean_null 0.5115, p 0.33. The shuffle is correct. `sample(ev$season)` permutes the labels across the 86 events (12 winter, 74 summer), and `match(cs$event_id, ev$event_id)` gives every image its event's label, so each event's images stay together. `p = mean(null <= obs)` is the low-overlap tail, which is the right tail for "an overlap this low". `fitact` with its default `sample = "none"` uses no RNG, so the seed covers the only random step. `s` is local to `replicate()`.
- Deer event shuffle (same code, `set.seed(9)`): observed 0.521, mean_null 0.773, min_null 0.669, p 0. So "they pass it easily" holds.
- `activity::compareCkern` source: the null is a with-replacement bootstrap of pooled single observations, which supports "resampling single images". `solartime` uses average double anchoring, and `tz` only shifts the computed sunrise and sunset onto the camera clock. So the tz bullet is accurate: with one offset and a camera that changes for DST, part of the year is an hour off. The log shows 8270 of 10219 images fall in the DST period.
- Mean anchors on the solar scale: sunrise 6.59 h, sunset 20.37 h. The deer summer KDE peaks are at 7.73 h (after sunrise) and 20.34 h (at sunset). The winter peaks are at 2.11, 5.72 and 21.14 h. These match the plot description.
- Student state: no reuse of `m1`/`m2`. `img_locs$season` is new, and assigning it again is idempotent. The new globals (`obs`, `null`, `ev`, `cs`, `cw`, `m_win`, `m_sum`, `c_win`, `c_sum`) collide with nothing later in the book: ch 12 uses `obs` only as a `summarise()` output name. No chunk label is duplicated across `*.Rmd`. Nothing masks `month`.

## Findings

- **[severity: bug]** 09-activity.Rmd:266 (the paragraph after `ch9_season_3`). "In summer, deer ... are rarely detected at night" is not supported by the data behind the plot. Night here means outside each image's own sunrise and sunset at tz -6, which is the same as outside 6.59–20.37 h on the solar axis. By that measure, 23.3% of summer deer images (585 of 2514) and 20.4% of the 313 summer deer events are at night, and night takes up 32% of a summer day. So deer are less active at night, at about two-thirds of the daytime rate per hour, but they are not rare at night: about one detection in four is nocturnal. The curve also has small night peaks at about 02:10 and 04:20. A student comparing the plot with the sentence will see night activity that the text says is rare. Suggested wording: "and are less active at night (about a fifth of summer events)". The rest of the paragraph holds: 77% of summer images are by day, and 77% of winter images are at night against a 67% night share of the winter day, so "much of their activity moves into the night" is supported.
  - **Rule:** code-check.md "A proxy is not the property"

## Notes (not findings)

- "About a third of the time" is the seed-9 draw, which the code reproduces exactly. Across seeds 1–20 at 100 reps, p ranges from 0.19 to 0.37, with a median of 0.27. The log's 200-rep run gives 0.26. The conclusion ("the data do not show...") holds for every seed. The sentence is accurate for the shipped code, but it is not robust to a student changing the seed or `reps`.
- Since the render, the list lead-in changed to "Three things follow for the comparisons earlier in this chapter". The third bullet (tz) is about seasonal comparisons rather than the earlier ones. This is a wording point and is not counted.
