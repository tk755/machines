# Analysis recipes

The named moves, the artifact contracts, and the machinery. Format follows the when-to-use-table style because it transfers; apply moves by the structure of the claim, not ritually.

What statistics may appear on the page is owned by the one-pager style guide (figure-caption rules); the machinery below feeds findings.md and stats.json, not page text.

## When to use which move

| The claim looks like | Move | What it prevents |
|---|---|---|
| "The loss comes from stage X" | **Hit/miss conditioning** | blaming the wrong stage |
| "A beats B (by d)" | **Paired CI on the lift** | reporting noise as signal |
| "Group G is better/worse than group H" (groups differ in composition) | **Mix adjustment** | Simpson's-paradox rankings |
| Any mean-based story | **Distribution shape** | a mean that describes nobody |
| "Where does the loss happen?" / "is it X or Y?" | **Stage decomposition** | arguing about stages with no accounting |

## Move 1 — hit/miss conditioning

Localize a mechanism by splitting the outcome on whether an upstream stage succeeded (e.g. answer completeness conditioned on whether retrieval surfaced the gold chunks). Report the conditional means with their n's; the gap that *survives* upstream success is the downstream loss. Always state that conditioning is on the system's own behavior — observational subsets, not randomized arms — and never phrase the result causally ("fixing retrieval would yield…" is not licensed; "queries where retrieval succeeded still score only…" is).

## Move 2 — paired CI on lifts

Any claimed lift ("A beats B by d") between arms measured on the same items is a paired difference: `paired_delta_ci` on the per-item deltas, reporting d with its 95% CI and n. A CI touching 0 downgrades the claim to "no reliable difference". A paired Wilcoxon signed-rank (scipy) may back the CI as a secondary check; report the CI either way — it, not a p-value, is what the page shows. When arms are on different items (unpaired), say so and bootstrap the difference of group means instead.

## Move 3 — mix adjustment

When comparing groups whose composition differs on a factor that drives the outcome (corpora with different tier mixes), report BOTH: the raw group means and a standardized comparison — reweight each group's factor-level means to the pooled factor distribution (direct standardization), or simply present the factor-level breakdown and let the reader see the mix. If the ranking changes under adjustment, the raw ranking is not a finding. Disclose the reweighting wherever the adjusted number appears.

## Move 4 — distribution shape

Before any mean-based claim: median beside mean (a gap flags skew), share of observations at exactly 0 and exactly 1 (zero/ceiling inflation), and an ECDF glance per key group. If mass concentrates at 0 ("half the attempts score exactly 0"), that share IS the finding — report it directly rather than letting it hide inside a mean. Skewed measures report median beside mean everywhere they appear.

## Move 5 — stage decomposition on a shared denominator

**Precondition — both halves required:** two or more metrics are fractions of the *same underlying unit set*, AND the stages they measure are genuinely ordered, so a unit must survive the earlier stage to be counted at the later one. When both hold, successive differences decompose the total shortfall into stage-attributable losses that read as one part-to-whole. When only the first holds — metrics sharing units but measuring unordered or overlapping things — differencing them is arithmetic without meaning. Do not force a funnel onto data that has none; the move is high-value where it applies and noise where it does not.

Check for it mechanically before writing findings: list every metric, group them by what its denominator counts, and for any group with two or more members, ask whether the stages nest. If they do, order and difference them. The shared units make the subtraction meaningful; the nesting makes it a funnel.

Report it as an **accounting decomposition, not a measurement identity**, whenever the stages are measured by different instruments — say so in one clause. Pair it with Move 1: conditioning on the upstream stage succeeding tells you what the downstream stage would still lose, which bounds what fixing the upstream stage could buy. Keep that observational.

Worked shape (any domain): of every unit that could have been recovered, X% never reached stage 2, a further Y% reached stage 2 but not stage 3, and Z% survived — where X + Y + Z = 1 by construction.

## Machinery

`scripts/stats_helpers.py` is the single implementation — `boot_ci`, `paired_delta_ci`, `standardize` (direct standardization for Move 3), `summary` (the standard per-group entry), `contrast`, and `write_stats`. Import it; never re-implement these inline. One seed per document, recorded in params.

## stats.json contract

One computation script emits every number the report could show; charts and prose read this file, and nothing downstream recomputes or retypes. Written via `write_stats(path, groups, contrasts, params)`:

- `params` — source path, seed, n_boot, filters/exclusions, row counts (total and used). Mandatory; this is what makes the file regenerable.
- `groups` — self-describing keys (`<grouping>.<group>.<metric>`), each entry the `summary` shape: mean, ci, median, n, endpoint shares. Every entry carries its n (`write_stats` enforces this).
- `contrasts` — named lifts from `contrast`: delta, ci, n, paired flag.

Values the analysis rejected are not deleted — they stay, and findings.md records why they are not reportable.

## findings.md format

Ranked, most load-bearing first. Each finding:

```markdown
## F1. <one-sentence claim, plain words>
- effect: <the number(s) with CI and n, from stats.json keys>
- robustness: <which moves were applied and what they showed;
  caveats (observational conditioning, adjustment, skew)>
- visual: <suggested chart type from the charts catalog + what it shows>
- verdict: report | borderline | do-not-report — <reason>
```

Borderline and do-not-report findings stay in the file: the writer (or the user) sees what was considered and rejected, not only the survivors.
