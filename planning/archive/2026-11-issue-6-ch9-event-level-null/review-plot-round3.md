# Review: ch9 shuffle histograms, round 3 (staged increment over aa7ee42)

## Checklist read

- **code-check.md**: all 14 H3s under `## Mechanisms`, prose only, skipping `|` table rows: A guard that fails toward pass; A fixture that cannot reach the failure mode; A proxy is not the property; Verification that reads its own output; A guard's scope, escape hatches, and remedies; A fix lands in one of two callers that share a harness; Restore the bug and prove the guard fires; A shared working tree, and what generators leave in it; A wrapper's exit is not the work; Zero-length, empty, and unset are three different things; The probe is broken before the world is; Written data outlives the fix; Serialization loses meaning silently; One fact derived twice. Not read: 20 headings under Rules that stand alone, Security and Spreadsheets and PDFs. None of them names a tool, shape or pattern this diff uses.
- **code-check-r.md**: 5 read: "`[[` on a named ATOMIC vector with an absent key is an error, not `NULL`" (the diff uses `ck["null"]`); "`c(name = x)` keeps `x`'s own name..." (`abline(v = ck["null"])` passes a named value); "A duplicate knitr chunk label fails the build..."; "`data.frame()` recycles a scalar against a zero-length column"; "A library call that dispatches on a global option is not a pure function" (`print` and `round` of printed numbers). 116 not read.
- **code-check-shell.md**: 0 read. The diff has no shell, sed or git code.
- **code-check-spatial.md**: 0 read. The diff has no spatial code.

## Fresh angles checked (beyond rounded values and twice-derived data)

- **`ck["null"]` key**: `compareCkern()` returns a named num `c(obs, null, seNull, pNull)` (`str()` run on activity as installed, and the rendered output at md lines 458 and 521). The `"null"` key exists, so the call does not return the length-1 `NA` that would make `abline` silently draw nothing. A named value passed to `abline(v=)` is harmless.
- **`xlim = c(0.5, 1)` clipping**: if any shuffle fell below 0.5, `hist` would draw it off the plot without a warning, and "the 100 shuffles" would be false. I measured the shuffled-overlap range at seeds 9 and 1–6. Feature type: min 0.589 (seed 6), 0.621 at seed 9. Species: min 0.650, 0.663 at seed 9. Max ≤ 0.906. So nothing is clipped, and the published render (seed 9) shows all 100.
- **Seed 9 reproduces the render exactly**: ft 0.83 / 0.76 / p 0.91 / 87 / 254; sp 0.78 / 0.79 / p 0.47 / 562 / 119. Unrounded obs 0.8267 and 0.7847, which match `ck_ft["obs"]` 0.8267 and `ck_sp["obs"]` 0.7847 printed in the render. So the red line and compareCkern's dashed line are on the same coefficient scale.
- **`fitact()` default**: `sample = "none"`, so the shuffles draw no RNG beyond `sample()`, and `set.seed(9)` alone fixes the figures.
- **One-session knit**: the new globals are `ck_sp`, `ck_ft`, `ft`, `sp_test` and `plot_shuffle`. None appears in any other chapter's .Rmd (grep across all *.Rmd). `ck_sp` is assigned before `m1`/`m2` are overwritten in ch9_13/14, so it holds the species comparison. Turning a printed call into an assign-then-print uses no RNG, so the upstream unseeded `compareCkern` output is unchanged in kind.
- **Sibling branch** (worktree `ch9-season`, branch `ch9-activity-season`): it does not yet call `event_shuffle` or use any new name. Its top-level `obs`/`ev`/`cs` do not collide with the function locals. `print.data.frame` does not show the custom attributes, so the printed one-row frame is unchanged.
- **Chunk labels**: the diff adds none. Existing ch9 labels are unique.
- **Overlap of plot elements**: in both figures the legend (top left, x ≈ 0.5–0.69) does not cover any bar or either vertical line.

## Prose enumeration (every new or changed sentence in the diff)

| # | Sentence | Source of truth | Holds |
|---|---|---|---|
| 1 | "The grey bars are the overlaps from the 100 shuffles." | `reps = 100` default; measured seed-9 range 0.621–0.868, all inside xlim; figure ch9_null_3-1.png | Yes |
| 2 | "With feature types shuffled among events, two random groups overlap by only about 0.76 on average, even though the label means nothing: …" (unchanged apart from following #1) | render md:597 `mean_null 0.76`; events 87/254 (md:539) | Yes |
| 3 | "The observed 0.83 (red line) is higher than most shuffles, so `p` is high, …" | md:597 observed 0.83, p 0.91; figure: red line at 0.827, most bars to its left | Yes |
| 4 | "… and `compareCkern`'s null (dashed line) sits to the right of every shuffle." | md:522 null 0.957; seed-9 max shuffle 0.868 (figure: dashed at ~0.957, last bar ends ~0.87); seeds 1–6 max ≤ 0.867 vs null 0.954–0.960 | Yes |
| 5 | "A high `p` means … / So the data do not show …" (unchanged) | md:597 p 0.91 | Yes |
| 6 | "The observed overlap (0.78) is about the same as that of two random groups of events (the red line falls among the bars), and `p` is well above 0.05, …" | md:634 observed 0.78, mean_null 0.79, p 0.47; figure ch9_null_5-1.png: red line at 0.785 with bars on both sides (tallest bin adjacent); seeds 1–6 p 0.33–0.44 | Yes |
| 7 | "When you compare activity patterns from raw images, always test …" (unchanged) | n/a (advice) | n/a |
| C1 | Comment "keep the shuffled overlaps, and the unrounded observed one, to plot" | code: `attr(out,"null") <- null`, `attr(out,"obs") <- unname(obs)` | Yes |
| C2 | Comment/legend "compareCkern's null" | `ck["null"]`, which the chapter's own bullet defines as the "mean null overlap index" | Yes |
| C3 | Comment "observed overlap" on the red line | `attr(res,"obs")` = unrounded obs, which equals compareCkern's obs | Yes |

## Clean

No issues found.
