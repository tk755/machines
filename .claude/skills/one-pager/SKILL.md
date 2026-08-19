---
name: one-pager
description: Write and build a polished single-page technical report (a "one-pager") as self-contained HTML + a single tall PDF, in a specific house style with matplotlib charts, inline SVG diagrams, worked-example cards, and a mandatory visual QA loop. Use whenever the user asks for a one-pager, a results write-up, a report or summary page to share with a team, or wants experiment/eval results presented — even if they say "report", "summary", "presentation", or "doc" instead of "one-pager".
model: opus
---

# One-Pager Writer

Produce a single-page (tall-scroll) technical report: one self-contained HTML file plus a one-page PDF, in the house style defined by `references/style-guide.md`. The audience is technical (engineers, data scientists); the register is terse and quantitative.

This skill is also the driver of a pipeline: when handed raw results data, it runs discovery and analysis phases before writing; when the findings are already established, it skips straight to writing.

## Phases (driver logic)

Decide by what the inputs already contain:

- **Raw results data, findings not established** → run the full pipeline:
  1. A fresh subagent invokes the `data-discovery` skill on the data → `discovery/profile.json` + `discovery/metrics-inventory.md`.
  2. A fresh subagent invokes the `data-analysis` skill with the data, the question, and the discovery artifacts → `analysis/stats.json` + `analysis/findings.md`.
  3. Write the page (process below) from those artifacts: findings.md supplies the candidate story (respect its verdicts), stats.json supplies every number — prose and charts consume it; nothing is recomputed or retyped. If subagents are unavailable, run the same phases yourself in order, still producing the artifacts — they are the contract, not a formality.
- **Findings already established** (in the conversation, notes, or a prior analysis) → skip discovery/analysis and write directly; if a stats file exists, still treat it as the single source of numbers.
- **Partial** (data plus some known findings) → run discovery (cheap, catches unreported metrics), then analysis scoped to what is not yet established.

## Process

1. **Gather content first.** Collect the facts, numbers, data files, and example materials before touching style. Content decisions (which results, which examples, which sections) come from the user and the task context — the skill supplies how it looks, not what it says.

2. **Read `references/style-guide.md` in full.** It is the binding spec: typography, color semantics, layout components, diagram grammar, writing register, and output format. Everything below assumes it.

3. **Plan the document.** One visual per point; the visual leads and prose interprets after it. Documents carrying several findings open with the opener (per the style guide). Beyond that, let structure and flow come from the user's request and the content — a common shape (not mandatory) is opener → system/flow diagram → results charts → worked-example cards.

4. **Bind the palette** per the style guide's color precedence and binding rules, and write the bindings down before making any chart so every visual agrees. Check the spine actually shows as data — a page whose charts are mostly accent and gray means a breakout went missing.

5. **Build charts** via the `charts` skill (catalog + builders). Before building anything, write a chart plan: one line per figure — finding → chosen chart → why (a default fits, or what a specialist chart shows that the default cannot). Build only what the plan justifies. Chart PNGs go in an `assets/` directory sibling to the HTML.

6. **Build diagrams** as inline SVG per the style guide's diagram grammar (note its renderer caveat: every SVG color inline, templated from the palette).

7. **Write the HTML.** Single file; inline the whole of `assets/page.css` into one `<style>` block (adjusting tokens only if the document needs a deliberate deviation). Use the component classes it defines: `.chart`, `.diagram`, `.excard`, `.quote`, `.cap`, `h2 .num`, etc.

8. **Render the PDF**: `python scripts/render_pdf.py page.html page.pdf`. Fixed 11in width, height binary-searched until everything fits one page.

9. **QA loop (mandatory).** `python scripts/qa_pdf.py page.pdf` (with no output directory it writes slices to a fresh temp directory and prints the paths — disposable, nothing to clean up in the deliverable folder; never write QA slices next to the deliverables). Read every slice image and look: clipped text, broken SVG colors, overlapping chart labels, wrong fonts, oversized images, casing inconsistencies. Inline-SVG diagrams deserve extra suspicion — any text touching a box, arrow, or another label is a blocker; if you cannot tell at default scale, re-rasterize that region larger (`--scale 2.5`) and look again. Fix, re-render, re-inspect. Ship only what you have seen.

## Bundled files and sibling skills

- `references/style-guide.md` — the binding style spec. Read before writing.
- `assets/page.css` — design tokens + component CSS. Inline into the HTML.
- `scripts/render_pdf.py` — HTML → single tall PDF page (weasyprint).
- `scripts/qa_pdf.py` — PDF → raster slices for visual inspection (pymupdf).
- Sibling skills: `charts` (chart catalog + chart_style.py builders), `data-analysis` (stats.json + findings.md), `data-discovery` (profile + metrics inventory).

## Dependencies

Python: `matplotlib`, `weasyprint`, `pymupdf`. Fonts: Ubuntu Sans + Ubuntu Mono (Google Fonts if not installed); `chart_style.register_fonts()` finds them in common locations and falls back with a warning — a fallback font is a QA finding, not a silent pass. If the environment's default python lacks the packages, ask about or look for the project's environment (conda, venv) before installing anything.

## Scope notes

- The deliverable is HTML + PDF files on disk, not a chat message. File naming and folder conventions follow the style guide's output section unless the user has their own.
- If the user's project has established meanings for specific hues or a fixed example format, those bindings override step 4 — reuse them so sibling documents stay consistent.
- Slides, multi-page documents, and interactive dashboards are out of scope; if asked for those, this skill's style rules may still inform the design but the build process does not apply.
