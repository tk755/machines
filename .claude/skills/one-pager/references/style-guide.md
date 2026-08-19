# One-pager style guide

The STYLE specification for technical one-pagers: typography, color, layout, diagram, and writing rules. It encodes no document structure and no project content — any two reports following it should look like siblings. Executable carriers: `assets/page.css` (page tokens + components, canonical for all hex values) and the charts skill's `chart_style.py` (chart constants). This file states only what prose must state; anything a carrier enforces is not repeated here.

## Page & typography

- Single-file HTML page; all styling in one `<style>` block driven by CSS custom properties (tokens); page content column max-width 960px, padding 40px 32px 56px, background white, base line-height 1.5.
- Two typefaces only:
  - **Sans** (prose, headings, chart/axis titles): Ubuntu Sans — or any humanist sans available to both the HTML renderer and matplotlib.
  - **Mono** (ALL data-adjacent text: figure captions, meta lines, tick labels, in-chart value labels, verbatim/OCR quote blocks, counts): Ubuntu Mono, or the matching mono of the chosen sans. Both must be registered with matplotlib (`font_manager.addfont`) so chart text matches page text. Fonts are obtainable from Google Fonts if not system-installed.
- Type scale:
  | Element | Size / weight | Notes |
  |---|---|---|
  | h1 title | 28px / 700 | letter-spacing −0.015em |
  | subtitle | 13.5px / 400 | muted color, directly under h1 |
  | h2 section | 18px / 700 | 40px above, 12px below |
  | body prose | 14px / 400 | |
  | card note | 13px / 400 | |
  | caption / meta | 12px / 400 | mono, muted |
  | evidence quote | 12px (10.5px if verbatim/OCR mono) | |
  | micro-label | 10.5px uppercase, letter-spacing 0.05em, muted | |
- **Title**: "<Topic>: <Deliverable>" (e.g. "Image Queries: Tier-Stratified Retrieval Evaluation"). **Subtitle**: byline only — "Author · Month D, YYYY" separated by `·`. No abstract, no logos, no footer.
- Casing: h1, h2, and chart titles in Title Case; captions, legends, axis labels, meta lines, and bullets in sentence case. Domain terms that are defined lowercase stay lowercase everywhere, even at sentence start.
- Section headings are numbered with a chip: dark-ink rounded tag (radius 6, padding 2px 8px, 12px mono, white numeral) followed by the Title Case heading text.
- Section headings are short noun phrases that name the section's analytical content ("Failure Decomposition", "Pipeline & Certification") — not generic containers ("Results", "Discussion") and not narrative claims.

## Color system

Hex values live in `assets/page.css` (canonical for the page) and are mirrored in the charts skill's `chart_style.py` PALETTE (matplotlib cannot read CSS) — change both together; this file never restates them.

Token roles:

- **Neutrals** (chrome — never used to encode data): bg, ink (headings, body, chips, diagram titles), muted (subtitle, captions, ticks, legends), secondary text (diagram body), card border, line/border (diagram arrows, decision nodes), surface (tinted boxes), quote bg/border.
- **Data palette** (data marks/fills only, never chrome): data-green / data-gold / data-blue (each with a tint bg for diagram outcome cards), data-violet / data-teal / data-rose, ref-light / ref-dark, accent-warm, deemphasis.

Precedence — which concept earns which colors. Salience tracks narrative rank, strongest first:

1. **The spine** — the factor the document's findings are organized around, the one recurring in section titles and takeaways — takes the vivid data hues. Its hues follow it onto every chart where it appears, *including* charts where it is also the row factor: repeating the hue on the marks there is redundant encoding on purpose, and it is what ties the flagship chart to the rest of the document.
2. **The primary measured series** — the thing being evaluated, present on most charts — takes the warm accent.
3. **Reference bounds** take the neutral grays (dark = ceiling, light = floor).
4. **Dropped / below-threshold** takes the deemphasis gray.
5. **One-off concepts** draw from the unused data hues, per the binding rules below.

Warm accent and grays sit at the bottom of that ladder by design. If a document's charts are mostly accent and gray, the spine is probably being named in row labels but never shown as data — check that before accepting the palette.

