## Checklist read

- **code-check.md**: I read the prose of all 14 H3s under `## Mechanisms`, skipping the `|` table rows: "A guard that fails toward pass", "A fixture that cannot reach the failure mode", "A proxy is not the property", "Verification that reads its own output", "A guard's scope, escape hatches, and remedies", "A fix lands in one of two callers that share a harness", "Restore the bug and prove the guard fires", "A shared working tree, and what generators leave in it", "A wrapper's exit is not the work", "Zero-length, empty, and unset are three different things", "The probe is broken before the world is", "Written data outlives the fix", "Serialization loses meaning silently" and "One fact derived twice". I did not read 24: the Rules that stand alone, Security, and Spreadsheets and PDFs sections. Nothing in those sections is used by this diff.
- **code-check-r.md**: I read 4 sections: "as.POSIXct on a Date pins UTC midnight; on a character it uses the machine zone", "`sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent", "A library call that dispatches on a global option is not a pure function" and "Inside a dplyr verb, a column named like a local variable wins". I did not read the other 116 of the file's 120 `###` headings.
- **code-check-shell.md**: I read 2 sections: "`git diff a..b` compares TIPS; a change on `a` shows up as the branch's" and "A verification command can be shadowed by a shell function or alias". I did not read the other 68 of 70.
- **code-check-spatial.md**: I read none of its 94 headings. The diff uses no terra, sf, bcdata or GDAL.

## Clean

No issues found.

## Enumeration: every number in the four texts

The logs I compared against:

- **M**: `newgraph:newgraph/logs/20261112_check_fixes_master.txt` (RESULT sha=2c79f0e)
- **G**: `scratchpad/20261112_check_fixes_ch12-independence-gap.txt` (RESULT sha=8278ddc)
- **T**: `scratchpad/20261112_check_fixes_weekly-detection-tz.txt` (RESULT sha=18165f5)

`newgraph:newgraph/check_fixes.R` is byte-identical (`cmp`) to the scratchpad `check_fixes.R` and `check_fixes_frozen.R`. What each figure counts:

- **images** is `nrow(env$img_sub)`, checked equal to the rows of `_raw_detections.csv`.
- **events** is `length(unique(raw_written$event_id))`.
- **written** is `nrow(_30min_independent_detections.csv)`.
- **chN_week_diff** is `sum(utc != van)`. It evaluates each chapter's detection-week `strftime(ind_dat$timestamp, ...)` text on ch 12's in-memory `ind_dat`, so the denominator is *written*.
- **week_obs_identical** is `identical()` of ch 12's `week_obs` built under UTC and under America/Vancouver.

### Commit 8278ddc (`ch12-independence-gap`)

| # | Number in text | (a) Tree claimed | (b) Population / qualifier claimed | (c) Where it is measured | (d) Match |
|---|---|---|---|---|---|
| 1 | "ch 12", "ch 3" | 8278ddc | `12-on_your_own.Rmd`, `03-error-checking.Rmd` | file names | yes |
| 2 | `ch3_56` | 8278ddc | the chunk that ch 12 now copies | `03-error-checking.Rmd:1174` at 8278ddc. Lines 1177-1179 equal the new ch 12 lines 446-448, minus `ungroup()` | yes |
| 3 | 69,096 | 8278ddc ("now") | mammal images identified to species once OFF067 is removed | G: `images entering the independence step: 69096` (nrow(img_sub)). Recounted from images.csv + deployments.csv at 8278ddc after the join and the OFF067 removal: non-blank, Mammalia, species non-NA and non-empty gives **69,096**. Of these, 0 are `sapiens`, so the human filter removes nothing. The 24 species are all non-human | yes |
| 4 | 4,939 | 8278ddc | independent detections ch 12 writes | G: `written=4939` | yes |
| 5 | 831 | before the change (2c79f0e) | independent detections ch 12 writes | M: `written=831` | yes |
| 6 | OFF067 | — | a placename, not a measured figure (244 image rows) | ch 12:299-300 | n/a |

### Commit 18165f5 (`weekly-detection-tz`)

| # | Number in text | (a) Tree claimed | (b) Population / qualifier claimed | (c) Where it is measured | (d) Match |
|---|---|---|---|---|---|
| 1 | "ch 3 and ch 12" | 18165f5 | the weekly frames | effort weeks at ch3:1421 and ch12:607 (`tz = "UTC"`). Detection weeks at ch3:1441 and ch12:627 | yes |
| 2 | 831 | "ch 12 as it stands" (18165f5; same at 2c79f0e) | independent detections written | T: `written=831` (M also 831) | yes |
| 3 | 35 | before this change (2c79f0e) | of those 831: ch 12's week label differs between America/Vancouver and UTC | M: `ch12_week_diff=35` | yes |
| 4 | "none after" (0) | 18165f5 | same population | T: `ch12_week_diff=0` | yes |
| 5 | "weekly frame is now the same under both zones" | 18165f5 | ch 12's `week_obs` | T: `week_obs_identical=TRUE` (M: FALSE) | yes |

### pr_c1.md (ch12-independence-gap -> newgraph)

