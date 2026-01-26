import bpy
import os

output_path = os.path.expanduser("~/sorted_vertices_by_x_world.txt")
precision = 6

obj = bpy.context.active_object
if obj is None or obj.type != 'MESH':
    raise RuntimeError("Please select a mesh object.")

M = obj.matrix_world

# world-space vertex coordinates
verts = [(M @ v.co) for v in obj.data.vertices]

# sort by world-space x
verts_sorted = sorted(verts, key=lambda v: v.x)

with open(output_path, "w") as f:
    f.write("# x y z (world)\n")
    for v in verts_sorted:
        f.write(f"{v.x:.{precision}f} {v.y:.{precision}f} {v.z:.{precision}f}\n")

print(f"Wrote {len(verts_sorted)} vertices to {output_path}")

