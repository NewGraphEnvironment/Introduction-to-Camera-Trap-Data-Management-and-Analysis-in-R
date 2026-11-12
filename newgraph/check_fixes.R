# Measure ch 12's independent detections and the weekly frame's time zone on the book's own
# Los Amigos data, from the chapter text at a git ref.
#
# Usage, from the repository root:
#   Rscript newgraph/check_fixes.R <git-ref> 2>&1 | tee newgraph/logs/<yyyymmdd>_check_fixes_<name>.txt
#
# Ch 12's chunks are eval=F, so they are read from `12-on_your_own.Rmd` at <git-ref>, found
# by a phrase each contains, and run in a temporary directory holding data/raw_data/your_data/
# as it is at the same commit. The one
# change to the chapter's code is the package-install line, which becomes library() calls.
# Every phrase and substitution must match exactly once, or the run stops.
#
# It reports:
#   1. the images entering the independence step, the events it forms, and the rows in the
#      `_30min_independent_detections.csv` it writes;
#   2. for the detection-week expression in ch 12's weekly frame and in ch 3's
#      (`strftime(ind_dat$timestamp, ...)`, read from each chapter at <git-ref>), how many
#      detections get a different week label under TZ=America/Vancouver than under UTC;
#   3. the total, monthly and weekly frames ch 12 builds, run under both time zones: their
#      observation totals and whether the weekly frame is identical.
#
# Writes nothing into the checkout.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) stop("usage: Rscript newgraph/check_fixes.R <git-ref>")
ref <- args[[1]]
if (!file.exists("12-on_your_own.Rmd")) stop("run from the repository root")

# stdout only: a warning git writes to stderr (an ambiguous refname) must not become output.
git <- function(...) {
  out <- suppressWarnings(system2("git", shQuote(c(...)), stdout = TRUE, stderr = FALSE))
  if (!is.null(attr(out, "status"))) stop("git ", paste(c(...), collapse = " "), " exited ", attr(out, "status"))
  out
}
# Resolve the ref once; the chapter text and the data are both read from this commit.
sha <- git("rev-parse", "--verify", paste0(ref, "^{commit}"))
if (length(sha) != 1 || !grepl("^[0-9a-f]{40}$", sha)) stop("git rev-parse gave no single sha for ", ref)
rmd <- function(file) git("show", paste0(sha, ":", file))
# A file at `sha`, written byte for byte to `dest`.
git_to_file <- function(file, dest) {
  status <- system2("git", shQuote(c("show", paste0(sha, ":", file))), stdout = dest, stderr = FALSE)
  if (status != 0 || !file.exists(dest)) stop("git show ", sha, ":", file, " exited ", status)
}

suppressPackageStartupMessages({ library(dplyr); library(lubridate); library(stringr); library(tidyr) })

# Chunks of an Rmd, as text with the line each opens on.
chunks_of <- function(lines) {
  open_at <- grep("^```\\{r", lines)
  lapply(open_at, function(i) {
    close <- i + which(grepl("^```\\s*$", lines[(i + 1):length(lines)]))[1]
    list(line = i, code = paste(lines[(i + 1):(close - 1)], collapse = "\n"))
  })
}
# The one chunk containing `phrase`.
chunk <- function(chunks, phrase, label) {
  hit <- which(vapply(chunks, function(ch) grepl(phrase, ch$code, fixed = TRUE), TRUE))
  if (length(hit) != 1) stop(label, ": expected one chunk containing '", phrase, "', found ", length(hit))
  chunks[[hit]]
}
# Replace `from` with `to`; `from` must occur exactly once.
patch <- function(code, from, to) {
  n <- lengths(regmatches(code, gregexpr(from, code, fixed = TRUE)))
  if (n != 1) stop("substitution target found ", n, " times: ", substr(from, 1, 60))
  sub(from, to, code, fixed = TRUE)
}

ch12 <- chunks_of(rmd("12-on_your_own.Rmd"))
ch3 <- chunks_of(rmd("03-error-checking.Rmd"))

# Pipeline runs in UTC, as ymd_hms() parses; the time-zone checks switch it explicitly.
set_tz <- function(z) {
  Sys.setenv(TZ = z)
  # 2019-01-06 is a Sunday: at 03:00 UTC it is Saturday evening in Vancouver, so the week label
  # in the session's zone changes. Checks that the switch reaches strftime().
  probe <- strftime(as.POSIXct("2019-01-06 03:00:00", tz = "UTC"), format = "%Y-W%U")
  want <- c(UTC = "2019-W01", "America/Vancouver" = "2019-W00")[[z]]
  if (probe != want) stop("time zone switch to ", z, " did not take effect (probe ", probe, ")")
}
old_tz <- Sys.getenv("TZ", unset = NA)
set_tz("UTC")

