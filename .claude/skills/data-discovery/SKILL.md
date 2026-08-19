---
name: data-discovery
description: Deterministic first look at a results dataset - schema and per-column profiling, data-quality checks, and an exhaustive metrics inventory including metrics that are available but not being reported. Use before analyzing or reporting on any results table, when receiving raw experiment output, when asked "what's in this data", or as the first phase of building a report from data.
model: opus
---

# Data Discovery

The deterministic layer that runs before any analysis or writing: profile what exists, check its quality, and enumerate every metric the data could support — especially the ones nobody asked about. No findings, no judgment about what matters; that belongs to `data-analysis`.

## Process

1. **Profile every provided table**: `python scripts/profile_data.py <table> discovery/profile.json` — shape, per-column types, missingness, uniqueness, numeric stats (mean/median/spread/quantiles, share at exactly 0 and exactly 1), categorical value counts. Read the printed summary and the JSON.
2. **Write `discovery/metrics-inventory.md`** with these sections:
   - **Columns** — every column, one line each: name, type, meaning (from the task context; write "unknown" rather than guessing), and role: identifier / grouping / metric / metadata.
   - **Available but unreported** (mandatory, even if empty): metrics present in the data or trivially derivable that the current ask/notes do not mention. This is the section that catches the question a teammate will ask later ("do we have grounding scores?"). Enumerate mechanically — every metric column not named in the ask, every pairwise arm delta, every conditioning split a boolean/threshold column enables.
   - **Derivable metrics** — combinations worth naming: per-item deltas between arm columns, rates from booleans, splits by threshold columns. Include a **shared-denominator grouping**: group every metric by what its denominator counts (the unit each one is a fraction of) and name any group with two or more members, noting whether those metrics measure ordered stages of one process. Such groups are the raw material for stage decomposition downstream and are easy to miss when metrics are read one column at a time.
   - **Absent but adjacent** (mandatory, even if empty) — metrics the task context implies the upstream system could measure but that are NOT in the provided tables (e.g. grounding of answers in retrieved chunks when answers and chunks exist upstream). One line each: what it is, that it is absent here, and what upstream export would enable it. This answers "why isn't X on the page" before anyone asks.
   - **Data quality** — missing values and exactly where they live, row counts reconciled against expectations from context, duplicate keys, out-of-range values, columns whose values contradict their described meaning. State each as a fact with counts, not a recommendation.
3. **Do not filter or fix anything.** Discovery describes; the analysis layer decides what to exclude and must disclose it.

## Output contract

- `discovery/profile.json` — the machine profile (script output).
- `discovery/metrics-inventory.md` — the five sections above.

Downstream, `data-analysis` treats the inventory as its checklist and the quality notes as constraints to honor and disclose.

## Dependencies

pandas + numpy only (pyarrow if parquet). The profiler is bundled — in-house, no external profiling packages.
