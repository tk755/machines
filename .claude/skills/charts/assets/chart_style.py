"""
Matplotlib style constants and builders for house charts.
Copy next to the chart script and import; see references/charts.md for the
selection guidance and constants these implement.
"""
import json
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import numpy as np
from matplotlib import font_manager
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.lines as mlines
import matplotlib.pyplot as plt

PALETTE = {
    "ink": "#16202b", "muted": "#5b6876",
    "figbg": "#ffffff", "panel": "#ffffff", "grid": "#e9edf3", "spine": "#d4dbe4",
    "surface": "#f4f6f9",
    "data_green": "#34d399", "data_gold": "#ffc328", "data_blue": "#60a5fa",
    "data_violet": "#a78bfa", "data_teal": "#2dd4bf", "data_rose": "#fb7185",
    "ref_light": "#c0c9d3", "ref_dark": "#5d6b7c",
    "accent_warm": "#8c6d52", "deemph": "#aab3bf",
}

# one-off (unbound) series draw from here; bound hues are exclusive to their
# concept — see charts.md "Series color — bound vs unbound"
UNBOUND_POOL = ["data_violet", "data_teal", "data_rose"]
SANS = "Ubuntu Sans"
MONO = "Ubuntu Mono"

# marker sizes: diamond corner-to-corner ~ circle diameter, on chart and in legend
CIRCLE_S = 100
DIAMOND_S = 70
LEGEND_CIRCLE_MS = 8
LEGEND_DIAMOND_MS = 6.7

FONT_CANDIDATES = [
    "/usr/share/fonts/truetype/ubuntu/UbuntuSans[wdth,wght].ttf",
    "/usr/share/fonts/truetype/ubuntu/UbuntuMono[wght].ttf",
    str(Path.home() / ".fonts" / "UbuntuSans.ttf"),
    str(Path.home() / ".fonts" / "UbuntuMono.ttf"),
]


def load_stats(path):
    """Load the document's computed stats file; every plotted number comes from it."""
    return json.loads(Path(path).read_text())


def register_fonts(extra_paths=()):
    """Register the page fonts with matplotlib; warn on fallback."""
    for fp in [*FONT_CANDIDATES, *extra_paths]:
        if Path(fp).exists():
            font_manager.fontManager.addfont(fp)
    available = {f.name for f in font_manager.fontManager.ttflist}
    plt.rcParams["font.family"] = SANS if SANS in available else "sans-serif"
    if SANS not in available or MONO not in available:
        print(f"warning: {SANS}/{MONO} not found; charts will not match page fonts")


def style_axes(ax):
    """Panel background, bottom/left spines only, muted mono ticks."""
    ax.set_facecolor(PALETTE["panel"])
    for side in ("top", "right"):
        ax.spines[side].set_visible(False)
    for side in ("left", "bottom"):
        ax.spines[side].set_color(PALETTE["spine"])
    ax.tick_params(colors=PALETTE["muted"], labelsize=9)
    for lab in ax.get_xticklabels() + ax.get_yticklabels():
        lab.set_fontfamily(MONO)
    ax.set_axisbelow(True)


def set_title(ax, title):
    """13pt weight-600 left-aligned strict descriptive Title Case."""
    ax.set_title(title, loc="left", fontsize=13, fontweight="600",
                 color=PALETTE["ink"], pad=14, fontfamily=SANS)


def set_xlabel(ax, label):
    ax.set_xlabel(label, fontsize=9.5, color=PALETTE["muted"], fontfamily=SANS)


def save(fig, path):
    fig.savefig(path, dpi=170, facecolor=PALETTE["figbg"])
    plt.close(fig)
    print(path)


def legend_below(fig, handles, fig_h, rows=1, ncols=None):
    """
    Legend below the axes in a reserved band: 0.42in for 1-2 rows, 0.56in for 3.
    Two-column legends fill column-major (primary col 1, reference col 2).
    Returns the rect to pass to fig.tight_layout.
    """
    band = 0.56 if rows >= 3 else 0.42
    leg = fig.legend(handles=handles, loc="lower center",
                     ncols=ncols or len(handles), fontsize=8.5, frameon=False)
    for t in leg.get_texts():
        t.set_color(PALETTE["muted"])
    return (0, band / fig_h, 1, 1)


