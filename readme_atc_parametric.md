# ATC Parametric Helical Tube Mesh Generator

## Overview

`atc_parametric.py` is a Python script that generates structured 3D helical tube meshes using Gmsh with **arbitrary angular range support**. Unlike fixed half-turn implementations, this version allows you to specify custom start and end angles for the helical sweep, making it highly flexible for various engineering applications.

## Key Features

- **Parametric Angular Range**: Specify any start/end angles (not limited to full or half turns)
- **O-Grid Cross-Section**: Creates structured quadrilateral mesh topology for high-quality CFD simulations
- **Helical Twist Extrusion**: Uses Gmsh's twist operation for mathematically accurate helical geometry
- **Automatic Frame Calculation**: Computes proper local coordinate systems along the helix
- **Structured Mesh Control**: Full control over mesh density in all directions

## Mathematical Foundation

### Helix Parameterization
The script generates a helix using the standard parametric equations:
```
x(θ) = R × cos(θ)
y(θ) = R × sin(θ)  
z(θ) = (Pitch/2π) × θ
```

### Local Frame Computation
At each point on the helix centerline, a local coordinate system is computed:

- **Tangent Vector**: Direction along the helix curve
  ```
  T = (-R×sin(θ), R×cos(θ), Pitch/2π) (normalized)
  ```

- **Normal Vector**: Points radially outward from helix axis
  ```
  N = (cos(θ), sin(θ), 0)
  ```

- **Binormal Vector**: Completes right-handed coordinate system
  ```
  B = T × N
  ```

## Parameters

### Geometric Parameters
```python
R = 25.0        # Helix radius (mm)
rtube = 2.5     # Inner tube radius (mm)
Pturn = 7.0     # Pitch per full turn (mm)
```

### Angular Range (Key Feature)
```python
start_angle_deg = 30.0    # Start angle in degrees
end_angle_deg = 150.0     # End angle in degrees
```

### Mesh Control Parameters
```python
nCirc = 32      # Cells around circumference (÷4 per O-grid block)
nRad = 8        # Cells from center to wall (per block)
nAxial = 40     # Layers along helical sweep
ratioR = 1.0    # Radial mesh grading ratio
```

## Algorithm Workflow

### 1. Parameter Setup
- Convert angular range from degrees to radians
- Calculate axial rise: `dz = (Pitch/2π) × angular_span`
- Compute starting position and local frame vectors

### 2. O-Grid Cross-Section Creation
- Create center point at helix radius on starting plane
- Generate 4 points on circle boundary using local normal/binormal vectors
- Create 4 circular arcs connecting the boundary points
- Add radial lines from center to boundary
- Form 4 quadrilateral surfaces for O-grid topology

### 3. Structured Mesh Setup
- Apply transfinite meshing to all curves with specified densities
- Set surfaces as transfinite and recombined (pure quads)
- Configure mesh progression ratios for boundary layer control

### 4. Helical Extrusion
- Use Gmsh's `twist()` operation on each O-grid surface
- Extrude with simultaneous rotation and translation
- Generate `nAxial` layers over the specified angular span

### 5. Mesh Generation
- Synchronize geometry model
- Generate 3D structured hexahedral mesh
- Export to `.msh` file with descriptive filename

## Usage Examples

### Basic Usage
```bash
python atc_parametric.py
```
Generates a 120° helical segment (30° to 150°) with GUI preview.

### No GUI Mode
```bash
python atc_parametric.py -nopopup
```
Generates mesh without displaying the GUI.

### Customizing Parameters
Edit the script to modify:
- `start_angle_deg` and `end_angle_deg` for different angular ranges
- Geometric parameters (`R`, `rtube`, `Pturn`) for different helix dimensions
- Mesh parameters (`nCirc`, `nRad`, `nAxial`) for resolution control

## Output

### Generated Files
- **Mesh File**: `atc_helix_{start}to{end}deg.msh`
  - Example: `atc_helix_30to150deg.msh` for default parameters

### Console Output
```
Generating helical mesh:
  Angular range: 30.0° to 150.0° (120.0° span)
  Axial rise: 2.333 mm
  Helix radius: 25 mm, Tube radius: 2.5 mm
✓ Generated helical tube mesh with 4 volumes
✓ 40 layers over 120.0° span
✓ Mesh written to: atc_helix_30to150deg.msh
```

## Applications

### CFD Simulations
- **Heat Exchangers**: Helical tube heat exchangers with complex flow patterns
- **Mixing Devices**: Helical static mixers and twisted tube reactors
- **Turbomachinery**: Scroll compressors, helical blade passages

### Structural Analysis
- **Coiled Springs**: Variable pitch helical springs
- **Helical Stairs**: Architectural helical structures
- **Twisted Members**: Structural elements with helical geometry

## Technical Advantages

### Geometric Accuracy
- Mathematically exact helical curves using twist extrusion
- Proper frame orientation prevents mesh distortion
- Automatic handling of complex 3D transformations

### Mesh Quality
- Structured O-grid topology ensures orthogonal mesh lines
- Controlled aspect ratios for numerical stability
- Pure hexahedral elements (no pyramids or tetrahedra)

### Flexibility
- Arbitrary angular ranges (not limited to standard fractions)
- Independent control of all geometric and mesh parameters
- Easy integration into parametric design workflows

## Dependencies

- **Python 3.x**
- **Gmsh 4.x**: `pip install gmsh`
- **Standard libraries**: `math`, `sys`

## Related Files

- `atc.geo`: Original GEO script version (fixed half-turn)
- `atc_parametric_advanced.py`: Extended version with additional features
- `atc_frenet_frame.py`: Alternative implementation using Frenet frames

## Notes

- The script uses Gmsh's built-in geometry kernel for maximum compatibility
- Twist extrusion automatically handles the complex 3D transformations
- The O-grid cross-section ensures high-quality structured meshes suitable for CFD
- Output mesh is compatible with most CFD solvers (OpenFOAM, FLUENT, etc.)