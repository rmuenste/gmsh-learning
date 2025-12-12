import gmsh
import os

os.makedirs("output", exist_ok=True)

gmsh.initialize()
gmsh.open("pure_quad_omesh_helix_minimal.geo")
gmsh.option.setNumber("start_angle_deg", 45)
gmsh.option.setNumber("end_angle_deg", 135)
gmsh.model.mesh.generate(3)
gmsh.write("output/pure_quad_omesh_helix_minimal.vtk")
gmsh.finalize()
