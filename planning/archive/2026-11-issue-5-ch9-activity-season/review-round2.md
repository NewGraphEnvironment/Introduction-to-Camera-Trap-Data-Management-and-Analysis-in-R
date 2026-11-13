# Code-check review, round 2: `newgraph/check_ch9_season.R`, its log, findings.md "Measured"

## Checklist read

- code-check.md (read by heading): all 14 H3s under `## Mechanisms` read as prose (table rows
  skipped). Not read: 24 others (Rules that stand alone, Security, Spreadsheets and PDFs); none
  names a tool or shape this diff uses.
- code-check-r.md (read by heading): 4 read: `match()` treats NA as a matchable VALUE;
  `ifelse()` with an all-NA test; `[[` on a named ATOMIC vector with an absent key;
  `system2(stdout = TRUE)` warns on a non-zero exit. 117 not read.
- code-check-shell.md (read by heading): 0 read, 71 not read (only shell is the `| tee` usage line).
- code-check-spatial.md (read by heading): 0 read, 94 not read (no sf/terra/GDAL).

## What was checked and holds

- `block_null()` generalised: filters to the two labels, one row per event, guard that each event
  carries one label, permutes labels across events and maps them back to every image, refits with
  the same `ovl4` path as `obs`. p = `mean(null <= obs)` is the right (lower) tail: low overlap =
  different. Event counts in the log (562 vs 119; 137 vs 12; 313 vs 74; 87 vs 254; 21 vs 74;
  54 vs 129) reconcile with section 1.
- Species shuffle is a valid permutation null for deer vs caribou: re-probed every event is one
  species, one site, one calendar month, one season, one feature type (1,543 of 1,543). The
  pooled shuffle is not exchangeable with respect to season (caribou summer-heavy), but that
  confound lowers the observed overlap, i.e. biases toward finding a difference; the result is
  non-significant, so "no detectable difference" stands.
- Subsetting by season before `block_null()` keeps events whole (no event spans two seasons), so
  the within-season lines test what the log says.
- Deer winter vs summer: also probed with season shuffled **within site** (17 sites with deer in
  both seasons, tz -6, 100 reps): obs 0.53, null 0.74 (min 0.59), p 0.000. The deer seasonal claim
  is not a site-mix artefact.
- Caribou winter dates (6 in Nov 2018 to Mar 2019, 6 on 2019-11-14..20, 6 sites) confirmed.
- Script mtime 18:04:38 UTC precedes the log's run stamp 18:04:44 UTC; working copy == staged.
- Table 2 (shares), the tz -6 pooled/within-season table, season mixes, HumanUse 27% / Offline 32%,
  "up to 1.0 h / 1.9 h", and the deer rows of table 1 all follow from the log.

## Findings

- **[severity: bug]** planning/active/findings.md:65 — "deer, season shuffled across events": the
  -7 and DST null means are swapped. Table says -7 `0.77`, DST `0.78`; log says -7 null 0.78
  (line 62) and DST null 0.77 (line 91).
  - **Rule:** code-check.md "Written data outlives the fix" ; code-check.md "The probe is broken before the world is"

- **[severity: bug]** planning/active/findings.md:67 — "caribou, images (compareCkern)", DST cell
  `0.73 (0.87)`; log line 93 says null 0.88.
  - **Rule:** code-check.md "Written data outlives the fix"

- **[severity: bug]** planning/active/findings.md:68 — "caribou, season shuffled across events",
  -7 cell `p 0.83`; log line 66 says p 0.850. (DST `p 0.96` against 0.965 is rounding.) These three
  cells look carried over from the pre-re-run log: the re-run changed the RNG stream (new
  `block_null` calls), and the hand-copied table was not re-derived from the new log.
  - **Rule:** code-check.md "Written data outlives the fix"

- **[severity: bug]** planning/active/findings.md:86-87 — "Under -7 and DST the event-shuffle p
  ranges are 0.25–0.44 (species, pooled) ... and 0.065–0.13 (feature type, summer)". The upper ends
  are the tz -6 values (0.440, log 45; 0.130, log 55). Under -7 and DST alone the ranges are
  0.25–0.37 and 0.065–0.075. Either say "across all three variants" (then 0.25–0.44, 0.91–0.95,
  0.065–0.13 are right) or use the -7/DST ranges. The conclusion (none reaches 0.05) is unaffected.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** planning/active/findings.md:102 — "Feature type is a site property
  (14 HumanUse, 13 Offline sites)" counts every camera site in the locations file, not the units a
  site-level shuffle of the deer comparison would permute. Deer were detected at 9 HumanUse and
  9 Offline sites (winter 6 / 5, summer 8 / 9). Not in the log. The point ("stricter still") holds,
  more strongly; the numbers describe the wrong population.
  - **Rule:** code-check.md "A proxy is not the property"
