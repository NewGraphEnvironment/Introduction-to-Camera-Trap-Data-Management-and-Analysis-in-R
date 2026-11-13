<!-- Upstream PR body, NOT opened. Open only if the author asks for it.
Base: WildCoLab master; head: NewGraphEnvironment:ch12-independence-gap (8278ddc).
Title: Use ch 3's sort and gap in ch 12's independence step -->

As discussed: ch 12's independence step takes ch 3's two lines (chunk `ch3_56`), `arrange(deployment_id, sp, timestamp)` and `int_length(lag(timestamp) %--% timestamp)`. Without the old loop's `abs()`, the previous gap was negative for images in time order.

On the Los Amigos data in `data/raw_data/your_data/`:

| | Events | Independent detections written |
|---|---|---|
| Before | 852 | 831 |
| After | 5,027 | 4,939 |

Claude Code helped find and test this. The commit credits Claude as co-author; happy to change that to an `Assisted-by` line or drop it, whichever suits your project.
