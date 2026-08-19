"""
Rasterize a PDF into vertical slice images for visual QA.
Read every slice after rendering; ship only what has been inspected.
With no outdir, slices go to a fresh temp directory (disposable — never
write QA slices next to the deliverables). A reused outdir is cleared of
its previous slice_*.png files first (in-process, no shell rm).

Usage: python qa_pdf.py page.pdf [outdir] [--scale 1.3] [--slice-px 1400]
"""
import argparse
import tempfile
from pathlib import Path

import fitz


def rasterize(pdf_path, outdir=None, scale=1.3, slice_px=1400):
    if outdir is None:
        outdir = Path(tempfile.mkdtemp(prefix="qa_slices_"))
    else:
        outdir = Path(outdir)
        outdir.mkdir(parents=True, exist_ok=True)
        for old in outdir.glob("slice_*.png"):
            old.unlink()
    doc = fitz.open(pdf_path)
    zoom = fitz.Matrix(scale, scale)
    slice_pts = slice_px / scale
    n = 0
    for page in doc:
        top = 0.0
        while top < page.rect.height:
            clip = fitz.Rect(0, top, page.rect.width,
                             min(top + slice_pts, page.rect.height))
            pix = page.get_pixmap(matrix=zoom, clip=clip)
            path = outdir / f"slice_{n:02d}.png"
            pix.save(path)
            print(path)
            top += slice_pts
            n += 1
    print(f"{n} slices")


def main():
    parser = argparse.ArgumentParser(description="PDF to raster slices for QA")
    parser.add_argument("pdf")
    parser.add_argument("outdir", nargs="?", default=None,
                        help="optional; defaults to a fresh temp directory")
    parser.add_argument("--scale", type=float, default=1.3)
    parser.add_argument("--slice-px", type=int, default=1400)
    args = parser.parse_args()
    rasterize(args.pdf, args.outdir, args.scale, args.slice_px)


if __name__ == "__main__":
    main()
