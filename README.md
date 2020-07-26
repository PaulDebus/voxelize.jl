# Voxelize.jl
Compute voxel (3D pixels) representations from polygon meshes.

**This project is very much a first test and exploration. It does not even really work in the moment for. Use with care... or preferably not all**

The idea is based on the implementation of the [trimesh library](https://github.com/mikedh/trimesh), where the edges of the mesh are split until every edge is shorter then half of the desired grid size. Then, the vertex coordinates are converted to voxel indices and the corresponding fields of the world array are set to 1.
