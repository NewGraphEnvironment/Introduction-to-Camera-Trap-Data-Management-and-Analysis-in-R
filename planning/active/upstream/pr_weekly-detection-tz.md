<!-- Upstream PR body, NOT opened. Open only if the author asks for it, after the course.
Base: WildCoLab master; head: NewGraphEnvironment:weekly-detection-tz (18165f5).
Title: Label detection weeks in UTC, as effort weeks are -->

Adds `tz = "UTC"` to the detection-week `strftime()` in the weekly frames of ch 12 (line 627) and ch 3 (line 1441), so detection weeks are labelled in the same zone as effort weeks, as ch 3's daily frame already does.

On the Los Amigos data in `data/raw_data/your_data/`, on a machine set to `America/Vancouver`:

| | Detections in a different week than under UTC | Weekly frame same as under UTC |
|---|---|---|
| Before (ch 12 as written, 831) | 35 | No |
| Before (with the ch 12 independence fix, 4,939) | 258 | No |
| After | 0 | Yes |

Claude Code helped find and test this. The commit credits Claude as co-author; happy to change that to an `Assisted-by` line or drop it, whichever suits your project.