def circle_handle(label, color, is_open=False):
    if is_open:
        return mlines.Line2D([], [], markerfacecolor=PALETTE["panel"],
                             markeredgecolor=color, markeredgewidth=1.6,
                             color="none", marker="o", linestyle="none",
                             markersize=LEGEND_CIRCLE_MS, label=label)
    return mlines.Line2D([], [], color=color, marker="o", linestyle="none",
                         markersize=LEGEND_CIRCLE_MS, label=label)


def diamond_handle(label, color):
    return mlines.Line2D([], [], color=color, marker="D", linestyle="none",
                         markersize=LEGEND_DIAMOND_MS, label=label)


def square_handle(label, color):
    return mlines.Line2D([], [], color=color, marker="s", linestyle="none",
                         markersize=9, label=label)


def annotate_nudged(ax, yi, marks, merge=0.005, near=0.05):
    """
    Value labels 10pt above marks: 8pt mono muted; values within `merge`
    share one label; labels within `near` nudge +/-9pt apart.
    marks: [(value, label_or_None)]
    """
    labeled = sorted((v, lab) for v, lab in marks if lab)
    merged = []
    for v, lab in labeled:
        if merged and v - merged[-1][0] < merge:
            continue
        merged.append((v, lab))
    nudge = {}
    for (v1, _), (v2, _) in zip(merged, merged[1:]):
        if v2 - v1 < near:
            nudge[v1] = nudge.get(v1, 0) - 9
            nudge[v2] = nudge.get(v2, 0) + 9
    for v, lab in merged:
        ax.annotate(lab, (v, yi), textcoords="offset points",
                    xytext=(nudge.get(v, 0), 10), ha="center",
                    fontsize=8, color=PALETTE["muted"], fontfamily=MONO)


def ci_whisker(ax, x, y, lo, hi, horizontal=True):
    """Thin ink 95%-CI whisker through a mark (no caps wider than the mark)."""
    if horizontal:
        ax.plot([lo, hi], [y, y], color=PALETTE["ink"], linewidth=1.2,
                zorder=4, solid_capstyle="butt")
    else:
        ax.plot([x, x], [lo, hi], color=PALETTE["ink"], linewidth=1.2,
                zorder=4, solid_capstyle="butt")


def stacked_bars(rows, series, title, xlabel, path, label_min=9):
    """
    Stacked horizontal bar chart of count compositions.
    rows: [(label, {series_key: count})], top row first; "(n=...)" appended.
    series: [(key, color, legend_label)] in document series order; in-bar
    counts are always ink.
    """
    labels = [f"{name}\n(n={sum(cnt.values())})" for name, cnt in rows][::-1]
    counts = [cnt for _, cnt in rows][::-1]
    fig_h = 0.40 * len(rows) + 1.9
    fig, ax = plt.subplots(figsize=(8.2, fig_h))
    left = [0.0] * len(labels)
    handles = []
    for key, color, name in series:
        vals = [c.get(key, 0) for c in counts]
        ax.barh(labels, vals, left=left, color=color, height=0.68)
        handles.append(square_handle(name, color))
        for i, (v, l) in enumerate(zip(vals, left)):
            if v >= label_min:
                ax.text(l + v / 2, i, str(v), ha="center", va="center",
                        fontsize=8.5, color=PALETTE["ink"], fontweight="bold",
                        fontfamily=MONO)
        left = [l + v for l, v in zip(left, vals)]
    set_xlabel(ax, xlabel)
    set_title(ax, title)
    style_axes(ax)
    rect = legend_below(fig, handles, fig_h)
    fig.tight_layout(rect=rect)
    save(fig, path)


