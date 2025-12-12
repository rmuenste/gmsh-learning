#!/usr/bin/env python3
import argparse
import csv
import math
from dataclasses import dataclass
from typing import List, Tuple, Optional

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


def write_points_csv(path: str, rows: List[PointRow]) -> None:
    with open(path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["vtkOriginalPointIds", "Points:0", "Points:1", "Points:2"])
        for r in rows:
            writer.writerow([r.pid, float(r.p[0]), float(r.p[1]), float(r.p[2])])


def helix_centerline_point(theta: float, R: float, k: float, z0: float) -> np.ndarray:
    """
    Helix centerline:
      x = R cos(theta)
      y = R sin(theta)
      z = z0 + k * theta
    where k = Pturn/(2*pi)
    """
    return np.array([R * math.cos(theta), R * math.sin(theta), z0 + k * theta], dtype=float)


def objective(theta: float, pts: np.ndarray, R: float, k: float, z0: float, r_sphere: float) -> float:
    C = helix_centerline_point(theta, R, k, z0)
    d = np.linalg.norm(pts - C[None, :], axis=1)
    res = d - r_sphere
    return float(np.dot(res, res))


def golden_section_minimize(
    f, a: float, b: float, tol: float = 1e-10, max_iter: int = 200
) -> Tuple[float, float]:
    """
    Minimize f on [a,b] using golden-section search.
    Returns (x_min, f(x_min)).
    """
    gr = (math.sqrt(5) - 1) / 2  # ~0.618
    c = b - gr * (b - a)
    d = a + gr * (b - a)
    fc = f(c)
    fd = f(d)

    for _ in range(max_iter):
        if abs(b - a) < tol:
            break
        if fc < fd:
            b, d, fd = d, c, fc
            c = b - gr * (b - a)
            fc = f(c)
        else:
            a, c, fc = c, d, fd
            d = a + gr * (b - a)
            fd = f(d)

    x = 0.5 * (a + b)
    return x, f(x)


def estimate_theta_from_points(pts: np.ndarray) -> float:
    """
    Rough estimate for theta based on centroid direction in xy-plane.
    """
    c = pts.mean(axis=0)
    return math.atan2(c[1], c[0])