| # | Number in text | (a) Tree claimed | (b) Population / qualifier claimed | (c) Where it is measured | (d) Match |
|---|---|---|---|---|---|
| 1 | #1 | fork issue | "the two concerns" | `gh issue view 1`: open, "Ch 12 independence step and the weekly frame's time zone" | yes |
| 2 | 2c79f0e | `master` | branch base | `git log` shows the parent of 8278ddc is 2c79f0e, the tip of master | yes |
| 3 | `ch3_56` | — | source of the lines | as in commit row 2 | yes |
| 4 | 69,096 (master row) | 2c79f0e | images entering the independence step | M: `images=69096` | yes |
| 5 | 852 | 2c79f0e | events | M: `events=852` | yes |
| 6 | 831 | 2c79f0e | independent detections written | M: `written=831` | yes |
| 7 | 69,096 (branch row) | 8278ddc | as row 4 | G: `images=69096` | yes |
| 8 | 5,027 | 8278ddc | events | G: `events=5027` | yes |
| 9 | 4,939 | 8278ddc | independent detections written | G: `written=4939` | yes |
| 10 | "Images are the mammal images identified to species, excluding humans, once OFF067 is removed" | both | nrow(img_sub) | ch 12 filter chunk: is_blank==0, species non-NA, class Mammalia, species != "sapiens", species != "". Recount 69,096 | yes |
| 11 | 258 of 4,939 | "this branch" (8278ddc) | week labels differing under America/Vancouver | G: `ch12_week_diff=258`, `written=4939` | yes |
| 12 | "four rounds", "Round 1", "round 3" | — | review history | round 1 file: other branch's message cited 4,939/258. Round 3 file: missing "identified to species". "four rounds" is excluded by the brief | yes |

### pr_c2.md (weekly-detection-tz -> newgraph)

| # | Number in text | (a) Tree claimed | (b) Population / qualifier claimed | (c) Where it is measured | (d) Match |
|---|---|---|---|---|---|
| 1 | #1, 2c79f0e | as pr_c1 | | the parent of 18165f5 is 2c79f0e | yes |
| 2 | `12-on_your_own.Rmd:627` | this branch (no line shift from 2c79f0e) | the detection-week `strftime` that gained `tz = "UTC"` | `git grep strftime( 18165f5` gives ch12:627 | yes |
| 3 | `03-error-checking.Rmd:1441` | same | same | gives ch3:1441 | yes |
| 4 | `03-error-checking.Rmd:1475` | same | ch 3's daily frame already passes `tz = "UTC"` | ch3:1475 is `strftime(..., "%Y-%m-%d", tz = "UTC")`. The diff does not touch it | yes |
| 5 | 831 (master row) | 2c79f0e | detections written | M: `written=831` | yes |
| 6 | 35 / 35 | 2c79f0e | labels differing for the ch 12 line / the ch 3 line, both evaluated on that row's 831 detections | M: `ch12_week_diff=35 ch3_week_diff=35` | yes (see note) |
| 7 | "no" | 2c79f0e | weekly frame identical across zones | M: `week_obs_identical=FALSE` | yes |
| 8 | 831 (branch row) | 18165f5 | detections written | T: `written=831` | yes |
| 9 | 0 / 0 | 18165f5 | as row 6 | T: `ch12_week_diff=0 ch3_week_diff=0` | yes |
| 10 | "yes" | 18165f5 | identical | T: `week_obs_identical=TRUE` | yes |
| 11 | 258 of 4,939 | "with the other concern and without this one" (8278ddc) | labels differing | G: `ch12_week_diff=258 written=4939` | yes |
| 12 | "Round 1 ... cited the 4,939 figures" | — | review history | round 1 file (commit 562b0cf) | yes |

Note on row 6/9: the "ch 3 line" figure is ch 3's expression applied to ch 12's 831 detections, not to ch 3's own data. The column says "ch 3 *line*". The row's denominator is the 831 written. The prose says the script "evaluates the detection-week expression read from each chapter". That is what `label_diff(week_expr(ch3, ...))` over `env$ind_dat` does, so it matches.

## Diffs re-checked

- **2c79f0e..8278ddc** (12-on_your_own.Rmd:446-448). The lines match `ch3_56` except for `ungroup()`.
  - Sorting by deployment, species and time keeps each group together. Each group's first row gets NA, so `cumsum(new_event)` never joins two groups into one event.
  - `duplicated(event_id)` keeps each event's earliest image.
  - The sort order of character keys (locale) only renumbers `event_id`, so the counts do not depend on it.
  - The leftover grouping is the same as on master (accepted).
  - No other `.Rmd` or `.R` file still contains `timestamp %--% lag` or `arrange(deployment_id)`.
- **2c79f0e..18165f5** (ch3:1441, ch12:627). Plain `strftime(x, tz = "")` labels in the machine's zone. `tz = "UTC"` matches the effort weeks (ch3:1421, ch12:607) and ch 3's daily line (1475). `git grep strftime(` at 18165f5 finds no other detection-week call. The monthly and lookup filters use `substr()` on the POSIXct, which follows its UTC `tzone`.
- Both branches are single commits on 2c79f0e, so the two-dot diffs equal the three-dot (merge-base) diffs.
