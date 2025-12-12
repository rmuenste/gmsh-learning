#!/usr/bin/env bash
set -e

OUTDIR=output
mkdir -p "$OUTDIR"

gmsh examples/pure_quad_omesh_helix_minimal.geo -3 \
  -setnumber start_angle_deg 45 \
  -setnumber end_angle_deg 135 \
  -setnumber nAxial 50 \
  -o "$OUTDIR/mesh.msh"