def dot_chart(groups, title, xlabel, path, legend_handles=None,
              legend_rows=1, legend_ncols=None, proportion=True):
    """
    Dot/dumbbell chart: rows of primary circles vs reference diamonds.
    groups: [(row_label, marks)] top row first, where marks is a list of
      dicts: {"v": value, "color": hex, "kind": "circle"|"diamond",
              "open": bool, "label": bool, "ci": (lo, hi) or None}
    Row labels should already carry their "(n=...)".
    Connector spans each row's min->max; labels follow the nudge/merge rules.
    Legend is one row by default; pass legend_ncols=2 ONLY for a logical
    primary/reference column split (never an arbitrary ragged wrap).
    """
    n = len(groups)
    fig_h = max(0.85 * n + 1.6, 3.2)
    fig, ax = plt.subplots(figsize=(8.2, fig_h))
    ys = list(range(n))[::-1]
    for yi, (_, marks) in zip(ys, groups):
        xs = [m["v"] for m in marks]
        if len(xs) > 1:
            ax.plot([min(xs), max(xs)], [yi, yi], color=PALETTE["grid"],
                    linewidth=2, zorder=1)
        for m in marks:
            if m.get("ci"):
                ci_whisker(ax, m["v"], yi, *m["ci"])
            if m.get("kind") == "diamond":
                ax.scatter([m["v"]], [yi], s=DIAMOND_S, color=m["color"],
                           marker="D", zorder=3)
            elif m.get("open"):
                ax.scatter([m["v"]], [yi], s=CIRCLE_S, facecolors=PALETTE["panel"],
                           edgecolors=m["color"], linewidths=1.8, zorder=3)
            else:
                ax.scatter([m["v"]], [yi], s=CIRCLE_S, color=m["color"], zorder=3)
        annotate_nudged(ax, yi, [(m["v"], f"{m['v']:.2f}" if m.get("label") else None)
                                 for m in marks])
    ax.set_yticks(ys, [g[0] for g in groups], fontsize=9.5)
    if proportion:
        ax.set_xlim(0, 1.02)
    ax.set_ylim(-0.7, n - 0.3)
    ax.grid(axis="x", color=PALETTE["grid"], linewidth=0.8)
    set_xlabel(ax, xlabel)
    set_title(ax, title)
    style_axes(ax)
    rect = (0, 0, 1, 1)
    if legend_handles:
        rect = legend_below(fig, legend_handles, fig_h, rows=legend_rows,
                            ncols=legend_ncols)
    fig.tight_layout(rect=rect)
    save(fig, path)


def bars(rows, title, ylabel, path, color=None, horizontal=False):
    """
    Plain bar chart for a few absolute magnitudes (k <= ~8), zero baseline.
    rows: [(label, value, ci_or_None)]; labels should carry "(n=...)".
    """
    color = color or PALETTE["ref_dark"]
    labels = [r[0] for r in rows]
    vals = [r[1] for r in rows]
    fig, ax = plt.subplots(figsize=(8.2, 3.4))
    if horizontal:
        ax.barh(labels[::-1], vals[::-1], color=color, height=0.62)
        for i, (_, v, ci) in enumerate(reversed(rows)):
            if ci:
                ci_whisker(ax, v, i, *ci)
            ax.annotate(f"{v:.2f}", (ci[1] if ci else v, i),
                        textcoords="offset points", xytext=(8, 0), va="center",
                        fontsize=8, color=PALETTE["muted"], fontfamily=MONO)
        ax.set_xlim(left=0)
        set_xlabel(ax, ylabel)
    else:
        ax.bar(labels, vals, color=color, width=0.62)
        for i, (_, v, ci) in enumerate(rows):
            if ci:
                ci_whisker(ax, i, v, *ci, horizontal=False)
            ax.annotate(f"{v:.2f}", (i, ci[1] if ci else v),
                        textcoords="offset points", xytext=(0, 6), ha="center",
                        fontsize=8, color=PALETTE["muted"], fontfamily=MONO)
        ax.set_ylim(bottom=0)
        ax.set_ylabel(ylabel, fontsize=9.5, color=PALETTE["muted"], fontfamily=SANS)
    set_title(ax, title)
    style_axes(ax)
    fig.tight_layout()
    save(fig, path)


