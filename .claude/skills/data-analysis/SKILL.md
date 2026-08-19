---
name: data-analysis
description: Turn experiment/eval result tables into verified, uncertainty-qualified findings plus a single stats.json that downstream charts and prose consume. Use when analyzing results data, computing the numbers for a report or one-pager, quantifying whether a claimed effect is real, decomposing a gap, or preparing findings from a metrics CSV/parquet — especially before writing any results document.
model: opus
---

# Data Analysis

The judgment layer between raw results and a written report: compute the quantitative backbone, pressure-test every candidate claim, and emit two artifacts that downstream consumers (chart scripts, report prose) treat as the single source of truth.

## Inputs

- The results table(s) (CSV/parquet) and the question being asked.
- If a data-discovery pass ran: its `profile.json` and `metrics-inventory.md` — read them first; the "available but unreported" inventory is the checklist of metrics to consider, and the data-quality notes are constraints (missing values, exclusions) the analysis must honor and disclose.

## Process

1. **Backbone first**, using `scripts/stats_helpers.py` (the single implementation of the bootstrap, contrasts, standardization, and the stats writer — never re-implement inline): `summary` for every grouping the report might use, and a distribution-shape look before trusting any mean — a skewed or zero-inflated measure changes what may be claimed.
2. **Pressure-test candidate findings** with the recipes in `references/analysis.md` — the named moves: hit/miss conditioning, paired CI on lifts, mix adjustment, distribution shape, stage decomposition. Apply whichever the claim's structure calls for; a claim that fails its own check is reported as absent or downgraded, not massaged.
3. **Emit `stats.json`** via `write_stats` — every number the report could show, with params recorded for regeneration (the contract is in `references/analysis.md`). One computation script produces it; nothing downstream recomputes or retypes a number.
4. **Emit `findings.md`** — ranked candidate findings in the format specified in `references/analysis.md`, each carrying its effect size, CI, n, robustness note, suggested visual, and a report / borderline / do-not-report verdict with the reason.

## Honesty rules (non-negotiable)

- Report effect sizes and CIs, not significance stars; test only what the report will actually claim.
- Conditioning on system behavior (e.g. retrieval hit/miss) is observational — say so wherever it appears.
- Disclose every adjustment, reweighting, and exclusion where its result is used.
- Never import a number the analysis did not compute (no statistics from memory, prior docs, or plausible-sounding priors).
- Small groups: omit subgroup marks below n=5; flag n<30 groups in findings; skewed measures report median beside mean.

## Dependencies

pandas, numpy; scipy optional (paired tests). Everything else is in-house — no external profiling or stats packages.
