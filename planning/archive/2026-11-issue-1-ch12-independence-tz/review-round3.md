## Checklist read

- **code-check.md**: I read the prose of all 14 H3s under `## Mechanisms`, skipping the `|` table rows: A guard that fails toward pass; A fixture that cannot reach the failure mode; A proxy is not the property; Verification that reads its own output; A guard's scope, escape hatches, and remedies; A fix lands in one of two callers that share a harness; Restore the bug and prove the guard fires; A shared working tree, and what generators leave in it; A wrapper's exit is not the work; Zero-length, empty, and unset are three different things; The probe is broken before the world is; Written data outlives the fix; Serialization loses meaning silently; One fact derived twice. I did not read the other 24 headings.
- **code-check-r.md**: I read 17 headings and did not read 103:
  - `system2(stdout = TRUE)` warns on a non-zero exit instead of raising…
  - as.POSIXct on character infers ONE format for the whole vector
  - as.POSIXct on a Date pins UTC midnight; on a character it uses the machine zone
  - A library call that dispatches on a global option is not a pure function
  - `on.exit()` at a script's top level never fires
  - `tempfile()` lives in the session tempdir…
  - `[[` on a named ATOMIC vector with an absent key is an error, not `NULL`
  - `$` on a list partial-matches…
  - `read.delim()` quotes by default…
  - `sub()` takes one replacement, not one per element
  - `paste()` with a zero-length argument returns length ONE, not zero
  - Rscript reads a script as it runs…
  - Moving prose into a code chunk hides it from tools that scan the document
  - `identical()` on two reader results tests the reader, not the file
  - Inside a dplyr verb, a column named like a local variable wins
  - `c(name = x)` keeps `x`'s own name…
  - `\<` and `\>` are word boundaries in R's default regex…
- **code-check-shell.md**: I read 4 headings and did not read 66: Quoting; Git plumbing calls whose default answers a different question; A verification command can be shadowed by a shell function or alias; A failed `cd` lets every later command run in the directory you were already in.
- **code-check-spatial.md**: I read 2 headings and did not read 92: An offset regex must be anchored to a time, or a date looks like a zone; A reader that accepts a UTC offset may not be applying it.

## Findings

The round-1 bug had this mechanism: a value was read from a channel that can also carry something else, and the script took whatever came through as the thing it wanted. I traced every input the script reads: git, the chapter text, the CSVs, the environment and the R search path. Two inputs are still read from a channel other than the one the RESULT line names. Neither changes a number for the four refs planned, so both are rated fragile, not bug.

- **[severity: fragile]** newgraph/check_fixes.R:79-81 (stamped at :34 and :163). The input data comes from the checkout's working tree, not from `<git-ref>`. The RESULT line still stamps `ref=… sha=…` as if the whole measurement were taken at that commit.
  - `file.copy(file.path("data", "raw_data", "your_data", …))` reads whatever is on disk in the checkout the script runs from. That is always `newgraph`, because the script exists only there. The chapter code, by contrast, is read from the ref.
  - These CSVs are tracked and have changed before (`git log -- data/raw_data/your_data/`: 40e36b4 "Update to new WI format", 9361acf, e772722).
  - So a ref whose data differs from the checkout's, or an uncommitted local edit to `images.csv`, pairs that ref's chapter code with other data. The script then reports counts under that ref's sha, and nothing flags the mismatch.
  - Today it is harmless. `git ls-tree 2c79f0e` and `git hash-object` on the working-tree files give identical blobs for all four CSVs, and the fix branches touch only `.Rmd` files.
  - Fix: write each CSV from `git show <sha>:data/raw_data/your_data/<f>.csv` into `yd`. Or, more simply, stop unless `git rev-parse <sha>:<path>` equals `git hash-object <path>` for each of the four files.
  - **Rule:** code-check.md "The probe is broken before the world is"

- **[severity: fragile]** newgraph/check_fixes.R:34, 36, 61-62. `ref` is resolved by name three separate times: once by `rev-parse` for the stamp, then once by each `git show` for the ch 12 and ch 3 text.
  - The stamped `sha` is never used to read anything.
  - If the branch tip moves between line 34 and lines 61-62, the stamp describes a different commit from the text that was measured. That gap is about 1–2 s, spent loading the packages at line 38. Another session or worktree committing to a fix branch is enough to move it.
  - In that case ch 12 and ch 3 could also come from different commits. The two `*_week_diff` numbers would then be printed side by side as if they came from one tree.
  - The chance is small, and nothing would show it if it happened.
  - Fix: resolve once with `rev-parse --verify <ref>^{commit}` (full sha), use that sha in `rmd()`, and print `--short` only for display.
  - **Rule:** code-check.md "Written data outlives the fix"

## Checked, not reported

- **The `git()` channel (round-1 fix).** The output is stdout only.
  - `color.ui=auto` emits no colour codes into a pipe.
  - No `.gitattributes`, and `git show <rev>:<blob>` does not apply textconv or filters, so the output is the raw blob bytes. A CRLF would be stripped by R's line reader.
  - Both `system2` calls run before `setwd(work)`, so they read the right repo.
- **The chapter-text channel.** Each phrase, `patch()` target and `week_expr()` match must occur exactly once, so a duplicated phrase (including one inside a comment) stops the run.
  - The regex in `week_expr()` also searches comments, so a comment can supply the expression.
  - It would do that silently only if a fix removed `strftime(ind_dat$timestamp …)` from the code and quoted it in a comment. The planned tz fix keeps `strftime` and adds `tz = "UTC"`, which still matches `[^)]*`.
  - At 2c79f0e neither weekly chunk (ch 12 lines 530-640, ch 3 chunk `ch3_68`) has such a comment. If a fix were shaped differently, parsing the chunk and taking the `strftime` call from the parse tree would close this off.
- **The CSV read-back (lines 109-114).** `stopifnot(nrow(raw_written) == n_img, nrow(env$ind_dat) == n_written)` would catch rows lost or inflated by `read.csv`.
  - The work directory is a fresh `tempfile()`, so no stale output from an earlier run can be read back.
- **The TZ environment.** `set_tz()` probes `strftime()` against a known answer after every switch.
  - `old_tz` is restored.
  - The monthly frame (`substr(ind_dat$timestamp, 1, 7)`) and the effort week (`tz = "UTC"` on line 607) do not depend on the zone, so `week_obs_identical` isolates the detection-week expression.
- **Leaks between `env` and the script.** Every name read by the chunks that run is assigned in `env` before use at 2c79f0e, so none of the script's globals (`f`, `pid`, `ind`, …) is picked up.
- **NA timestamps.** The "1 failed to parse" warning would give `sum(utc != van)` an NA, and that NA would print visibly. At 2c79f0e the row_lookup filter on ch 12 line 496 drops such rows before `ind_dat`, which is why the result is 35.
- **Package set.** Loading 4 packages instead of the chapter's 34 is the accepted design. None of the 34 masks the verbs the measured chunks call (`lag`, `arrange`, `top_n`, `%--%`, `int_length`), and the chapter uses `dplyr::select` explicitly.
- **The log reproduces.** I ran a frozen copy (`Rscript <scratchpad>/check_fixes_frozen.R 2c79f0e`), which exited 0 in 10 s. Its output was byte-identical to `newgraph/logs/20261112_check_fixes_master.txt`, and the checkout was unchanged afterwards.
