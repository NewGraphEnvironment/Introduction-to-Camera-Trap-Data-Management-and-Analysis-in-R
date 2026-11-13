# Findings — Does pooling seasons in ch 9 hide changes in daily activity? (#5)

## Issue context

## Question

Ch 9 fits one activity curve per species over every month of the year. `solartime()` (`09-activity.Rmd:101`) puts sunrise and sunset at the same place on the axis all year, so a winter dusk is not lost to the short day. But does pooling the seasons hide how the animals actually change their daily timing, and does it change what the deer-vs-caribou and feature-type comparisons mean?

## What a first look shows

From `data/raw_data/example_data/images.csv` (several frames per event, not the processed raw detections the chapter loads), winter = Nov-Mar, summer = May-Aug, in solar time:

| | winter n | summer n | winter vs summer overlap (`compareCkern`) | null |
|---|---|---|---|---|
| White-tailed deer | 1286 | 2534 | 0.53 | 0.97 |
| Caribou | 65 | 542 | 0.44 | 0.87 |

Share of images within 2 h of sunset:

| | summer | winter |
|---|---|---|
| White-tailed deer | 28% | 16% |
| Caribou | 22% | 5% |

So the lower evening peak in the chapter's deer/caribou plot is mostly winter, and it is not an artefact of the short winter day. Detections are also uneven across the year (caribou 70% summer, deer peaking in November), so each species' pooled curve leans toward a different season.

## To do

- Add a seasonal section to ch 9 on branch `ch9-activity-season` (off `master`), run on the chapter's own processed detections: winter and summer curves per species, `compareCkern`, the dawn/dusk shares.
- Check the fixed `tz = -6`: Alberta is UTC-7 in winter, so winter detections may sit an hour off sunrise and sunset depending on how the cameras kept time.
- Decide afterwards whether any of it is worth offering upstream.


## Exploration (2026-11-13)

- `09-activity.Rmd` is identical on `master` (`2c79f0e`, = upstream `master`) and `newgraph`.
- Ch 9 reads `data/processed_data/AlgarRestorationProject_raw_detections.csv`: 10,219 rows, one
  per image, with `event_id`, `placename`, `sp`. Range 2018-04-08 to 2019-11-21 (as stored).
- Images / events / sites by season (winter Nov–Mar, summer May–Aug, shoulder Apr, Sep, Oct):

  | | winter | summer | shoulder |
  |---|---|---|---|
  | deer images | 1,271 | 2,514 | 1,005 |
  | deer events / sites | 137 / 18 | 313 / 26 | 112 / 14 |
  | caribou images | 65 | 542 | 180 |
  | caribou events / sites | 12 / 6 | 74 / 18 | 33 / 8 |

- `activity::solartime()` (activity 1.3.4) takes the clock time as stored (`gettime`) and places
  sunrise and sunset with `get_suntimes(dat, lat, lon, tz)`, so `tz` moves the solar axis only.
- No time-zone field in `deployments.csv` or `projects.csv`; cameras are Browning BTC-5HDX
  (`cameras.csv`); no images on the DST-start days (2018-03-11, 2019-03-10), so the data cannot
  say whether the cameras kept MST all year or followed DST.

## Measured (2026-11-13, `newgraph/check_ch9_season.R`, log `newgraph/logs/20261113_check_ch9_season.txt`)

Inputs: raw detections md5 `1f2147b5…`, locations md5 `702c295a…`; 200 reps, seed 20261113.
The pooled overlaps reproduce the chapter's 0.78 (deer vs caribou) and 0.83 (HumanUse vs
Offline) at `tz = -6` (guard). Winter Nov–Mar, summer May–Aug.

Winter vs summer overlap, by `solartime()` tz variant (obs (null, p)); generated from the log by script:

| | -6 (chapter) | -7 (MST all year) | DST-following |
|---|---|---|---|
| deer, images (compareCkern) | 0.52 (0.96) | 0.58 (0.97) | 0.55 (0.97) |
| deer, one image per event (compareCkern) | 0.53 (0.92) | 0.56 (0.92) | 0.55 (0.92) |
| deer, season shuffled across events | 0.52 (0.78, p 0.000) | 0.58 (0.78, p 0.000) | 0.55 (0.77, p 0.000) |
| deer, core months Dec–Feb vs Jun–Jul | 0.47 (0.95) | 0.51 (0.95) | 0.43 (0.95) |
| caribou, images (compareCkern) | 0.45 (0.87, p 0.000) | 0.62 (0.88, p 0.000) | 0.73 (0.88, p 0.000) |
| caribou, one image per event (compareCkern) | 0.67 (0.75, p 0.155) | 0.75 (0.75, p 0.485) | 0.79 (0.74, p 0.700) |
| caribou, season shuffled across events | 0.45 (0.51, p 0.260) | 0.62 (0.51, p 0.850) | 0.73 (0.52, p 0.965) |
| caribou, core months (10 winter images) | 0.22 (0.66, p 0.000) | 0.56 (0.71, p 0.050) | 0.45 (0.73, p 0.000) |

Share of images within 2 h of that day's sunrise / sunset (clock time):

| | -6 | -7 | DST |
|---|---|---|---|
| deer winter | 30% / 15% | 26% / 10% | 25% / 10% |
| deer summer | 24% / 28% | 17% / 31% | 24% / 28% |
| caribou winter (65 images) | 65% / 20% | 55% / 15% | 55% / 15% |
| caribou summer | 44% / 22% | 32% / 26% | 44% / 22% |

Pooled vs within-season comparisons, tz -6 (obs; image-level null; event-shuffle null and p):

| | pooled | winter | summer |
|---|---|---|---|
| deer vs caribou | 0.78; 0.95; 0.79, p 0.44 | 0.52; 0.86; 0.56, p 0.38 | 0.73; 0.94; 0.72, p 0.54 |
| deer HumanUse vs Offline | 0.83; 0.96; 0.76, p 0.92 | 0.72; 0.93; 0.60, p 0.86 | 0.63; 0.93; 0.70, p 0.13 |

Across all three variants the event-shuffle p ranges are 0.25–0.44 (species, pooled), 0.91–0.95
(feature type, pooled) and 0.065–0.13 (feature type, summer); no variant reaches 0.05.

Season mix of images: deer 27% winter / 52% summer / 21% other, caribou 8% / 69% / 23%.
Deer HumanUse 27% winter, Offline 32%.

What it says:

- **Deer change their daily timing between seasons**, under every variant and against a null
  that keeps events whole: the summer curve has a much larger dusk share. Pooling hides that.
- **Caribou's apparent seasonal shift is not supported.** The image-level pNull is 0.000, but
  shuffling season across whole events gives p 0.26 at best: 12 winter events at 6 sites carry
  it, 6 in winter 2018–19 and 6 in one week of November 2019. compareCkern's image-resampling
  null treats an event's frames as independent.
- **The chapter's two existing differences do not survive the event-level null either**: deer vs
  caribou (pooled overlap 0.76–0.78, p 0.25–0.44) and HumanUse vs Offline (0.81–0.83, p
  0.91–0.95), each range across the three tz variants, pooled or within a season. Only deer winter vs summer does. That is the chapter's prose at lines 181 and 224
  ("This suggests the patterns differ"), a separate concern from this branch: fork #6.
  Feature type is a site property, and deer were detected at 9 HumanUse and 9 Offline sites, so a
  site-level shuffle would be stricter still; not run.
- **The pooled species comparison mixes different seasons**: caribou is 69% summer, deer 52%.
- **`tz`**: solar time differs between variants by up to 1.0 h (-6 vs -7) and 1.9 h (-6 vs DST),
  because the stored clock does not move while sunrise and sunset do. Magnitudes move (caribou
  0.45 → 0.73) but no conclusion flips: deer winter vs summer significant everywhere, nothing
  else at event level anywhere, share directions unchanged. Decision 3's trigger is not met; the question of how the
  cameras kept time goes to the author.
- Plan-review claim that only a solar-axis dusk share responds to tz: disproved (deer winter
  sunset 15% at -6, 10% at -7, clock time).
- The chapter draft first said winter deer lose the summer evening peak. The rendered plot shows
  otherwise: summer deer are active by day with peaks after sunrise and in the evening; in winter
  much of their activity moves into the night. Prose corrected from the figure.
- Existing line 181 says "both feature types" for the deer vs caribou comparison. Left alone (one
  concern per branch); reported.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| Table 1 not re-derived after the re-run changed the random stream (code-check round 2) | Table generated from the log by script; every number in the section enumerated against the log |
| The regenerating splice duplicated half the file: its end marker matched the issue text quoted above the table | Restored from the index; end marker searched only after the table's start |
