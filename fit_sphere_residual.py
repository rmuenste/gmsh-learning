#!/usr/bin/env python3
import argparse
import csv
import math
from dataclasses import dataclass
from typing import List

import numpy as np


@dataclass
class PointRow:
    pid: int
    p: np.ndarray  # shape (3,)


def read_points_csv(path: str) -> List[PointRow]:
    rows: List[PointRow] = []
    with open(path, "r", newline="") as f:
        reader = csv.DictReader(f)
        # Expected columns:
        # "vtkOriginalPointIds","Points:0","Points:1","Points:2"
        for r in reader:
            pid = int(r["vtkOriginalPointIds"])
            x = float(r["Points:0"])
            y = float(r["Points:1"])
            z = float(r["Points:2"])
            rows.append(PointRow(pid=pid, p=np.array([x, y, z], dtype=float)))
    if not rows:
        raise RuntimeError(f"No points found in {path}")
    return rows


def main():
    ap = argparse.ArgumentParser(
        description="Compute residuals for a fixed-radius sphere at a fixed center against input points."
    )
    ap.add_argument("--points_csv", required=True, help="CSV with points (ids + xyz).")
    ap.add_argument("--r", type=float, required=True, help="Sphere radius.")
    ap.add_argument("--cx", type=float, required=True, help="Sphere center x.")
    ap.add_argument("--cy", type=float, required=True, help="Sphere center y.")
    ap.add_argument("--cz", type=float, required=True, help="Sphere center z.")
    args = ap.parse_args()

    rows = read_points_csv(args.points_csv)
    pts = np.stack([r.p for r in rows], axis=0)
    C = np.array([args.cx, args.cy, args.cz], dtype=float)

    d = np.linalg.norm(pts - C[None, :], axis=1)
    res = d - args.r

    rmse = math.sqrt(float(np.mean(res * res)))
    sse = float(np.dot(res, res))
    print("=== Sphere residual (fixed center and radius) ===")
    print(f"Points: {len(pts)}")
    print(f"Center: [{C[0]}, {C[1]}, {C[2]}]")
    print(f"Radius: {args.r}")
    print(f"RMSE(|p-C|-r): {rmse}")
    print(f"SSE(|p-C|-r):  {sse}")
    print(f"Residual min/max: [{float(res.min())}, {float(res.max())}]")


if __name__ == "__main__":
    main()
