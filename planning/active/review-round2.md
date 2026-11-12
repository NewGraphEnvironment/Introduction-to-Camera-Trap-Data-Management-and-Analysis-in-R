## Checklist read

- **code-check.md**: I read the prose of all 14 H3s under `## Mechanisms`, without the `|` table rows or evidence blocks: A guard that fails toward pass; A fixture that cannot reach the failure mode; A proxy is not the property; Verification that reads its own output; A guard's scope, escape hatches, and remedies; A fix lands in one of two callers that share a harness; Restore the bug and prove the guard fires; A shared working tree, and what generators leave in it; A wrapper's exit is not the work; Zero-length, empty, and unset are three different things; The probe is broken before the world is; Written data outlives the fix; Serialization loses meaning silently; One fact derived twice. I did not read the other 24 headings.
- **code-check-r.md**: I read 13 headings and did not read 107:
  - `system2(stdout = TRUE)` warns on a non-zero exit instead of raising…
  - `on.exit()` at a script's top level never fires
  - `tempfile()` lives in the session tempdir…
  - as.POSIXct on a Date pins UTC midnight; on a character it uses the machine zone
  - A library call that dispatches on a global option is not a pure function
  - `[[` on a named ATOMIC vector with an absent key is an error, not `NULL`
  - `paste()` with a zero-length argument returns length ONE, not zero
  - `sub()` takes one replacement, not one per element
  - Rscript reads a script as it runs…
  - `identical()` on two reader results tests the reader, not the file
  - `expect_false(identical(x, y))` cannot fail when the two are different types
  - `c(name = x)` keeps `x`'s own name…
  - `$` on a list partial-matches…
- **code-check-shell.md**: I read 4 headings and did not read 66: Quoting; Git plumbing calls whose default answers a different question; Paths; A verification command can be shadowed by a shell function or alias.
- **code-check-spatial.md**: I read 2 headings and did not read 92: An offset regex must be anchored to a time, or a date looks like a zone; A reader that accepts a UTC offset may not be applying it.

## Clean

No issues found.

### The round-1 fix (check_fixes.R lines 28-35)

I ran the `git()` helper unchanged from the repo root against 12 refs and 2 `show` targets (scratchpad probe `r2/probe_git.R`).

- **Quoting with system2:** `system2()` quotes the command and pastes `args` raw, so `shQuote()` on every argument is the right layer.
  - `X^{commit}`, `--short`, a ref with a space (`a b`) and a ref with an apostrophe (`it's`) all reach git as single arguments.
  - The bad ones exit 128 and stop. Nothing is split by the shell.
- **Empty output on success:**
  - `rev-parse --short <ref>^{commit}` printed exactly one line for every valid ref: a short sha, a branch, a tag, `HEAD~1`, `origin/master` and `@{-1}`.
  - A range (`master..newgraph`) and a `<rev>:<path>` both exit 128, so the length check is a backstop that the current inputs never reach.
  - An empty `git show` result becomes `character(0)`. `chunks_of()` turns that into `list()`, and every `chunk()` lookup then stops with "found 0". It cannot pass silently.
- **Error message losing the reason:** with `stderr = FALSE`, an unknown ref and a missing file both report only "… exited 128". The command and file named in the message are enough to tell the two apart. Nothing runs past the failure, so this costs a rerun, not a wrong number.
  - git's "refname is ambiguous" warning is now discarded as well as kept out of the value.
  - No ref in this repo is ambiguous (`for-each-ref`: master, newgraph, worktree-detect, origin/*, upstream/*, tag v1).
  - The RESULT line records the resolved sha either way.
- **Long lines:** `system(intern = TRUE)` warns and splits a line over about 8 KB, and `suppressWarnings()` would hide that warning. The longest line at 2c79f0e is 392 characters in ch 12 and 595 in ch 3, so this does not apply.

### Rest of the script, checked and not reported

- **`chunks_of()`:** the close-fence offset is correct; the log reports ch12:17 for the fence on line 17. An empty chunk produces junk text, but no phrase can match it. Every phrase, patch and strftime match must occur exactly once, or the run stops.
- **Chunk selection:** the skipped ch 12 chunks (leaflet map, spacing, the table checks, activity plots, diel plot) reorder or annotate `dep`, or add and then remove `img$hours`. None of them changes `img_sub`, `row_lookup` or `ind_dat`'s rows. The hidden chunk at line 435 stands in for the `###INSERT###` chunk at 429.
- **Time zone:** `set_tz()` probes `strftime()` itself, the same code path the chapter uses, on every switch, and fails toward abort.
  - The effort week at ch 12 line ~606 already passes `tz = "UTC"` at master, and the regex reads only `ind_dat$timestamp`.
  - The monthly `substr(POSIXct)` follows the `tzone` attribute, which is why the monthly totals agree across zones.
- **Counts:**
  - `n_written`, `n_events` and `n_img` are read from the CSVs the chapter wrote, in a fresh temp dir, so no stale file can be read.
  - `stopifnot()` ties the file counts to the in-memory frames.
  - The label-difference denominator is the same `ind_dat` the weekly chunk uses.
- **Checkout untouched:** every `git()` call runs before `setwd(work)`. The chapter's writes (`data/raw_data/*_raw_species_list.csv`, `data/processed_data/`) land under the temp dir. A `stop()` part-way leaves only the session tempdir, which R removes on exit.
- **Inputs:** `data/raw_data/your_data/*.csv` is tracked and clean in the worktree, so all four refs run on the same data.
- **Out of scope:** the 1-failed-to-parse warning and the many-to-many warning come from the chapter, as the repo conventions say.