Binding rules — bound vs unbound:
- A hue becomes **bound** when its concept appears on more than one chart or diagram: bound hues belong to that concept exclusively for the whole document and are never reused for anything else (the palette teaches itself).
- A concept that appears on only ONE chart does not bind its color. Unbound series draw from the data palette's unused hues (violet, teal, rose, or whichever of green/gold/blue are not bound in this document); the same pool color may be reused by a different one-off concept on a DIFFERENT chart. Within one chart, overlaid series always take distinct colors.
- If a previously one-off concept later recurs on another chart, its color becomes bound to it — check before reusing.
- Reference/bound series use the neutral grays, with **dark = the upper/ceiling series and light = the floor** in any floor/ceiling pair.
- Derived/secondary measurement families that recur across the document take the warm accent, not a new hue.
- Below-threshold / dropped segments use the deemphasis gray.
- Ink is chrome, never a data-mark color.
- In-bar text is always ink, never white.

## Layout & components

- **Every visual element sits in a card**: 1px card-border, radius 10, padding 14–16px, vertical margin 16px — charts, diagrams, and exhibit cards all get identical treatment.
- **The opener** (for documents carrying several findings) — three parts before the first numbered section, none of them a section:
  1. Framing paragraph: 1–3 sentences that open with the subject itself, not self-reference — never "This page…", and not "This document <verbs>…" either; jump straight in ("Five corpora produced … , of which …"). If self-reference is unavoidable mid-paragraph, "this document" is the term. Never internal process terms (sprint, workstream, iteration, PR) — translate them into what the work IS. No definition callouts or quote blocks here — definitions belong where their machinery is introduced.
  2. **Key Takeaways card**: a bordered card titled "Key Takeaways", styled exactly like a KPI micro-label (10.5px uppercase letterspaced muted), holding at most 3 takeaways: bold claim, period, explanation ("**The gap is a cliff, not a slope.** The measured value halves at …").
  3. KPI strip below the takeaways: one card per narrative-crucial quantity — often 2–3, never more than 4. Two card kinds only: a headline *quantity* (count or ratio: "594 / 749") or a *comparison* compressed to a single signed percentage in the pos/neg accent ("−52%", red, computed from the two group values) — never "A vs B" pairs, arrow chains, or anything that must be parsed. Uppercase micro-label naming the insight; one-line 12px muted note completing the thought ("79% of emitted; 155 dropped at the image floor"). The pos/neg accents exist ONLY here — never on data marks. No orphan numbers: every number in the opener appears on a chart or in a caption below (the underlying values of a percentage card count).
