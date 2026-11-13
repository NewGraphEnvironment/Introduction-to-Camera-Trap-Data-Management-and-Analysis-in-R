# Measure whether ch 9's year-round activity curves hide a seasonal change in daily timing, on
# the chapter's own Algar data, and how much the fixed `tz = -6` in `solartime()` matters.
#
# Usage, from the repository root, after ch 3 and ch 4 have written data/processed_data/:
#   Rscript newgraph/check_ch9_season.R 2>&1 | tee newgraph/logs/<yyyymmdd>_check_ch9_season.txt
#
# Data are read and joined as `09-activity.Rmd` does (chunks ch9_2, ch9_5, ch9_6), and solar
# time is computed once over all images, as the chapter does: `solartime()` anchors to the mean
# sunrise and sunset of the vector it is given, so subsetting first would move the axis.
#
# Seasons by month: winter Nov-Mar, summer May-Aug; Apr, Sep and Oct are left out of the
# seasonal comparisons. Time zone variants for `solartime()`:
#   -6   the chapter's value;
#   -7   MST all year (cameras that never change their clocks);
#   dst  -6 between the 2018 and 2019 DST changes, -7 outside them (cameras that do).
# The timestamps are used as stored in every variant: tz only places sunrise and sunset.
#
# It reports, per variant:
#   1. images, events and sites per species and season, and each species' season mix;
#   2. winter vs summer overlap (`compareCkern`) for deer and caribou, on images and on one
#      image per event (the event's first); on images against a null that shuffles season
#      labels across whole events; and on the core months (Dec-Feb vs Jun-Jul);
#   3. the share of images within 2 h of that day's sunrise and of its sunset, by clock time;
#   4. deer vs caribou, and deer HumanUse vs Offline, overlap pooled and within each season,
#      each also against the event-shuffle null.
# The pooled deer vs caribou and HumanUse vs Offline overlaps must reproduce the chapter's
# prose (0.78, 0.83) under tz = -6, or the run stops.
#
# Writes nothing into the checkout.

suppressPackageStartupMessages({
  library(activity)
  library(dplyr)
  library(lubridate)
})

det_file <- "data/processed_data/AlgarRestorationProject_raw_detections.csv"
loc_file <- "data/processed_data/AlgarRestorationProject_camera_locations_and_covariates.csv"
if (!file.exists("09-activity.Rmd")) stop("run from the repository root")
for (f in c(det_file, loc_file)) if (!file.exists(f)) stop("missing ", f, ": run ch 3 and ch 4 first")

seed <- 20261113
reps <- 200
set.seed(seed)

head_sha <- system2("git", c("rev-parse", "HEAD"), stdout = TRUE, stderr = FALSE)
ch9_blob <- system2("git", c("rev-parse", "HEAD:09-activity.Rmd"), stdout = TRUE, stderr = FALSE)
cat("check_ch9_season.R  run", format(Sys.time(), tz = "UTC", usetz = TRUE), "\n")
cat("checkout HEAD", head_sha, " 09-activity.Rmd blob", ch9_blob, "\n")
cat("R", as.character(getRversion()), " activity", as.character(packageVersion("activity")),
    " seed", seed, " compareCkern reps", reps, "\n")
for (f in c(det_file, loc_file)) {
  cat("md5", tools::md5sum(f), " mtime", format(file.mtime(f), tz = "UTC", usetz = TRUE), f, "\n")
}
cat("\n")

# As the chapter: read, parse as UTC, join the locations on their shared columns.
img  <- read.csv(det_file, header = TRUE)
img$timestamp <- ymd_hms(img$timestamp, tz = "UTC")
locs <- read.csv(loc_file)
img  <- suppressMessages(left_join(img, locs))
if (anyNA(img$timestamp) || anyNA(img$latitude) || anyNA(img$longitude)) {
  stop("missing timestamp or location after the join")
}

m <- month(img$timestamp)
img$season <- ifelse(m %in% c(11, 12, 1, 2, 3), "winter",
                     ifelse(m %in% 5:8, "summer", "shoulder"))

# DST in Alberta, as local wall-clock instants on the stored (UTC-labelled) clock.
dst_on <- (img$timestamp >= ymd_hms("2018-03-11 02:00:00", tz = "UTC") &
           img$timestamp <  ymd_hms("2018-11-04 02:00:00", tz = "UTC")) |
          (img$timestamp >= ymd_hms("2019-03-10 02:00:00", tz = "UTC") &
           img$timestamp <  ymd_hms("2019-11-03 02:00:00", tz = "UTC"))
