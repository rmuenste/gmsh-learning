# Claude's Project Notes

## Project Summary
Gmsh helical O-mesh generation for Archimedes Tube Crystallizer (ATC). Goal: Generate pure hexahedral meshes by sweeping structured quad O-grid cross-sections along helical centerlines.

## Testing Status
- **Gmsh Version**: Successfully tested with **Gmsh 4.12**
- **Baseline Reference**: `examples/pure_quad_omesh_helix_minimal.geo` confirmed working
- **Output**: Produces 48 hex elements with ultra-coarse settings (nCirc=1, nRad=1, nAxial=20)
- **Status**: User confirmed mesh "looks great" (2025-12-04)

## Key Technical Understanding

### O-mesh Cross-Section Structure
The working approach uses a 48-surface cross-section:
- **16 outer surfaces**: Between tube wall and inner ring
- **16 middle surfaces**: Between inner ring and quad boundary
- **4 center surfaces**: Core structured quad region
- **12 transition surfaces**: Bridge between center and middle layers

### Critical Success Factors
1. **Transfinite meshing on ALL entities** before extrusion
   - All curves: `Transfinite Line {id} = count;`
   - All surfaces: `Transfinite Surface {id}; Recombine Surface {id};`
   - This guarantees pure quad cross-section → pure hex 3D mesh

2. **Helical extrusion syntax**:
   ```
   Extrude { {0,0,dz}, {0,0,0}, angular_span } {
       Surface{all_surfaces[]};
       Layers{nAxial};
       Recombine;
   }
   ```
   - Rotates around Z-axis with simultaneous axial rise
   - `dz = (Pturn / (2*Pi)) * angular_span`

### Parametric Control
- `R`: Helix radius (25mm default)
- `rtube`: Tube radius (2.5mm default)
- `Pturn`: Pitch per turn (7mm default)
- `start_angle_deg`, `end_angle_deg`: Angular sweep range
- `nCirc`, `nRad`, `nAxial`: Mesh resolution controls

## Key Files Reference
- `AGENTS.md`: Context and artifact inventory
- `examples/pure_quad_omesh_helix_minimal.geo`: Working baseline (ultra-coarse)
- `examples/pure_quad_helix_fixed.geo`: Higher resolution version
- `examples/atc_parametric_advanced.py`: Python parametric variant
- `examples/atc_pure_quad_helix.py`: Python pure-quad O-grid variant
- `readme_atc_parametric.md`: Parametric helix script overview
- `atc_with_examples.md`: Blender helix modeling notes

## Command Reference
```bash
# Generate minimal mesh
gmsh examples/pure_quad_omesh_helix_minimal.geo -3 -format msh2 -o examples/pure_quad_omesh_helix_minimal.msh

# Generate higher-res mesh
gmsh examples/pure_quad_helix_fixed.geo -3 -o examples/pure_quad_helix_fixed.msh

# Python variants
python examples/atc_parametric_advanced.py -nopopup
python examples/atc_pure_quad_helix.py -nopopup
```

## Open Questions / Future Work
- Verify mesh quality metrics for higher-resolution meshes
- Consider merging Python and .geo approaches
- Explore adaptive resolution strategies for specific flow regions

## Last Updated
2025-12-10: Initial notes created after confirming gmsh 4.12 compatibility
