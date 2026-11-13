# Review: ch 9 shuffle histograms, round 2

Diff: staged increment over aa7ee42 (`09-activity.Rmd`): `event_shuffle()` keeps `null` and unrounded `obs` as attributes, adds `plot_shuffle()`, stores `ck_sp` / `ck_ft`, and adds prose about the plots.

## Checklist read

- **code-check.md**: the prose of all 14 H3s under `## Mechanisms` (A guard that fails toward pass; A fixture that cannot reach the failure mode; A proxy is not the property; Verification that reads its own output; A guard's scope, escape hatches, and remedies; A fix lands in one of two callers that share a harness; Restore the bug and prove the guard fires; A shared working tree, and what generators leave in it; A wrapper's exit is not the work; Zero-length, empty, and unset are three different things; The probe is broken before the world is; Written data outlives the fix; Serialization loses meaning silently; One fact derived twice), skipping `|` table rows. Not read: the 14 under "Rules that stand alone", the 6 under Security and the 4 under Spreadsheets and PDFs, because none names a tool or shape this diff uses.
- **code-check-r.md**: 5 read: "A duplicate knitr chunk label fails the build, and reading the diff will not find it"; "`data.frame()` recycles a scalar against a zero-length column"; "`[[` on a named ATOMIC vector with an absent key is an error, not `NULL`" (for `ck["null"]`); "`c(name = x)` keeps `x`'s own name"; "`tolerance` in testthat is RELATIVE" (cited by "One fact derived twice" on printed values). About 147 not read.
- **code-check-shell.md**: none read, because the diff has no shell, sed or git code. All headings not read.
- **code-check-spatial.md**: none read, because the diff has no spatial code. All headings not read.

## The fix from round 1

The fix holds. `attr(out, "obs") <- unname(obs)` is the same object that `p = mean(null <= obs)` compares against, and the red line is drawn at `attr(res, "obs")`. The rendered `branch/09-activity.md` shows the fixed code (lines 570–579). In `ch9_null_5-1.png` the red line sits at 0.7847, which is where `p = 0.47` puts it.

## Every other displayed value or second derivation used as data

1. **Red line vs the printed `observed` column.** `observed` is rounded and only printed. The line uses the unrounded value (0.8267 and 0.7847), which matches the prose's "0.83 (red line)" and "0.78" at 2 dp. Holds.
2. **`event_shuffle`'s `obs` vs `compareCkern`'s `obs`.** These are two derivations of the same overlap: `ovl4` on default `fitact` fits against `ovl4` on the `sample = "model"` fits `m1`/`m2`. The prose and the code comment ("the coefficient compareCkern reports as obs") treat them as one number. I recomputed both from the data. They are bitwise equal: species 0.7846524083 for both, feature type 0.8267425550 for both. No NA in `sp`, `feature_type` or `solar`, so the subset filters (`==` vs `%in%`) select the same rows. Holds.
3. **Dashed line `ck["null"]`.** It reads the stored, unrounded `compareCkern` result. The rendered output prints the names as `obs null seNull pNull`, so `ck["null"]` is not a silent NA, and `abline()` ignores the name it carries. `ck_sp` is stored in ch9_12, before ch9_13/14 overwrite `m1`/`m2`, so each plot is paired with the right comparison (`ck_ft` with feature type, `ck_sp` with species). The `compareCkern` chunks are unseeded, so the line moves between renders, but only within 0.954–0.960. The largest shuffled overlap is 0.87 under seed 9 (0.84–0.87 across seeds), so "sits to the right of every shuffle" holds on every render. Holds.
4. **`mean_null` (rounded).** It is only printed. The prose quotes the printed values ("about 0.76", and 0.79 implied by "about the same"), and no code reuses it. Holds.
5. **Histogram bars vs printed `p`.** Both come from the same `null` vector. In the feature-type plot the red line falls inside the 0.82–0.83 bin (5 shuffles), so counting the bars to its right does not give exactly 1 − p. The prose claims only "higher than most shuffles" (p = 0.91), which the figure supports. Holds.
6. **"The grey bars are the overlaps from the 100 shuffles" vs `reps = 100` and the fixed `xlim = c(0.5, 1)`.** The fixed `xlim` is a second statement of the data's range. All 100 shuffles fall inside it: the minimum is about 0.62 (feature type) and 0.66 (species) under seed 9, and an overlap cannot exceed 1. No bar is clipped. Holds.
7. **The legend vs what is drawn.** Red solid and black dashed (`lty = c(1, 2)`) match the two `abline` calls. The legend sits top-left and clears the bars in both figures. Holds.
8. **Global names in the merged bookdown session.** `_bookdown.yml` sets no `new_session`, so all chapters run in one session. `ft`, `sp_test`, `ck_sp`, `ck_ft` and `plot_shuffle` appear in no other `.Rmd`. Holds.
9. **Sibling call `event_shuffle(cs, "season", "winter", "summer")`.** It still returns a one-row data frame, and `print.data.frame` does not show the attributes. Holds.

No chunk labels were added, so the duplicate-label rule does not apply.

## Clean
No issues found.
