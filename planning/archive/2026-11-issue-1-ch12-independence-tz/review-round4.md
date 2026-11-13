## Checklist read

- **code-check.md**: I read the prose of all 14 H3s under `## Mechanisms` and skipped their table rows. Those H3s are:
  - "A guard that fails toward pass"
  - "A fixture that cannot reach the failure mode"
  - "A proxy is not the property"
  - "Verification that reads its own output"
  - "A guard's scope, escape hatches, and remedies"
  - "A fix lands in one of two callers that share a harness"
  - "Restore the bug and prove the guard fires"
  - "A shared working tree, and what generators leave in it"
  - "A wrapper's exit is not the work"
  - "Zero-length, empty, and unset are three different things"
  - "The probe is broken before the world is"
  - "Written data outlives the fix"
  - "Serialization loses meaning silently"
  - "One fact derived twice"

  I did not read 24 headings: the stand-alone rules, Security, and Spreadsheets and PDFs. None of them names a tool or shape this diff uses.
- **code-check-r.md**: I read 12 headings and did not read 108. The 12 are:
  - "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising, so a `tryCatch(error =)` around it never fires"
  - "as.POSIXct on a Date pins UTC midnight; on a character it uses the machine zone"
  - "as.POSIXct on character infers ONE format for the whole vector"
  - "A library call that dispatches on a global option is not a pure function"
  - "`[[` on a named ATOMIC vector with an absent key is an error, not `NULL`"
  - "`tempfile()` lives in the session tempdir, so a path printed in an error names a file R is about to delete"
  - "`identical()` on two reader results tests the reader, not the file"
  - "`on.exit()` at a script's top level never fires"
  - "Rscript reads a script as it runs, so never edit a script while a run of it is in flight"
  - "`sub()` takes one replacement, not one per element"
  - "`$` on a list partial-matches, so a longer sibling key answers for a missing one"
  - "`file(open = "wb", encoding = )` does not re-encode on write"
- **code-check-shell.md**: I read 3 headings and did not read 67. The 3 are:
  - "Git plumbing calls whose default answers a different question"
  - "A fetch can fail and still deliver the commit, so when you need an object, test the object"
  - "Quoting"
- **code-check-spatial.md**: I read 2 headings and did not read 92. They are the two time-zone and offset reader rules:
  - "A reader that accepts a UTC offset may not be applying it"
  - "An offset regex must be anchored to a time, or a date looks like a zone"

## Clean

No issues found.

## Round-3 fixes, checked against the questions asked

I tested these in R 4.5.2 from the repo root (`<scratchpad>/probe1.R`).

- **Exit status of `system2()` with a file as stdout.**
  - `system2()` turns the call into `git 'show' '<sha>:<f>' 2>/dev/null > '<dest>'` and returns the shell's exit status, which is git's.
  - For a path that does not exist at the sha, it returned 128.
  - For a command that does not exist, it returned 127.
  - For a process killed by a signal, R returns the raw wait status, which is not 0.
  - So `status != 0` catches every failure. `!file.exists(dest)` is redundant, because the shell creates the file before git runs, but it does no harm.
- **Partial or empty writes.** The redirection creates `dest` before git starts. A failure mid-write leaves a truncated file, but the status is not 0, so the run stops. The leftover file is in a fresh `tempfile()` directory that is never read afterwards.
- **Byte fidelity.**
  - `git show <sha>:<blob>` streams the raw blob and applies textconv only when `--textconv` is passed. The repo has no `.gitattributes`, so no eol or LFS smudge applies either.
  - For each of the four CSVs at 2c79f0e, `git hash-object` of the written file equals `git rev-parse <sha>:<path>`. That includes `images.csv` (56,835,780 bytes), which is a real blob, not an LFS pointer.
- **A ref with no such file.** Git exits 128 and `stop()` fires.
- **A tree path (`<sha>:data/raw_data`).** Git exits 0 and prints a listing, which is not a CSV. This cannot happen here, because the four paths are literals that end in `.csv`.
- **Working directory.**
  - Every git call (lines 36, 68, 69 and 87) runs before `setwd(work)` on line 90, so all of them run in the checkout that line 27 guards.
  - After line 90 no git call is made.
- **`rmd()` through `stdout = TRUE`.**
  - R 4.5.2 reads a line longer than 8,096 bytes back as one element (tested with 9,000 bytes), so long lines are not split.
  - No CR bytes appear in either Rmd at 2c79f0e.
  - The longest line is 591 characters.
- **The ref is resolved once.** `sha` is a 40-hex value and is checked at line 37. `rmd()` and `git_to_file()` both use `sha`, never `ref`.

## Every input and its source now

| Input | Source |
|---|---|
| `<git-ref>` | Command-line argument. It is resolved once to a full sha with `rev-parse --verify <ref>^{commit}` in the checkout (line 36). |
| Ch 12 chunk text (all 10 steps run, the analysis-frames chunk, and the weekly expression) | `git show <sha>:12-on_your_own.Rmd` |
| Ch 3 weekly expression | `git show <sha>:03-error-checking.Rmd` |
| `projects.csv`, `cameras.csv`, `deployments.csv`, `images.csv` | `git show <sha>:data/raw_data/your_data/<f>.csv`, written byte for byte to the temp dir. Hashes were verified equal to the blobs. |
| Any other file the run chunks read | None. The only reads are the four `read.csv` calls in the "read" chunk, plus the script's own `read.csv` of the two CSVs that the chunks wrote into the fresh temp dir. |
| Package-install replacement, step phrases, `independent <- 30` | Literals in the script. The threshold is in the chapter text at the sha. |
| `TZ` | Set explicitly by `set_tz()`. A probe checks it after each switch. |
| Zone of `ind_dat$timestamp` and of `substr()` on it | `ymd_hms()` defaults to UTC, and that `tzone` attribute is carried through. Neither depends on the session zone. |
| R packages and `~/.Rprofile` | The machine's installed copies. Accepted. |
| Working tree | Only the `file.exists("12-on_your_own.Rmd")` guard reads it. That guard decides which repo git runs in and supplies no value. |
| Script globals visible to the chapter code (`env`'s parent is `globalenv()`) | At 2c79f0e every name the run chunks read is assigned in `env`/`fe` before use, so nothing leaks in. The planned independence fix changes only the `arrange()` and `mutate()` lines, which reference no new names. |

**What the RESULT fields measure.**
- `images` comes from `env$img_sub` after the independence step. The planned fix does not reassign `img_sub`, and `stopifnot(nrow(raw_written) == n_img)` ties it to the written file.
- `events` and `written` are read back from the CSVs the chunk wrote.
- `ch3_week_diff` applies ch 3's expression to ch 12's Los Amigos `ind_dat`, as the header documents.
- `sha` is the sha that was read.

## Reproduction

I ran a frozen copy (`Rscript <scratchpad>/check_fixes_frozen.R 2c79f0e` from the repo root). It exited 0. Its combined output is byte-identical to `newgraph/logs/20261112_check_fixes_master.txt`. `git status --short` was unchanged afterwards.
