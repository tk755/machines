"""
Render a one-pager HTML file as a single tall PDF page.
Fixed width; page height binary-searched until everything fits on one page.

Usage: python render_pdf.py page.html page.pdf [--width 11.0] [--margin 0.45]
"""
import argparse
import logging

logging.getLogger("weasyprint").setLevel(logging.ERROR)
from weasyprint import HTML, CSS


def single_page_pdf(html_path, pdf_path, width_in=11.0, margin_in=0.45):
    def render(h):
        css = CSS(string=f"@page {{ size: {width_in}in {h}in; margin: {margin_in}in }}")
        return HTML(filename=html_path).render(stylesheets=[css])

    lo, hi = 10.0, 120.0
    doc = render(hi)
    while len(doc.pages) > 1:
        hi *= 2
        doc = render(hi)
    best = doc
    for _ in range(10):
        mid = (lo + hi) / 2
        d = render(mid)
        if len(d.pages) == 1:
            hi, best = mid, d
        else:
            lo = mid
    best.write_pdf(pdf_path)
    print(f"{pdf_path}: 1 page, {hi:.1f}in tall")


def main():
    parser = argparse.ArgumentParser(description="HTML to single tall PDF page")
    parser.add_argument("html")
    parser.add_argument("pdf")
    parser.add_argument("--width", type=float, default=11.0)
    parser.add_argument("--margin", type=float, default=0.45)
    args = parser.parse_args()
    single_page_pdf(args.html, args.pdf, args.width, args.margin)


if __name__ == "__main__":
    main()
