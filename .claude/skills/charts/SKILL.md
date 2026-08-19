---
name: charts
description: Choose and build charts in the house data-visualization style (matplotlib) — chart-type selection by data relationship, reference constants, and reusable builders for stacked bars, dot/dumbbell comparisons, bar charts with confidence intervals, ECDFs, and annotated heatmaps. Use when making charts or figures for reports and one-pagers, when choosing which chart type fits a dataset, or when plotting results in the project's visual style.
model: opus
---

# Charts

A library skill: the house chart grammar and the code that implements it. Used standalone ("plot X in house style") and as the chart component of the `one-pager` report pipeline.

## Process

1. **Pick the chart from the data relationship, not from habit.** Read `references/charts.md` — it maps data situations to house chart types with when-to-use and when-not-to-use guidance, grounded in the graphical-perception literature. If the data situation genuinely fits none of the catalog types, say so and design deliberately rather than forcing a fit.
2. **Copy `assets/chart_style.py` next to your chart script and import it.** It carries the palette, fonts, marker constants, axis chrome, label nudging, legend bands, and a builder per catalog type. Call `register_fonts()` first. Numbers should come from a computed stats file (see `load_stats`), not be retyped by hand.
3. **Color by the precedence and binding rules** in the one-pager style guide's Color system (the single source for color semantics) — the catalog's "Series color" section carries the operative summary.
4. **Honor the caller responsibilities** listed in the catalog: titles, axis-title wording, n= labels, the n<5 omission rule, and the uncertainty and legend conventions.

## Files

- `references/charts.md` — the chart catalog: selection, per-type judgment rules, uncertainty and legend conventions.
- `assets/chart_style.py` — the executable constants: palette, fonts, chrome, and builders (`stacked_bars`, `dot_chart`, `bars`, `ecdf`, `heatmap`), plus `load_stats` for consuming a stats.json.

## Dependencies

matplotlib + numpy (pandas only if the caller already uses it). Fonts: Ubuntu Sans + Ubuntu Mono; `register_fonts()` warns on fallback — treat a fallback font as a defect to fix, not a pass.
