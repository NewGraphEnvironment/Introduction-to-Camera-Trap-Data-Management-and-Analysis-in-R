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

## Errors Encountered

| Error | Resolution |
|-------|------------|