- **Figure captions**: every chart/diagram is numbered ("**Figure N.**", bold prefix) in 12px mono muted, placed under the card. Captions carry ONLY what the reader cannot get by looking: encoding notes, exclusions, and epistemic caveats that change how a number should be read ("swings at these sample sizes are sampling noise, not corpus signal"; "hit/miss subsets are observational, not randomized"). Anything visible on the chart stays out — e.g. sample sizes already in the row labels, uncertainty already drawn as whiskers, marks that visibly coincide. A caveat earns its place by telling the reader to read a number differently, never by narrating the number. Compress ruthlessly: an omission is named, not justified ("<category> omitted, n=4" — the threshold rule needs no restating, and the roster of omitted items is never enumerated). Captions are prose sentences — capitalize sentence starts; only defined lowercase terms keep their lowercase. No test statistics or named effect sizes (p-values, Cramér's V, Wilcoxon…) anywhere on the page unless the user asks. CIs are likewise absent from captions and prose unless the user asked for them or the interval IS the point of a headline finding (a lift whose reality is the claim); all intervals live on in the analysis artifacts. Story interpretation goes in prose.
- **The visual leads** — prose interprets after it, one paragraph per visual. Body prose never announces figures ("Figure N shows…"); the caption carries the figure number. The interpretation paragraph may open with its key finding clause in bold — the claim, not a headline.
- **One chart per figure** — no multi-panel figures; each chart gets its own card, number, and caption.
- **Bullets**: one concept per bullet, bold lead term + em-dash definition; configuration details inline, never nested deeper than one level.
- **Parallel definitions live in bullets**: whenever two or more sibling concepts are defined (tiers, arms, metrics), they get the bulleted bold-term + em-dash treatment — never woven through a prose sentence. A single definition, or definitions of unrelated concepts, may stay in prose. Three rules govern them:
  - **Introduce the group first.** One sentence above the bullets says what is being defined and why it matters here ("Three quantities trace one item through the pipeline."). Bullets never appear cold.
  - **Define at first use.** A term is defined in the section where the document first uses it — never staged in advance in an earlier section, and never left undefined until later.
  - **Bold the term, not a description of it.** The bold lead is the canonical name the rest of the document uses, with the explanation after the dash. Putting a descriptive paraphrase in the bold slot and the real term after the dash ("**items surfaced** — recall@k, the fraction…") inverts this and buries the name the reader needs.
- **Punctuation split — findings vs definitions**: a bold *claim* is followed by a period and its explanation ("**The tier gradient is real.** The agent falls…") — in takeaways and interpretation paragraphs alike. The em-dash pattern is reserved for bold *terms* being defined.
- **Quote blocks** (verbatim evidence/source excerpts): light background, 3px left border, radius 3; verbatim machine text in mono at 10.5px; preceded by an uppercase micro-label naming the source channel.
- **Exhibit cards** (worked examples): bold quoted title line; a 12px mono meta line of `·`-separated facets; the exhibit image(s); labeled quote blocks; and a closing in-card note (13px) separated by a 1px top divider that explains the takeaway. Image layout by aspect ratio: portrait/square → side-by-side with text (image ~40% width); landscape → full width with text below; paired documents → two-column table. Images render at modest size — cap rendered height around 4in, cropping to the relevant region rather than scaling a whole figure up. Images always on white with the card border.

## Charts

Everything chart-side — selection, per-type judgment rules, uncertainty, legends, and the executable constants — lives in the `charts` skill (`references/charts.md` + `assets/chart_style.py`). That catalog is the sole authority; nothing chart-specific is restated here.

## Diagrams (inline SVG)

- Flow diagrams draw the **single-item decision path, not the system inventory**: what happens to one item as it flows through. Put real quantities on outcome nodes. Reuse the document's data palette so the diagram teaches the charts' colors.
- Grammar: uppercase letter-spaced stage captions (10px, muted) across the top; rectangular input/process boxes (rx 8, 1.4px borders — inputs on surface tint, processes on white); decision nodes as pills (rx = half height, line/border color); outcome cards with data-tint fill + 2.2px data-color border; dropped/terminated outcomes dashed deemphasis gray; arrows 1.6px with small triangle markers and 10px yes/no labels.
- Decision pills ask plain-language questions readable without a legend ("Also answerable from extracted text alone?"), never symbol shorthand ("A ≥ 0.75?").
- Text inside nodes: 12.5px/600 titles, 11px secondary lines.
- Renderer caveat: print engines (e.g. weasyprint) do not cascade page CSS into inline SVG — every SVG color must be an inline attribute. Template the SVG from the token palette.

## Writing register

Audience: technical (engineers / data scientists). Terse declarative prose; no colloquialisms, metaphors, or AI-ish narration. Quantitative claims with the minimum number of figures — only numbers that prove a point, preferably readable off the adjacent visual. Chart first, interpretation after. Reuse defined terms exactly — never coin synonyms or variants for a term the document defines. Do not define ad-hoc symbols (A, B, C) as shorthand for concepts; name things in words, and translate any symbols a source system uses into words on the page. No implementation details in the document (variant configs, internal analyses belong in an internal report). Concepts that require machinery beyond what the visuals show do not belong on the page.

## Output format

One self-contained HTML file + a single tall PDF page (11in wide, 0.45in margins, height fit to content); assets (chart PNGs, images) in a sibling `assets/` directory; file naming date-prefixed inside a dated folder (`{M-D-YYYY}/{M-D-YYYY}-one-pager.{html,pdf}`). The build and QA process — including the mandatory visual QA loop — is owned by the one-pager SKILL.md and its `scripts/`.
