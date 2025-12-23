# Context
- Repository explores Gmsh helical O-mesh generation for an Archimedes Tube Crystallizer (ATC) helix. Goal: pure hex mesh by sweeping a quad O-grid cross-section along a helical centerline.
- Last intensive work: July 7–8, 2025. Latest doc refresh: `atc_with_examples.md` (2025-12-04) and `readme_atc_parametric.md` (2025-07-07).

# Latest working artifacts to review
- `examples/pure_quad_omesh_helix_minimal.geo` (2025-07-08): final ultra-coarse pure-quad O-mesh .geo using full transfinite setup (nCirc=1, nRad=1, nAxial=20 by default). Output `examples/pure_quad_omesh_helix_minimal.msh` (48 hex elements when generated with defaults).
- `examples/pure_quad_helix_fixed.geo` (2025-07-07): higher-resolution version (nCirc=32, nRad=8, nAxial=40). Output `examples/pure_quad_helix_fixed.msh` (~17 MB).
- Python variants:
  - `examples/atc_parametric_advanced.py`: parametric helix sweep using simple 4-surface O-grid; supports arbitrary angular ranges; generates `atc_helix_XXtoYYdeg.msh`.
  - `examples/atc_pure_quad_helix.py`: pure-quad O-grid (48 surfaces) swept via `twist`; produced meshes like `atc_pure_quad_helix_0to180deg.msh` (and shorter spans).
- Root docs: `readme_atc_parametric.md` (overview of parametric helix script) and `atc_with_examples.md` (Blender helix modeling notes).

# How to reproduce key meshes
- Run minimal geo: `gmsh examples/pure_quad_omesh_helix_minimal.geo -3 -format msh2 -o examples/pure_quad_omesh_helix_minimal.msh`
- Run higher-res geo: `gmsh examples/pure_quad_helix_fixed.geo -3 -o examples/pure_quad_helix_fixed.msh`
- Python parametric: `python examples/atc_parametric_advanced.py -nopopup` (auto-generates several spans). Pure-quad Python: `python examples/atc_pure_quad_helix.py -nopopup`.

# Utility: fit_sphere_centerline.py
- Fits a fixed-radius sphere whose center lies on a helix centerline to a ring of points.
- Required CSV columns: `vtkOriginalPointIds,Points:0,Points:1,Points:2`.
- Required args: `--ring_csv --R --Pturn --r --theta_min_deg --theta_max_deg`
- Optional: `--z0`, `--theta_center` (radians), `--theta_halfwidth_deg`, `--free_dx_max/--free_dy_max/--free_dz_max`,
  `--project_csv` with `--project_out`.
- Example:
  `python fit_sphere_centerline.py --ring_csv path/to/ring.csv --R 0.05 --Pturn 0.10 --r 0.012 --theta_min_deg 0 --theta_max_deg 180`

# Key insights captured previously
- Success hinges on transfinite meshing of all O-grid surfaces (outer, middle, center, transition) before twist extrusion; eliminates stray triangles and yields pure hexes.
- Ultra-coarse feasible with nCirc=1, nRad=1; transfinite line counts set via nCirc/4+1 and nRad+1 to maintain quad topology.
- Helical extrusion now uses the 4-argument twist form to apply both rotation and pitch: `Extrude { {0,0,dz}, {0,0,1}, {0,0,0}, angular_span } { Surface{all_surfaces[]}; Layers{nAxial}; Recombine; }`, preceded by a `Rotate` by `start_angle` about z; dz still `=(Pturn/(2π))*angular_span`.

# Open questions / next steps
- Verify mesh quality/counts for higher-res `.msh` (e.g., `pure_quad_helix_fixed.msh`) and confirm absence of pyramids/tets.
- If resuming, consider merging Python and .geo approaches: generate O-grid in Python but emit .geo-like transfinite definitions before twist.
- Status update (2025-12-04): User confirmed `examples/pure_quad_omesh_helix_minimal.msh` looks great; keep as reference baseline.
