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