work <- tempfile("check_fixes_")
yd <- file.path(work, "data", "raw_data", "your_data")
dir.create(yd, recursive = TRUE)
for (f in c("projects", "cameras", "deployments", "images")) {
  git_to_file(paste0("data/raw_data/your_data/", f, ".csv"), file.path(yd, paste0(f, ".csv")))
}
home <- getwd()
setwd(work)
env <- new.env(parent = globalenv())

run <- function(env, label, phrase, subs = list()) {
  ch <- chunk(ch12, phrase, "ch 12")
  code <- ch$code
  for (s in subs) code <- patch(code, s[[1]], s[[2]])
  for (e in parse(text = code, keep.source = FALSE)) suppressMessages(eval(e, envir = env))
  message(sprintf("STEP %-24s ch12:%-4d %s", label, ch$line, if (length(subs)) "run (package line replaced)" else "run"))
}

run(env, "read", 'read.csv("data/raw_data/your_data/projects.csv"', list(list(
  'if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)',
  "library(dplyr); library(lubridate); library(stringr); library(tidyr)")))
run(env, "dates", "dep$days <- interval")
run(env, "remove_OFF067", 'dep <- dep[dep$placename!="OFF067",]')
run(env, "species_list", "taxonomy_headings <- c(")
run(env, "filter", "# Remove observations without animals detected")
run(env, "effort_lookup", "# Create your daily lookup")
run(env, "threshold", "independent <- 30")
run(env, "animal_count", "img_sub$animal_count <- img_sub$number_of_objects")
run(env, "independent_detections", "# Create your independent data")

pid <- env$pro$project_id[1]
pd <- file.path("data", "processed_data")
written <- read.csv(file.path(pd, paste0(pid, "_30min_independent_detections.csv")))
raw_written <- read.csv(file.path(pd, paste0(pid, "_raw_detections.csv")))
n_img <- nrow(env$img_sub)
n_events <- length(unique(raw_written$event_id))
n_written <- nrow(written)
stopifnot(nrow(raw_written) == n_img, nrow(env$ind_dat) == n_written)
message("images entering the independence step: ", n_img)
message("events: ", n_events, "; independent detections written: ", n_written)

## Detection-week labels, UTC against America/Vancouver ---------------------------------------
# The detection-week expression as each chapter writes it, from the line that matches it to
# the effort week.
week_expr <- function(chunks, label) {
  ch <- chunk(chunks, 'week_obs[i,as.character(tmp_stats$sp)]', label)
  m <- regmatches(ch$code, gregexpr("strftime\\(ind_dat\\$timestamp[^)]*\\)", ch$code))[[1]]
  if (length(m) != 1) stop(label, ": expected one detection-week strftime() in the weekly chunk, found ", length(m))
  m
}
ind <- env$ind_dat
label_diff <- function(expr_text) {
  e <- parse(text = expr_text)[[1]]
  set_tz("UTC"); utc <- eval(e, list(ind_dat = ind))
  set_tz("America/Vancouver"); van <- eval(e, list(ind_dat = ind))
  set_tz("UTC")
  sum(utc != van)
}
e12 <- week_expr(ch12, "ch 12")
e3 <- week_expr(ch3, "ch 3")
d12 <- label_diff(e12)
d3 <- label_diff(e3)
message("ch 12 detection week `", e12, "`: ", d12, " of ", n_written, " labels differ, Vancouver vs UTC")
message("ch 3  detection week `", e3, "`: ", d3, " of ", n_written, " labels differ, Vancouver vs UTC")

## The frames ch 12 builds, under each time zone ----------------------------------------------
frames <- function(z) {
  set_tz(z)
  fe <- list2env(as.list(env, all.names = TRUE), parent = globalenv())
  run(fe, paste0("analysis_frames (", z, ")"), "# Calculate the number of days at each site")
  set_tz("UTC")
  obs <- function(d) sum(as.matrix(d[, levels(fe$ind_dat$sp), drop = FALSE]), na.rm = TRUE)
  list(week_obs = fe$week_obs, totals = c(total = obs(fe$total_obs), monthly = obs(fe$mon_obs), weekly = obs(fe$week_obs)))
}
fu <- frames("UTC")
fv <- frames("America/Vancouver")
message("frame observation totals (total / monthly / weekly): UTC ", paste(fu$totals, collapse = " / "),
        "; Vancouver ", paste(fv$totals, collapse = " / "))
same_week <- identical(fu$week_obs, fv$week_obs)
message("weekly frame identical under UTC and Vancouver: ", same_week)

setwd(home)
unlink(work, recursive = TRUE)
if (is.na(old_tz)) Sys.unsetenv("TZ") else Sys.setenv(TZ = old_tz)

message(sprintf(
  "RESULT ref=%s sha=%s images=%d events=%d written=%d ch12_week_diff=%d ch3_week_diff=%d weekly_utc=%d weekly_vancouver=%d week_obs_identical=%s",
  ref, substr(sha, 1, 7), n_img, n_events, n_written, d12, d3, fu$totals[["weekly"]], fv$totals[["weekly"]], same_week))
