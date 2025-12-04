## 📌 Archimedes Tube Crystallizer (ATC) Helix – Parametric Definition The **inner centerline** of the ATC can be modeled mathematically as an ideal parametric helix: $$ \begin{cases} x(\theta) = R \cos(\theta + \varphi_0) \\ y(\theta) = R \sin(\theta + \varphi_0) \\ z(\theta) = \dfrac{P}{2\pi} \theta \end{cases} $$ where: * $R$ = helix radius (half the coil diameter) * $P$ = pitch (axial advance per turn) * $\varphi_0$ = phase offset (start angle) * $\theta \in [0, 2\pi N_\text{turns}]$ For the ATC design from the **Flow Map paper**, these values are fixed: | Parameter | Value | Meaning | | ---------- | ------------ | ------------------------------------ | | R | 25 mm | Radius (half of 50 mm coil diameter) | | P | 7 mm | Pitch per turn | | N\_turns | 45 | Total turns | | ϕ₀ | 0 | Start phase (can be rotated in CAD) | | Handedness | Right-handed | z increases with θ | This defines the *centerline path* exactly. --- ## 📌 Blender Generation – Overview In **Blender 4**, there's no built-in *Curve Spiral* node out of the box. ✅ The *easiest and most controllable* way is to **generate the centerline curve by scripting** in Blender’s Python API, then use a bevel object to make it a tube. This was exactly what you did successfully. --- ## 🧭 Step-by-Step Procedure Below is a clear summary of the procedure that worked best: --- ### 1️⃣ Define the Helix Parameters in Blender Script Specify: * **Radius** R = 25 mm * **Pitch** P = 7 mm * **Number of turns** N = 45 * **Resolution** = number of points per turn (e.g. 32 for smoothness) --- ### 2️⃣ Compute the Helix Points Sample θ from 0 to 2π·N, and compute: $$ \begin{aligned} x &= R \cos(\theta + \varphi_0) \\ y &= R \sin(\theta + \varphi_0) \\ z &= \frac{P}{2\pi}\theta \end{aligned} $$ For **right-handed**, z increases with θ. --- ### 3️⃣ Create a Curve Object in Blender * Make a new CURVE data block. * Add a *spline* with the computed (x, y, z) points. * Optionally set type = NURBS for smooth interpolation. --- ### 4️⃣ Add a Bevel Object * Create a small Bezier Circle with radius = half the **tube outer diameter**. * For a 5 mm O.D. tube → use **2.5 mm radius**. * Assign this circle as the *bevel object* of the helix curve. * Adjust resolution for cross-section roundness. --- ### 5️⃣ Result You get: ✅ A **true 3D tube** in Blender ✅ Exactly following the theoretical ATC centerline ✅ Fully parametric and editable You can later: * Convert to Mesh * Export as STL/OBJ/FBX * Render or animate in Blender --- ## 📜 Example Blender Python Code Snippet Here’s the **essential** part that generated your ATC helix:
python
import bpy
import math

# --- Parameters
R = 25.0     # mm
P = 7.0      # mm
N_coil = 45
phi0 = 0.0
resolution_per_turn = 32

# --- Compute points
n_pts = N_coil * resolution_per_turn + 1
points = []
for i in range(n_pts):
    theta = 2 * math.pi * i / resolution_per_turn
    x = R * math.cos(theta + phi0)
    y = R * math.sin(theta + phi0)
    z = (P * theta) / (2 * math.pi)
    points.append((x, y, z, 1))

# --- Create curve
curve_data = bpy.data.curves.new("ATC_Helix", type='CURVE')
curve_data.dimensions = '3D'
spline = curve_data.splines.new('NURBS')
spline.points.add(len(points)-1)
for p, co in zip(spline.points, points):
    p.co = co
spline.order_u = 3
spline.use_endpoint_u = True

# --- Object
curve_obj = bpy.data.objects.new("ATC_Helix", curve_data)
bpy.context.collection.objects.link(curve_obj)

# --- Add tube profile
bpy.ops.curve.primitive_bezier_circle_add(radius=2.5)
profile_obj = bpy.context.object
curve_data.bevel_object = profile_obj
curve_data.resolution_u = 24
✅ You can paste this into Blender’s 
**Scripting** workspace.
 ✅ It creates: 
 * **ATC\_Helix** (curve following the centerline) 
 * **TubeProfile** (circular cross-section) 
 * A full **3D tube** model
  --- ## 🧭 Advantages of This Method
   ✔ Exact match to design specs (25 mm radius, 7 mm pitch, 45 turns) ✔ Easy to modify (just change R, P, N\_coil in script) ✔ Non-destructive: you can adjust profile radius anytime ✔ Blender-native:
    no external add-ons required ✔ Exports cleanly for 3D printing or CFD meshing
    --- ## ✨ Recommended Use This method is ideal for: 
    ✅ Visualization and rendering of the ATC geometry 
    ✅ Exporting realistic geometry for CFD or simulation 
    ✅ Adjusting design parameters (pitch, radius, number of turns) quickly