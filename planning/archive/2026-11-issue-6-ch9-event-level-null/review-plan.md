# Plan review — #6 (Plan agent, 2026-11-13)

Reviewed `task_plan.md` against `findings.md`, `09-activity.Rmd:140-240`, `block_null()` and the
log, PR 7's diff and `activity::compareCkern`'s source. Probe: `event_id` is column 33 of the raw
detections CSV, so it reaches `img_locs` through the join. **No blockers.**

| # | Kind | Finding | Disposition |
|---|---|---|---|
| 1 | Gap | The plan read obs 0.83 > null 0.76 as small-sample noise. Noise explains null(event) < null(image), not obs > null: obs is fitted to the same events and carries the same bias, so under H0 it is one draw from the null (here near its 90th percentile). `p` is one-sided (share of shuffles ≤ obs); 0.92 means no evidence of a difference, not "more alike". Drop ":224 size of any change looks modest". | Folded in: reading rewritten |
| 2 | Gap | `event_shuffle()`: keep the two-labels-per-event `stop()`; filter to the two labels inside; return named `observed`, `mean_null`, `p`, event counts; obs as `ovl4(fitact(a), fitact(b))` (= compareCkern's obs). Its null re-estimates bandwidth each rep, compareCkern's fixes it and resamples with replacement, so do not call it "compareCkern's null by event". | Folded in |
| 3 | Assumption | reps = 100 gives SE(p) ≈ 0.05: 0.44 / 0.92 safe for "well above 0.05". Species 0.78 vs 0.79 can flip direction with the seed: say "about the same". `ch9_12` / `ch9_16` unseeded, so the 0.96 moves: seed them or write "about 0.95". | Folded in: "about the same"; upstream chunks stay unseeded, prose "about 0.95" |
| 4 | Acceptance | "Agree in direction" is the wrong test. Use: both p > 0.05, null means within ±0.03 of 0.79 / 0.76, event counts exactly 562/119 and 87/254; a second seed. | Folded in (Phase 4) |
| 5 | Gap | `:181` keeps "(pNull<0.01)" as the image-level null's report, then points forward. Site sentence needs the Phase 2 count; "stricter still" is about the design, not a result. | Folded in; count 9 / 9 confirmed |
| 6 | Scope / Ordering | Reconcile undercounted: also `ch9_season_5` paragraph, `ch9_season_6` body + its "about 0.5"/"about a third" (seed 9), "swap the species in the chunk above", "On your own" pointer. Expect a conflict at `:224`. List in the PR body; make the signature fit the season case unchanged. | Folded in (Owed, Phase 5) |
| 7 | Reader | Comment the function line by line as PR 7 does; introduce p in one sentence before the first call; measure run time with `system.time` (two `fitact` with bandwidth estimation per rep, up to ~5,600 images). | Folded in |