def main():
    ap = argparse.ArgumentParser(
        description="Fit a fixed-radius sphere center constrained to a helix centerline."
    )
    ap.add_argument("--ring_csv", required=True, help="CSV with outer-ring points (ids + xyz).")
    ap.add_argument("--R", type=float, required=True, help="Helix radius R.")
    ap.add_argument("--Pturn", type=float, required=True, help="Pitch per full turn (same units as coords).")
    ap.add_argument("--z0", type=float, default=0.0, help="Helix z offset for theta=0. Default: 0.")
    ap.add_argument("--r", type=float, required=True, help="Fixed sphere radius to fit to.")
    ap.add_argument("--theta_center", type=float, default=None,
                    help="Center of search interval for theta (radians). If omitted, estimated from ring centroid.")
    ap.add_argument("--theta_halfwidth_deg", type=float, default=90.0,
                    help="Search half-width in degrees around theta_center. Default: 90 deg.")
    ap.add_argument("--theta_min_deg", type=float, required=True,
                    help="Minimum theta in degrees for valid helix span (e.g., start_angle_deg).")
    ap.add_argument("--theta_max_deg", type=float, required=True,
                    help="Maximum theta in degrees for valid helix span (e.g., end_angle_deg).")
    ap.add_argument("--free_dx_max", type=float, default=0.0,
                    help="Optional second-pass freedom in x (symmetric +/-). 0 disables.")
    ap.add_argument("--free_dy_max", type=float, default=0.0,
                    help="Optional second-pass freedom in y (symmetric +/-). 0 disables.")
    ap.add_argument("--free_dz_max", type=float, default=0.0,
                    help="Optional second-pass freedom in z (symmetric +/-). 0 disables.")
    ap.add_argument("--free_iters", type=int, default=2,
                    help="Number of coordinate-descent cycles for free dx/dy/dz refinement (default: 2).")
    ap.add_argument("--tol", type=float, default=1e-10, help="Tolerance for 1D minimizer.")
    ap.add_argument("--project_csv", default=None,
                    help="Optional CSV of cap nodes to project to the fitted sphere.")
    ap.add_argument("--project_out", default=None,
                    help="Output CSV for projected nodes (required if --project_csv is used).")
    args = ap.parse_args()

    ring_rows = read_points_csv(args.ring_csv)
    ring_pts = np.stack([r.p for r in ring_rows], axis=0)

    k = args.Pturn / (2.0 * math.pi)

    theta0 = args.theta_center
    if theta0 is None:
        theta0 = estimate_theta_from_points(ring_pts)
        print(f"Theta is {theta0}")

    theta_min_allowed = math.radians(args.theta_min_deg)
    theta_max_allowed = math.radians(args.theta_max_deg)
    if theta_min_allowed >= theta_max_allowed:
        raise SystemExit("Error: theta_min_deg must be < theta_max_deg")

    halfwidth = math.radians(args.theta_halfwidth_deg)
    a = theta0 - halfwidth
    b = theta0 + halfwidth
    a = max(a, theta_min_allowed)
    b = min(b, theta_max_allowed)
    if a >= b:
        raise SystemExit("Error: search interval is empty after clamping to [theta_min_deg, theta_max_deg]")

    f = lambda th: objective(th, ring_pts, args.R, k, args.z0, args.r)

    # Coarse scan to avoid missing a better basin
    n_scan = 721  # 0.25 deg resolution over 180 deg if halfwidth=90
    thetas = np.linspace(a, b, n_scan)
    vals = np.array([f(th) for th in thetas])
    th_best = float(thetas[int(np.argmin(vals))])

    # Refine near best
    refine_hw = min(halfwidth, math.radians(10.0))
    a2 = th_best - refine_hw
    b2 = th_best + refine_hw
    th_min, f_min = golden_section_minimize(f, a2, b2, tol=args.tol)

    C = helix_centerline_point(th_min, args.R, k, args.z0)

    # Report fit quality on ring points
    d = np.linalg.norm(ring_pts - C[None, :], axis=1)
    res = d - args.r
    rmse = math.sqrt(float(np.mean(res * res)))
    print("=== Fixed-radius sphere fit (center constrained to helix centerline) ===")
    print(f"Input ring points: {len(ring_pts)}")
    print(f"Fixed radius r     = {args.r}")
    print(f"Helix params: R={args.R}, Pturn={args.Pturn}, z0={args.z0} (k={k})")
    print(f"theta_min (rad)    = {th_min}")
    print(f"theta_min (deg)    = {th_min * 180.0 / math.pi}")
    print(f"Center C           = [{C[0]}, {C[1]}, {C[2]}]")
    print(f"RMSE(|p-C|-r)      = {rmse}")
    print(f"min/max residual   = [{float(res.min())}, {float(res.max())}]")

    # Optional second pass: allow small dx/dy/dz freedom from the helix point
    free_enabled = any(v > 0.0 for v in (args.free_dx_max, args.free_dy_max, args.free_dz_max))
    if free_enabled:
        def obj_center(cx, cy, cz):
            dloc = np.linalg.norm(ring_pts - np.array([cx, cy, cz])[None, :], axis=1)
            resloc = dloc - args.r
            return float(np.dot(resloc, resloc))

        cx, cy, cz = C.tolist()
        for _ in range(max(1, args.free_iters)):
            if args.free_dx_max > 0:
                ax = cx - args.free_dx_max
                bx = cx + args.free_dx_max
                cx, _ = golden_section_minimize(lambda v: obj_center(v, cy, cz), ax, bx, tol=args.tol)
            if args.free_dy_max > 0:
                ay = cy - args.free_dy_max
                by = cy + args.free_dy_max
                cy, _ = golden_section_minimize(lambda v: obj_center(cx, v, cz), ay, by, tol=args.tol)
            if args.free_dz_max > 0:
                az = cz - args.free_dz_max
                bz = cz + args.free_dz_max
                cz, _ = golden_section_minimize(lambda v: obj_center(cx, cy, v), az, bz, tol=args.tol)

        C2 = np.array([cx, cy, cz])
        d2 = np.linalg.norm(ring_pts - C2[None, :], axis=1)
        res2 = d2 - args.r
        rmse2 = math.sqrt(float(np.mean(res2 * res2)))
        print("=== Second-pass free dx/dy/dz refinement ===")
        print(f"Center C_free      = [{C2[0]}, {C2[1]}, {C2[2]}]")
        print(f"RMSE(|p-C|-r)      = {rmse2}")
        print(f"min/max residual   = [{float(res2.min())}, {float(res2.max())}]")
        C = C2

    # Optional projection
    if args.project_csv is not None:
        if args.project_out is None:
            raise SystemExit("Error: --project_out is required when using --project_csv")

        cap_rows = read_points_csv(args.project_csv)
        out_rows: List[PointRow] = []

        for row in cap_rows:
            v = row.p - C
            nv = float(np.linalg.norm(v))
            if nv == 0.0:
                # Degenerate: keep unchanged
                p_proj = row.p.copy()
            else:
                p_proj = C + (args.r / nv) * v
            out_rows.append(PointRow(pid=row.pid, p=p_proj))

        write_points_csv(args.project_out, out_rows)
        print(f"Projected {len(out_rows)} points to sphere and wrote: {args.project_out}")


if __name__ == "__main__":
    main()
