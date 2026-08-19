"""
Statistical machinery for the analysis phase — the single implementation
of the bootstrap, paired contrasts, mix standardization, and the
stats.json writer. Import from compute scripts; never re-implement these
inline (one seed per document, recorded in params).

Usage: copy next to the compute script, or add its directory to sys.path.
"""
import json
from pathlib import Path

import numpy as np


def _clean(values):
    v = np.asarray(values, dtype=float)
    return v[~np.isnan(v)]


def boot_ci(values, seed=0, n_boot=5000, alpha=0.05):
    """Seeded bootstrap CI of the mean. Returns (mean, lo, hi, n)."""
    rng = np.random.default_rng(seed)
    v = _clean(values)
    means = rng.choice(v, size=(n_boot, len(v)), replace=True).mean(axis=1)
    lo, hi = np.quantile(means, [alpha / 2, 1 - alpha / 2])
    return float(v.mean()), float(lo), float(hi), int(len(v))


def paired_delta_ci(a, b, seed=0, n_boot=5000, alpha=0.05):
    """
    Paired lift a - b on the same items (NaNs dropped pairwise).
    Returns (delta, lo, hi, n). Use for any claimed "A beats B by d".
    """
    a = np.asarray(a, dtype=float)
    b = np.asarray(b, dtype=float)
    keep = ~(np.isnan(a) | np.isnan(b))
    return boot_ci(a[keep] - b[keep], seed=seed, n_boot=n_boot, alpha=alpha)


def standardize(level_means, pooled_weights):
    """
    Direct standardization: reweight a group's per-level means to the
    pooled level distribution. level_means / pooled_weights: dicts keyed
    by level; weights need not be normalized. Levels missing a mean are
    excluded from both numerator and weight mass.
    """
    keys = [k for k in pooled_weights if k in level_means
            and level_means[k] is not None]
    total = sum(pooled_weights[k] for k in keys)
    return float(sum(level_means[k] * pooled_weights[k] for k in keys) / total)


def summary(values, seed=0, n_boot=5000):
    """The standard per-group entry: mean+CI, median, n, endpoint shares."""
    v = _clean(values)
    mean, lo, hi, n = boot_ci(v, seed=seed, n_boot=n_boot)
    return {
        "mean": round(mean, 4), "ci": [round(lo, 4), round(hi, 4)],
        "median": round(float(np.median(v)), 4), "n": n,
        "share_0": round(float((v == 0).mean()), 4),
        "share_1": round(float((v == 1).mean()), 4),
    }


def contrast(a, b, seed=0, n_boot=5000, paired=True):
    """The standard contrast entry for stats.json."""
    if paired:
        delta, lo, hi, n = paired_delta_ci(a, b, seed=seed, n_boot=n_boot)
    else:
        ma, la, ha, na = boot_ci(a, seed=seed, n_boot=n_boot)
        mb, lb, hb, nb = boot_ci(b, seed=seed + 1, n_boot=n_boot)
        delta, n = ma - mb, min(na, nb)
        rng = np.random.default_rng(seed)
        va, vb = _clean(a), _clean(b)
        deltas = (rng.choice(va, (n_boot, len(va)), replace=True).mean(axis=1)
                  - rng.choice(vb, (n_boot, len(vb)), replace=True).mean(axis=1))
        lo, hi = np.quantile(deltas, [0.025, 0.975])
    return {"delta": round(delta, 4), "ci": [round(float(lo), 4), round(float(hi), 4)],
            "n": int(n), "paired": paired}


def write_stats(path, groups, contrasts, params):
    """
    Write stats.json. params must record source, seed, n_boot, filters,
    and row counts; every groups entry must carry its n (enforced).
    """
    for key, entry in groups.items():
        if "n" not in entry:
            raise ValueError(f"stats entry '{key}' is missing its n")
    payload = {"params": params, "groups": groups, "contrasts": contrasts}
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_text(json.dumps(payload, indent=1))
    print(f"wrote {path}: {len(groups)} groups, {len(contrasts)} contrasts")
