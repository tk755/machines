# Chart catalog

When to use each house chart type, and the judgment rules the builders cannot enforce. All sizes, colors, marker constants, label nudging, and legend geometry live in `assets/chart_style.py` — use its builders and never re-derive constants. Grounded in: Cleveland & McGill's graphical-perception ranking (position on a common scale decodes best, then length, then angle, then area, then color) [C&M 1984, JASA]; Wilke, *Fundamentals of Data Visualization*; the FT Visual Vocabulary; Few, *Show Me the Numbers*; Munzner, *Visualization Analysis and Design*.

## Selection

| Data situation | House chart | Notes |
|---|---|---|
| Part-to-whole counts across categories | **Stacked horizontal bars** | composition per row |
| Group means vs reference bounds (floor/ceiling) | **Dot/dumbbell** | the workhorse; position beats grouped bars [C&M] |
| Ranking / ordered comparison | **Dot/dumbbell** (ordered rows) | dot strip over ordered bars at density |
| A few absolute magnitudes (k ≤ ~8) | **Plain bars** | zero baseline mandatory |
| Change across an ordered axis (time, rounds, k) | **Line / slope** | slope chart for exactly two periods |
| Per-item joint view of two measures | **Scatter** | correlation/mechanism |
| Distribution shape or 2+ distributions | **ECDF** (histogram rarely) | usually an annotation, not a figure — see hierarchy |
| Factor × factor grid of a statistic | **Annotated heatmap** | only when the dot chart's cross-cut rule doesn't apply |
| Small matrix where exact values matter | **Table** | look-up, not pattern [Few] |

Never used: pie/donut (angle decodes poorly; stacked bar or table does the job), grouped bars beyond two series per group (crowds; use dot rows), dual axes, gauges/radials, 3D anything.

Hierarchy: **defaults** — dot/dumbbell for any group comparison, stacked bars for composition, plain bars for a single magnitude series — need no justification. Everything else is a **specialist chart**: used only when a finding cannot be carried by a default, with the chart plan stating what it shows that the default could not. Variety is not a reason. Two hard constraints:

- **Line marks require an ordered, continuous x** (time, rounds, k, dose) — a line asserts continuity categorical data does not have; the slope chart is the only categorical-adjacent exception.
- **Distribution facts are annotations by default.** Zero-inflation, skew, endpoint shares surface as caption facts or on-chart annotations; a distribution chart appears only when the distribution itself is the headline finding.

## Series color

Precedence and binding rules live in the one-pager style guide's Color system (single source). Operative summary: assign by narrative rank (spine → vivid hues, even where the spine is the row factor; primary measured series → warm accent; bounds → grays, dark = ceiling; dropped → deemphasis; one-offs → unused hues without binding), and never use ink as a data-mark color.

## Caller responsibilities (all charts)

The builders set geometry and chrome; the caller still owns:

- Titles: strict descriptive Title Case, never narrative claims.
- Axis titles name the measure only, never its range — the ticks carry the range.
- Every categorical row/group label carries "(n=…)"; subgroup marks use the subgroup n; omit a subgroup mark only when n < 5 (state in caption; never invent a stricter threshold).
- Proportions plot on the 0–1 axis; never truncate a bar axis.

## Per-type judgment rules

### Stacked horizontal bars — composition

- Segment order = the document's series order (headline series first); dropped/below-threshold segments in deemphasis gray, last.
- When rows differ greatly in total n and the comparison is the mix, normalize rows to 100% and keep raw counts as in-bar labels.
- Builder: `stacked_bars`.

### Dot/dumbbell — comparison against bounds

- Open vs filled variants of one shape+color distinguish two closely related metrics of one series (open = potential/input, filled = realized/output).
- **Reference bounds share the row with the series they bound.** When the document frames one series as measured and others as its floor/ceiling, the bounds are marks on the primary's row, never rows of their own. (Peer series with no primary/bound framing may each take a row — the rule follows the framing, not the series count.)
- **Overlapping marks are a layout defect, not a caption topic.** Make them readable — label nudge/merge, change the row factor, split the figure — never drop real data to tidy a layout, and never ship overlap with a caption explaining the overlap. A meaningful coincidence is a finding for the prose.
- When rows are one factor and a hue-bound second factor exists (≤3 levels), break the primary series into per-level marks in the bound hues, SHARING the row — a pooled mark hides the interaction, and splitting one level per row wastes what the hues already separate.
- Label only reference marks and the best primary mark per row.
- Builder: `dot_chart`.

### Plain bars — small-k magnitudes

- One series per chart; two only when paired and directly comparable — three or more means the dot chart was the right choice.
- Builder: `bars`.

### Line / slope — ordered trends

- 2px line in the series' bound hue; markers at observed points only (no smoothing through unobserved space); direct end-of-line labels over a legend when ≤4 series.
- Slope chart: endpoint labels with values; gray for series whose change is within noise.

### Scatter — per-item joint views

- Alpha ~0.55 when n > ~150 (overplotting honesty); shared-unit axes get a reference diagonal in grid color.
- Hue only for an already-bound category; otherwise the unbound default.
- A fitted line requires stating the fit method in the caption; never decoration through observational scatter.

### ECDF / histogram — distribution shape

- ECDF preferred (no bin parameter [Wilke]); reference thresholds as dashed vertical rules; when mass sits at exactly 0 or 1, label that share directly on the chart.
- Histogram only when the audience reads counts: Freedman–Diaconis bins; state bin width if the story depends on it.
- Builder: `ecdf`.

### Annotated heatmap — factor × factor

- Prefer the dot chart when one factor is hue-bound with ≤3 levels — the heatmap trades the bound hues away. Use it when both factors are unbound or levels are many.
- Single-hue lightness-monotonic ramp (builder default); never build sequential ramps from the warm accent or neutrals; diverging ramps only with a meaningful midpoint, stated in the caption.
- Ramp legend may be omitted when every cell is annotated.
- Builder: `heatmap` (annotates cells, masks n<5 as an em-dash).

### Tables — exact values

- For look-up rather than pattern [Few]: mono numerals right-aligned, 2-decimal proportions, header sentence case, no vertical rules, row shading only at ≥8 rows.

## Uncertainty

- **Default: no interval marks on charts.** The analysis computes CIs for every mean (they live in the stats file); charts show them only when uncertainty is load-bearing for a claim the page makes or the user asks. Whiskers fight multi-mark rows — mixed-hue rows are worth more than routine intervals.
- When shown: the stats file's seeded bootstrap CI, drawn by `ci_whisker` — never computed in the chart script; avoid on rows carrying more than one mark; the caption names the method once ("Whiskers: 95% bootstrap CI").
- Never significance stars; a contrast that matters gets its bracketed CI in prose (subject to the style guide's caption/prose CI rule).

## Legends

- Every multi-series chart carries its own in-figure legend; captions clarify but never substitute.
- One row by default. Two columns ONLY when the split is logical (primary col 1, reference col 2, column-major); never a ragged arbitrary wrap — one row, or columns with meaning.
- Labels are parallel phrases; drop the metric name when the axis title already names it. Geometry (band, marker sizes) is `legend_below`'s.
