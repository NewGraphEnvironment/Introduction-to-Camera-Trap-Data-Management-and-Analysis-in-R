# Review: concern branches, round 3

## Checklist read

- **code-check.md**: I read the prose (not the table rows) of all 14 H3s under `## Mechanisms`: A guard that fails toward pass; A fixture that cannot reach the failure mode; A proxy is not the property; Verification that reads its own output; A guard's scope, escape hatches, and remedies; A fix lands in one of two callers that share a harness; Restore the bug and prove the guard fires; A shared working tree, and what generators leave in it; A wrapper's exit is not the work; Zero-length, empty, and unset are three different things; The probe is broken before the world is; Written data outlives the fix; Serialization loses meaning silently; One fact derived twice. I did not read 24 headings (Rules that stand alone, Security, Spreadsheets and PDFs). None names a tool or shape these diffs use.
- **code-check-r.md**: I read 4 headings: as.POSIXct on a Date pins UTC midnight; on a character it uses the machine zone. `sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent. A library call that dispatches on a global option is not a pure function. Reproducibility. I did not read 116.
- **code-check-spatial.md**: I read 2 headings: An offset regex must be anchored to a time, or a date looks like a zone. A reader that accepts a UTC offset may not be applying it. I did not read 92.
- **code-check-shell.md**: I read 1 heading: `git diff a..b` compares TIPS; a change on `a` shows up as the branch's. I did not read 69.

## The mechanism behind round 1's finding

A figure was stated about the branch's tree but measured on another tree. The number was correct for the tree it was measured on, but the sentence attached it to a different one. The rule is code-check.md "The probe is broken before the world is": *write the numbers last, against the final tree, and re-measure when a fix lands after the prose*. The supporting rule is "One fact derived twice": a derived fact belongs to the commit it was read at, so re-derive it against one commit or cite that commit beside it.

To check this round's figures, I matched each one to the tree it was measured on:

- The 831, the 35-of-831 and the "weekly frame differs" figures come from the log for `ref=2c79f0e`. That commit is the parent of both branches.
- The 4,939 and 5,027 figures come from the log for `sha=39cc573`, the tip of ch12-independence-gap.
- The 0-of-831 and "weekly frame identical" figures come from the log for `sha=18165f5`, the tip of weekly-detection-tz.
- The script reads the chapter text and `data/raw_data/your_data/` from the same sha. `newgraph:newgraph/check_fixes.R` is byte-identical to the scratchpad copy used for the branch logs.

Every figure is attached to the tree it was measured on.

## Findings

- **[severity: fragile]** ch12-independence-gap commit 39cc573, message paragraph 2: "(69,096 mammal images once OFF067 is removed)" mislabels the figure.
  - 69,096 is `nrow(img_sub)`. The log calls it "images entering the independence step".
  - That count comes after ch 12's filter step (`12-on_your_own.Rmd:372-376`), which keeps non-blank, species-identified, non-human mammals.
  - On the data at that commit, after the join and the OFF067 removal, there are **72,614** `class == "Mammalia"` images. All of them are non-blank. 3,518 have no species label and none are `sapiens`.
  - Someone who checks the figure using the message's own description will get 72,614, not 69,096. The parenthetical left out the "identified to species" condition. The headline figures (4,939 against 831) are correct.
  - Suggested wording: "69,096 mammal images identified to species once OFF067 is removed".
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" ; code-check.md "A proxy is not the property"

## Claims checked and supported

**ch12-independence-gap (39cc573)**

- "sorted images by deployment only": supported. Line 446 at `2c79f0e` reads `arrange(deployment_id)`.
- "`int_length(timestamp %--% lag(timestamp))` is negative for rows in time order, so a gap passed the threshold only where rows were out of time order": supported. Line 456 (`is.na(duration) | duration > independent*60`) is outside the diff, so it is the same at `2c79f0e`.
- "takes ch 3's lines (chunk ch3_56)": supported. Lines 446-448 match `03-error-checking.Rmd:1177-1179` exactly, minus the `ungroup()` you accepted leaving out.
- "4,939 instead of 831": supported by the logs at 39cc573 and 2c79f0e.
- Assumptions about the rest of ch 12:
  - The `cumsum(new_event)` event numbering needs each (deployment, species) group to be contiguous and in time order. The new `arrange` provides that, and `group_by()` plus `mutate()` keep the row order.
  - `group_by(event_id)` replaces the existing grouping. `$<-` on `sp` regroups exactly as it did on master, where `img_tmp` was already grouped.
  - The one timestamp that fails to parse (NA) now sorts last in its group. It becomes its own event and is dropped by the effort filter, because `substr(NA)` matches no row in the lookup.
  - Nothing later in ch 12 reads `_raw_detections.csv` or depends on its row order. Later chunks read only the species list, the camera locations and the total/monthly frames.

**weekly-detection-tz (18165f5)**

- "effort weeks labelled with `tz = "UTC"`": supported. See `03-error-checking.Rmd:1421` and `12-on_your_own.Rmd:607`.
- "Timestamps are parsed as UTC": supported. `ymd_hms()` defaults to UTC at `03:220` and `12:65`.
- "Ch 3's daily frame already passes `tz = "UTC"`": supported. See `03:1475`.
- "west of UTC an early-Sunday detection got the previous week's label": supported. `%U` weeks start on Sunday, and the script's probe confirms it.
- "831 ... 35 differed before, none after; weekly frame now identical": supported by the logs at 2c79f0e and 18165f5.
- Coverage: no other timestamp call in ch 3 or ch 12 depends on the machine's time zone. The only `strftime` calls are at `03:1421`, `03:1441`, `03:1475`, `12:607` and `12:627`. `substr()`, `hour()` and `minute()` on the POSIXct use its own `tzone` attribute, which is UTC.
- Later chapters:
  - `06-community_metrics.Rmd:256` and `08-occupancy.Rmd:45` read the Algar weekly CSV as it is and do not recompute week labels.
  - `data/processed_data/` is gitignored, so there is no committed CSV left stale by the change. It is regenerated by ch 3 (eval=T) during the render.
  - CI renders on macos-latest, which runs in UTC, so the published book does not change.

## Verdict

The code in both diffs is clean. The one finding is the population label in the ch12-independence-gap commit message, which can be fixed by amending the message.
