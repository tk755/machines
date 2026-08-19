"""
Deterministic dataset profiler: schema, missingness, numeric and
categorical summaries, duplicate keys. Emits JSON and prints a summary.

Usage: python profile_data.py <table.csv|.parquet> <out.json> [--key COL]
"""
import argparse
import json
from pathlib import Path

import numpy as np
import pandas as pd

TOP_K = 12


def load(path):
    path = Path(path)
    if path.suffix == ".parquet":
        return pd.read_parquet(path)
    return pd.read_csv(path)


def profile_column(s):
    info = {
        "dtype": str(s.dtype),
        "missing": int(s.isna().sum()),
        "unique": int(s.nunique(dropna=True)),
    }
    if pd.api.types.is_numeric_dtype(s):
        v = s.dropna().astype(float)
        if len(v):
            q = v.quantile([0.25, 0.5, 0.75])
            info.update({
                "mean": round(float(v.mean()), 4),
                "median": round(float(q[0.5]), 4),
                "std": round(float(v.std()), 4),
                "min": round(float(v.min()), 4),
                "p25": round(float(q[0.25]), 4),
                "p75": round(float(q[0.75]), 4),
                "max": round(float(v.max()), 4),
                "share_exact_0": round(float((v == 0).mean()), 4),
                "share_exact_1": round(float((v == 1).mean()), 4),
            })
    else:
        counts = s.value_counts(dropna=True)
        info["top_values"] = {str(k): int(c) for k, c in counts.head(TOP_K).items()}
        if len(counts) > TOP_K:
            info["other_values"] = int(counts.iloc[TOP_K:].sum())
    return info


def profile(df, key=None):
    out = {
        "rows": int(len(df)),
        "columns": {col: profile_column(df[col]) for col in df.columns},
    }
    if key and key in df.columns:
        dupes = df[key].duplicated().sum()
        out["duplicate_keys"] = {"column": key, "count": int(dupes)}
    rows_missing = df.isna().any(axis=1)
    out["rows_with_missing"] = int(rows_missing.sum())
    if rows_missing.any():
        by_col = df.loc[rows_missing].isna().sum()
        out["missing_by_column"] = {c: int(n) for c, n in by_col.items() if n > 0}
    return out


def summarize(p):
    print(f"rows: {p['rows']}, rows with missing values: {p['rows_with_missing']}")
    if "duplicate_keys" in p:
        print(f"duplicate {p['duplicate_keys']['column']}: {p['duplicate_keys']['count']}")
    for col, info in p["columns"].items():
        if "mean" in info:
            extra = ""
            if info["share_exact_0"] >= 0.05 or info["share_exact_1"] >= 0.05:
                extra = (f"  [exact0 {info['share_exact_0']:.0%}, "
                         f"exact1 {info['share_exact_1']:.0%}]")
            skew = "  [skew: median != mean]" if abs(info["mean"] - info["median"]) > max(0.1 * (info["std"] or 1), 0.02) else ""
            print(f"  {col}: {info['dtype']} miss={info['missing']} "
                  f"mean={info['mean']} med={info['median']}{extra}{skew}")
        else:
            top = ", ".join(list(info.get("top_values", {}))[:5])
            print(f"  {col}: {info['dtype']} miss={info['missing']} "
                  f"unique={info['unique']} top: {top}")


def main():
    parser = argparse.ArgumentParser(description="Deterministic dataset profiler")
    parser.add_argument("table")
    parser.add_argument("out_json")
    parser.add_argument("--key", help="id column to check for duplicates")
    args = parser.parse_args()
    df = load(args.table)
    p = profile(df, key=args.key)
    Path(args.out_json).parent.mkdir(parents=True, exist_ok=True)
    Path(args.out_json).write_text(json.dumps(p, indent=1))
    summarize(p)
    print(f"wrote {args.out_json}")


if __name__ == "__main__":
    main()
