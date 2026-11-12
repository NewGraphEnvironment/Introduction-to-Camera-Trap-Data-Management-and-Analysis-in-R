# Findings — Ch 12 independence step and the weekly frame's time zone (#1)

## Issue context

Draft for upstream (`WildCoLab/Introduction-to-Camera-Trap-Data-Management-and-Analysis-in-R`). Not sent. Both fixes are to be made and measured on this fork first, one branch per concern from `master` at `2c79f0e`.

---

**Title:** Ch 12 independence step and the weekly frame's time zone

Thank you for the course and the book. It was a pleasure to work through, and we have been rerunning its pipeline on other datasets. We noticed two things that may help other readers:

1. **Ch 12's independence step.** In `12-on_your_own.Rmd` (chunk "Create your independent data"), images are sorted by `deployment_id` only and the gap is `int_length(timestamp %--% lag(timestamp))`. That gap is negative for rows in time order, so few gaps pass the threshold. On the Los Amigos data in `data/raw_data/your_data/` (69,096 mammal images once OFF067 is removed), the chapter writes 831 independent detections. With ch 3's lines (`arrange(deployment_id, sp, timestamp)` and `lag(timestamp) %--% timestamp`), it writes 4,939.
2. **The weekly frame's time zone.** In ch 3 and ch 12, effort weeks are labelled with `tz = "UTC"`, but the detection week, `strftime(ind_dat$timestamp, format = "%Y-W%U")`, uses the machine's time zone. On a machine set to Pacific time, 258 of those 4,939 detections get the previous week's label, and where that week has no effort row at the placename the detection is not counted. Adding `tz = "UTC"` to that call lines the two up.

Reprex: run ch 12 on `data/raw_data/your_data/` as written, then with the ch 3 lines. For the second item, run the weekly chunk after `Sys.setenv(TZ = "America/Vancouver")`.

We are happy to open a pull request if that would help, or to leave it with you. Claude Code helped find and measure these.

## Exploration (2026-11-11)

- Defect 1: `12-on_your_own.Rmd:445-448`. Ch 3's version: `03-error-checking.Rmd:1174-1179`
  (chunk `ch3_56`), which also ends with `ungroup()`.
- Defect 2: `12-on_your_own.Rmd:627` and `03-error-checking.Rmd:1441`. Effort weeks at
  `12:607` and `03:1421` use `tz = "UTC"`. Ch 3's daily frame already passes `tz = "UTC"` on
  its detection line (`03:1475`), so the fix follows the book's own pattern. `ymd_hms()` parses
  timestamps as UTC (`12:65`). No other `strftime` in ch 3 or ch 12 lacks `tz`.
- Ch 12's chunks are `eval=F` apart from the package chunk, so the measurement extracts and
  runs them.
- Upstream: one maintainer, no stated AI policy, and a commit search found no Claude
  co-authored commits upstream. No open PRs upstream.

## Measured (2026-11-12, `newgraph/check_fixes.R`, logs in `newgraph/logs/`)

Chapter text and Los Amigos tables read from the same commit. "Differ" counts the detections
whose detection-week label from each chapter's own expression changes between `UTC` and
`America/Vancouver`.

| ref | sha | images | events | written | differ (ch 12 / ch 3 line) | weekly total UTC / Van | weekly frame identical |
|---|---|---|---|---|---|---|---|
| `master` | `2c79f0e` | 69,096 | 852 | 831 | 35 / 35 | 831 / 831 | no |
| `ch12-independence-gap` | `8278ddc` | 69,096 | 5,027 | 4,939 | 258 / 258 | 4,939 / 4,939 | no |
| `weekly-detection-tz` | `18165f5` | 69,096 | 852 | 831 | 0 / 0 | 831 / 831 | yes |
| `newgraph` (both merged) | `0471220` | 69,096 | 5,027 | **4,939** | **0 / 0** | 4,939 / 4,939 | yes |

Images: mammal images identified to species (non-blank, species label present, not
`sapiens`), once OFF067 is removed, i.e. the rows entering the independence step.

### Two points for the draft's wording

- Item 1 says "69,096 mammal images once OFF067 is removed". After the OFF067 removal there are
  72,614 mammal images, 3,518 of them with no species label. 69,096 is the count identified to
  species (round 3 of the concern review).
- Item 2 says "where that week has no effort row at the placename the detection is not
  counted". That is true of the code, but on Los Amigos it did not happen: the weekly total
  is 4,939 under both zones, so the 258 detections were counted in the previous week rather
  than dropped.

### Other notes

- Ch 3's `ungroup()` is not needed in ch 12. Master's chunk was already grouped, and every
  later step regroups or ignores the grouping (concern review round 1).
- Ch 3 is `eval=T` on the Algar data. CI renders on a UTC runner, so the published book does
  not change from the tz fix (concern review round 3).