def ecdf(series, title, xlabel, path, refs=(), legend_rows=1):
    """
    ECDF overlay comparing distributions without binning.
    series: [(label, values, color)]; refs: [(x, label)] dashed vertical rules.
    Zero-inflation: shares at exactly 0 are visible as the curve's y-intercept.
    """
    fig_h = 3.6
    fig, ax = plt.subplots(figsize=(8.2, fig_h))
    handles = []
    for label, values, color in series:
        x = np.sort(np.asarray(values))
        y = np.arange(1, len(x) + 1) / len(x)
        ax.step(x, y, where="post", color=color, linewidth=2)
        handles.append(mlines.Line2D([], [], color=color, linewidth=2, label=label))
    for rx, rlabel in refs:
        ax.axvline(rx, color=PALETTE["muted"], linewidth=1.2, linestyle="--")
        ax.annotate(rlabel, (rx, 1.0), textcoords="offset points", xytext=(4, -2),
                    fontsize=8, color=PALETTE["muted"], fontfamily=MONO, va="top")
    ax.set_ylim(0, 1.02)
    ax.set_ylabel("fraction of queries ≤ x", fontsize=9.5,
                  color=PALETTE["muted"], fontfamily=SANS)
    ax.grid(axis="both", color=PALETTE["grid"], linewidth=0.8)
    set_xlabel(ax, xlabel)
    set_title(ax, title)
    style_axes(ax)
    rect = legend_below(fig, handles, fig_h, rows=legend_rows)
    fig.tight_layout(rect=rect)
    save(fig, path)


HEAT_CMAP = LinearSegmentedColormap.from_list("house_blue",
                                              ["#ffffff", PALETTE["data_blue"]])


def heatmap(matrix, row_labels, col_labels, title, path, min_n=None, ns=None,
            vmin=0.0, vmax=1.0):
    """
    Annotated factor x factor heatmap: single-hue lightness-monotonic ramp,
    every cell annotated in ink; cells under min_n rendered surface-gray
    with an em-dash. matrix/ns: 2D lists (rows x cols); None = missing.
    Labels should carry "(n=...)".
    """
    m = np.array([[np.nan if v is None else v for v in row] for row in matrix],
                 dtype=float)
    n_rows, n_cols = m.shape
    fig_h = 0.55 * n_rows + 1.8
    fig, ax = plt.subplots(figsize=(8.2, fig_h))
    display = np.ma.masked_invalid(m.copy())
    if min_n is not None and ns is not None:
        for i in range(n_rows):
            for j in range(n_cols):
                if ns[i][j] is not None and ns[i][j] < min_n:
                    display[i, j] = np.ma.masked
    cmap = HEAT_CMAP.copy()
    cmap.set_bad(PALETTE["surface"])
    ax.imshow(display, cmap=cmap, vmin=vmin, vmax=vmax, aspect="auto")
    for i in range(n_rows):
        for j in range(n_cols):
            masked = display.mask[i, j] if np.ma.is_masked(display[i, j]) else False
            text = "—" if masked or np.isnan(m[i, j]) else f"{m[i, j]:.2f}"
            ax.text(j, i, text, ha="center", va="center", fontsize=9,
                    color=PALETTE["ink"], fontfamily=MONO)
    ax.set_xticks(range(n_cols), col_labels, fontsize=9)
    ax.set_yticks(range(n_rows), row_labels, fontsize=9)
    ax.tick_params(length=0)
    for side in ("top", "right", "left", "bottom"):
        ax.spines[side].set_visible(False)
    for lab in ax.get_xticklabels() + ax.get_yticklabels():
        lab.set_fontfamily(MONO)
        lab.set_color(PALETTE["muted"])
    set_title(ax, title)
    fig.tight_layout()
    save(fig, path)
