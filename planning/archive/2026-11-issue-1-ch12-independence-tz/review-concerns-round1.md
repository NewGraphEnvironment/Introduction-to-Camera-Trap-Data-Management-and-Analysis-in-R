## Checklist read

- code-check.md: read all 14 H3s under `## Mechanisms` (prose only, skipping `|` table rows): A guard that fails toward pass; A fixture that cannot reach the failure mode; A proxy is not the property; Verification that reads its own output; A guard's scope, escape hatches, and remedies; A fix lands in one of two callers that share a harness; Restore the bug and prove the guard fires; A shared working tree, and what generators leave in it; A wrapper's exit is not the work; Zero-length, empty, and unset are three different things; The probe is broken before the world is; Written data outlives the fix; Serialization loses meaning silently; One fact derived twice. Not read: 24 (Rules that stand alone, Security, Spreadsheets and PDFs; none names a tool or pattern this diff uses).
- code-check-r.md: read 6: Reproducibility; as.POSIXct on a Date pins UTC midnight; on a character it uses the machine zone; `sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent; A library call that dispatches on a global option is not a pure function; `summarise()` and `mutate()` evaluate in order, so a later argument sees the summarised column; Inside a dplyr verb, a column named like a local variable wins. Not read: 114.
- code-check-spatial.md: read 2: An offset regex must be anchored to a time, or a date looks like a zone; A reader that accepts a UTC offset may not be applying it. Not read: 92.
- code-check-shell.md: read 1: `git diff a..b` compares TIPS; a change on `a` shows up as the branch's. Not read: 69.

## Findings

- **[severity: fragile]** commit 562b0cf (`weekly-detection-tz`) message, last paragraph. It says "On the Los Amigos data with ch 3's independence step (4,939 detections), 258 labels differed between America/Vancouver and UTC before this change and none after, and the weekly frame is the same under both zones."
  - The branch is meant to go upstream on its own, but it does not contain ch 3's independence step in ch 12. On this branch ch 12 still writes 831 detections, and 35 of them change label between the two zones before the fix.
  - The 258-of-4,939 figure was measured on `ch12-independence-gap`, which does not have the tz fix. "None after" and "same weekly frame" were measured only on this branch's 831 detections. Nobody ran the combined tree that the sentence describes.
  - Both "after" claims do hold by construction: with `tz = "UTC"` given explicitly, `strftime` no longer reads `TZ`. The sentence is still wrong about what was measured, though. An upstream reviewer who runs this branch will get 831 and 35, not 4,939 and 258.
  - Fix: cite this branch's own numbers (35 of 831 differ before, 0 after), or say that the 4,939 and 258 figures need the other branch applied too.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

## Checked and not a problem

- **ch12-independence-gap, img_tmp left grouped (no `ungroup()`).** This changes nothing compared with master, because master's chunk also ended with `group_by(deployment_id, sp) %>% mutate(...)`. Only the three diffed lines differ. Downstream steps behave the same either way:
  - `new_event`, `event_id` and `cumsum()` work on base vectors over the whole frame. Rows are now sorted by deployment, species and time, so each group's rows sit together and each group's first row is NA, so it starts a new event.
  - `top`, `bot`, `img_num` and `event_grp` all call `group_by(event_id)` without `.add`, which replaces the existing grouping.
  - In `left_join(img_tmp, diff)` the grouping comes from the left side, and `diff` brings in no grouping columns.
  - `[` subsetting and `ind_dat$sp <- as.factor(...)` regenerate the groups. Every frame-building loop calls `group_by(sp, .drop = F)`, which replaces them.
  - `write.csv` ignores grouping, and later chunks read the written CSVs back.
- The new sort makes each event's first row its earliest image, which matches ch 3.
- The data has no NA timestamps (0 of 69,096). In any case an NA would sort last within its group and fail the `row_lookup` filter.
- **Commit 39cc573 message:** the description of the old sign bug is accurate, and the `ch3_56` lines are copied exactly apart from `ungroup()`. I re-ran the 69,096 count after the chapter's OFF067 removal and filters, and it matches. 4,939 versus 831 matches the measurement.
- **weekly-detection-tz code:** `strftime(x, tz = "")` converts a UTC-parsed POSIXct to the machine's zone, while the effort labels, the monthly `substr()` and ch 3's daily frame all work in UTC. The fix makes the detection labels agree with all three. `git grep` finds no other `strftime` or `%Y-W%U` call on detections in either chapter, so no sibling caller was missed.