variants <- list(`-6` = rep(-6, nrow(img)), `-7` = rep(-7, nrow(img)),
                 dst = ifelse(dst_on, -6, -7))

# A tz vector must give each row the sunrise a single-value call gives it.
sun_vec <- activity:::get_suntimes(img$timestamp, img$latitude, img$longitude, variants$dst)
for (z in c(-6, -7)) {
  i <- which(variants$dst == z)
  sun_one <- activity:::get_suntimes(img$timestamp[i], img$latitude[i], img$longitude[i], z)
  if (!isTRUE(all.equal(sun_vec$sunrise[i], sun_one$sunrise))) stop("tz vector not applied per row")
}
cat("guard: a tz vector gives each row its single-value sunrise\n")

sp <- c(deer = "Odocoileus.virginianus", caribou = "Rangifer.tarandus")

# ---- 1. sample sizes (independent of tz) ----
cat("== 1. Images / events / sites by season ==\n")
for (nm in names(sp)) {
  x <- img[img$sp == sp[[nm]], ]
  tab <- sapply(c("winter", "summer", "shoulder"), function(s) {
    y <- x[x$season == s, ]
    c(images = nrow(y), events = length(unique(y$event_id)), sites = length(unique(y$placename)))
  })
  cat(nm, "\n"); print(tab)
  cat("  season mix of images (%):",
      paste(names(tab[1, ]), round(100 * tab[1, ] / sum(tab[1, ])), sep = " ", collapse = ", "), "\n")
}
x <- img[img$sp == sp[["deer"]], ]
cat("deer images by feature_type x season\n"); print(table(x$feature_type, x$season))
cat("\n")

# One image per event: its first.
first_of_event <- function(d) {
  d <- d[order(d$event_id, d$timestamp), ]
  d[!duplicated(d$event_id), ]
}

fit <- function(v) fitact(v, sample = "none", show = FALSE)
overlap <- function(a, b) {
  r <- compareCkern(fit(a), fit(b), reps = reps)
  sprintf("obs %.2f  null %.2f  pNull %.3f  (n %d vs %d)", r[["obs"]], r[["null"]], r[["pNull"]],
          length(a), length(b))
}
obs_only <- function(a, b) unname(ovl4(fit(a), fit(b)))

# compareCkern's null resamples single images, but images come in events. This null shuffles
# a label (`col`: season, feature type or species) across events, keeping each event's images
# together, so it also carries the small-sample bias of a curve fitted to few events. Every
# event has one label: one month, one site, one species.
block_null <- function(x, a = "winter", b = "summer", col = "season") {
  x <- x[x[[col]] %in% c(a, b), ]
  ev <- x[!duplicated(x$event_id), c("event_id", col)]
  lab <- x[[col]]
  if (any(ev[[col]][match(x$event_id, ev$event_id)] != lab)) stop("an event has two ", col, " labels")
  obs <- obs_only(x$solar[lab == a], x$solar[lab == b])
  null <- replicate(reps, {
    s <- sample(ev[[col]])[match(x$event_id, ev$event_id)]
    obs_only(x$solar[s == a], x$solar[s == b])
  })
  sprintf("obs %.2f  event-shuffle null %.2f (5th pct %.2f)  p %.3f  (%d vs %d events)",
          obs, mean(null), quantile(null, 0.05), mean(null <= obs),
          sum(ev[[col]] == a), sum(ev[[col]] == b))
}

# Clock-time distance (hours, circular) from x to y.
hdist <- function(x, y) { d <- abs(x - y) %% 24; pmin(d, 24 - d) }

