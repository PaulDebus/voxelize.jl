# Voxelize.jl
*Compute voxel (3D pixels) representations from polygon meshes.*

This package implements one algorithm based on the approach of the [trimesh library](https://github.com/mikedh/trimesh) to convert a polygon mesh into a voxel grid represenation. This voxel grid is represented by a 3D Array of `Int8`, where a non-zero value means that the cell is occupied.

The algorithm splits each edge in half until each piece is smaller then a fraction of the desired voxel size. Then, each vertex position is converted to an index in the grid array and the corresponding value is set to `1`.

## Roadmap
While the project is working at the moment with the functionality I need, I will want to work on it a little more. Open points are

* Improvement of the output data structure. [OffsetArrays.jl](https://github.com/JuliaArrays/OffsetArrays.jl) could be useful here as well as using the sparse matrices to represent the grid
* Implement different methods for voxelizing a mesh, that are not as naive as the current one
* Performance improvements (even though it runs quite fast for my cases)

I am very open to any contributions and collaborations. Just contact me!
