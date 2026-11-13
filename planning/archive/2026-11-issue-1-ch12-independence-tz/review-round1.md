## Checklist read

- **code-check.md**: read the prose of all 14 H3s under `## Mechanisms` (table rows skipped). Of the 26 headings under "Rules that stand alone", "Security" and "Spreadsheets and PDFs", read 0 in full; none names a tool, shape or pattern this diff uses. The index lines were checked.
- **code-check-r.md**: read in full "`on.exit()` at a script's top level never fires", "as.POSIXct on a Date pins UTC midnight; on a character it uses the machine zone", "`identical()` on two reader results tests the reader, not the file", "A library call that dispatches on a global option is not a pure function", "`[[` on a named ATOMIC vector with an absent key is an error, not `NULL`", "`tempfile()` lives in the session tempdir, so a path printed in an error names a file R is about to delete", "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising, so a `tryCatch(error =)` around it never fires" and "`sub()` takes one replacement, not one per element" (8). The other ~110 were not read in full.
- **code-check-shell.md**: read in full "Quoting" and "Git plumbing calls whose default answers a different question" (2). The other ~71 were not read in full.
- **code-check-spatial.md**: read 0 in full. The diff uses no spatial tool. All ~105 index lines were checked.

## Verification performed

I copied `newgraph/check_fixes.R` to the scratchpad, changing only two lines: `rmd()` reads a local directory and `sha` is a constant. I ran the copy from the repo root against four chapter-file sets:
- the 2c79f0e (master) text;
- an independence fix: `arrange(deployment_id, sp, timestamp)` and `int_length(lag(timestamp) %--% timestamp)`;
- a tz fix: `, tz = "UTC"` added to ch 12 line 627 and ch 3 line 1441;
- both fixes together.

| variant | events | written | ch12 diff | ch3 diff | weekly UTC / Van | week_obs identical |
|---|---|---|---|---|---|---|
| master | 852 | 831 | 35 | 35 | 831 / 831 | FALSE |
| independence fix | 5027 | 4939 | 258 | 258 | 4939 / 4939 | FALSE |
| tz fix | 852 | 831 | 0 | 0 | 831 / 831 | TRUE |
| merge | 5027 | 4939 | 0 | 0 | 4939 / 4939 | TRUE |

Every expected number reproduces. `git status --short` afterwards showed only the two staged files, so the runs wrote nothing into the checkout.

What I confirmed:
- `week_expr()`'s regex `strftime\(ind_dat\$timestamp[^)]*\)` picks up the fixed text: it has no `)` before the closing paren.
- Both the ch 12 and ch 3 weekly chunks have exactly one match.
- The analysis-frames chunk is found by its phrase at every variant.
- The `set_tz()` probe passes a UTC-tzone POSIXct to `strftime(tz = "")`, the same shape as `ind_dat$timestamp`. So it proves the TZ switch reaches the expression under test.
- Nothing else in the pipeline depends on TZ. `substr(ind_dat$timestamp, ...)` goes through `as.character.POSIXt`, which honours the `tzone` attribute. `ymd_hms` defaults to UTC, and the effort side uses Dates with `tz = "UTC"`. Running the pipeline in UTC therefore does not change the written count.
- The zeros at the tz and merge refs are not vacuous:
  - the probe is an in-run positive control on the instrument;
  - the same `ind_dat` gives 35 and 258 differences under the unfixed expression;
  - the log prints the extracted expression and the denominator.
- The chunks the script skips (lines 70–297: maps, distances, plots) only reorder `dep` or make `placename` a factor. They do not change any count.

## Findings

- **[severity: fragile]** newgraph/check_fixes.R:28-33 — `git()` captures `stderr = TRUE` into the same vector it returns, and that vector is then parsed.
  - **What goes wrong:** `sha <- git("rev-parse", "--short", ...)` becomes length 2 whenever git writes a warning to stderr. One example is `warning: refname 'X' is ambiguous.`, when a branch and a tag share a name. The final `sprintf("RESULT ... sha=%s ...")` is vectorised, so it then prints two RESULT lines, one with the warning text as the sha. The same applies to `rmd()`: a stderr line would be prepended to the chapter text, which shifts every reported `ch12:<line>` number.
  - **Arguments:** they go to the shell unquoted through `system2()`. That is harmless for the planned refs, because `^{commit}` and `/` are not special to `sh`.
  - **Likelihood:** low for the four planned refs. But it would print a wrong provenance line rather than stop.
  - **Fix:** use `stderr = FALSE`, or a tempfile that is printed only on failure. Add `stopifnot(length(sha) == 1)`, and `shQuote()` the ref argument.
  - **Rule:** code-check.md "A wrapper's exit is not the work"

No bug, security or wrong-number findings: the script measures what it claims at all four refs.