solar_by_variant <- list()
for (v in names(variants)) {
  tz <- variants[[v]]
  st <- solartime(img$timestamp, img$latitude, img$longitude, tz = tz,
                  format = "%Y-%m-%d %H:%M:%S")
  solar_by_variant[[v]] <- st$solar
  sun <- activity:::get_suntimes(img$timestamp, img$latitude, img$longitude, tz)
  clock_h <- st$clock * 12 / pi
  d <- img
  d$solar <- st$solar
  d$near_rise <- hdist(clock_h, sun$sunrise) <= 2
  d$near_set  <- hdist(clock_h, sun$sunset)  <= 2

  cat("================ tz variant:", v, "================\n")

  cat("== 2. Winter vs summer overlap ==\n")
  for (nm in names(sp)) {
    x <- d[d$sp == sp[[nm]], ]
    e <- first_of_event(x)
    cat(sprintf("%-8s images: %s\n", nm,
                overlap(x$solar[x$season == "winter"], x$solar[x$season == "summer"])))
    cat(sprintf("%-8s events: %s\n", nm,
                overlap(e$solar[e$season == "winter"], e$solar[e$season == "summer"])))
    cat(sprintf("%-8s images, events kept whole: %s\n", nm, block_null(x)))
    core <- x
    core$season <- ifelse(month(core$timestamp) %in% c(12, 1, 2), "winter",
                          ifelse(month(core$timestamp) %in% 6:7, "summer", "other"))
    cat(sprintf("%-8s core months (Dec-Feb vs Jun-Jul): %s\n", nm,
                overlap(core$solar[core$season == "winter"], core$solar[core$season == "summer"])))
  }

  cat("== 3. Share of images within 2 h of sunrise / sunset (clock time) ==\n")
  for (nm in names(sp)) {
    x <- d[d$sp == sp[[nm]], ]
    for (s in c("winter", "summer")) {
      y <- x[x$season == s, ]
      cat(sprintf("%-8s %-7s sunrise %3.0f%%  sunset %3.0f%%  (n %d)\n", nm, s,
                  100 * mean(y$near_rise), 100 * mean(y$near_set), nrow(y)))
    }
  }

  cat("== 4. Species and feature-type comparisons, pooled and by season ==\n")
  deer <- d[d$sp == sp[["deer"]], ]
  cari <- d[d$sp == sp[["caribou"]], ]
  pooled_sp <- obs_only(deer$solar, cari$solar)
  hu <- deer[deer$feature_type == "HumanUse", ]
  off <- deer[deer$feature_type == "Offline", ]
  pooled_ft <- obs_only(hu$solar, off$solar)
  both <- rbind(deer, cari)
  hu_off <- rbind(hu, off)
  cat("deer vs caribou, pooled:     ", overlap(deer$solar, cari$solar), "\n")
  cat("  events kept whole:         ", block_null(both, sp[["deer"]], sp[["caribou"]], "sp"), "\n")
  for (s in c("winter", "summer")) {
    cat(sprintf("deer vs caribou, %-7s:     %s\n", s,
                overlap(deer$solar[deer$season == s], cari$solar[cari$season == s])))
    cat(sprintf("  events kept whole:          %s\n",
                block_null(both[both$season == s, ], sp[["deer"]], sp[["caribou"]], "sp")))
  }
  cat("HumanUse vs Offline, pooled: ", overlap(hu$solar, off$solar), "\n")
  cat("  events kept whole:         ", block_null(hu_off, "HumanUse", "Offline", "feature_type"), "\n")
  for (s in c("winter", "summer")) {
    cat(sprintf("HumanUse vs Offline, %-7s: %s\n", s,
                overlap(hu$solar[hu$season == s], off$solar[off$season == s])))
    cat(sprintf("  events kept whole:          %s\n",
                block_null(hu_off[hu_off$season == s, ], "HumanUse", "Offline", "feature_type")))
  }
  if (v == "-6") {
    if (abs(pooled_sp - 0.78) > 0.005 || abs(pooled_ft - 0.83) > 0.005) {
      stop(sprintf("pooled overlaps %.3f / %.3f do not reproduce the chapter's 0.78 / 0.83",
                   pooled_sp, pooled_ft))
    }
    cat("guard: pooled overlaps reproduce the chapter's 0.78 and 0.83\n")
  }
  cat("\n")
}

# The stored clock times do not move with tz; sunrise and sunset do. So each variant places
# the detections differently relative to the sun, and solar time differs between variants.
dd <- function(a, b) { x <- abs(a - b) %% (2 * pi); max(pmin(x, 2 * pi - x)) }
cat("== Solar time differences between variants (max, radians; 2*pi = 24 h) ==\n")
cat(sprintf("-6 vs -7: %.2e\n", dd(solar_by_variant[["-6"]], solar_by_variant[["-7"]])))
cat(sprintf("-6 vs dst: %.3f (%.2f h)\n", dd(solar_by_variant[["-6"]], solar_by_variant[["dst"]]),
            dd(solar_by_variant[["-6"]], solar_by_variant[["dst"]]) * 12 / pi))
cat("images in the DST period:", sum(dst_on), "of", nrow(img), "\n")
