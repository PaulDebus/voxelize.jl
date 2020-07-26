module jlVoxel
using GeometryBasics
using CoordinateTransformations
using Rotations

greet() = print("Hello World!")

struct VoxelGrid
    voxels::Array{Int8,3}
    scale::Float64
    offset::Array{Float64,1}
end


"""
    voxelize(mesh)::VoxelGrid
    Convert a triangle mesh into a VoxelGrid using the `voxelize_subdivide`
    from the Python trimesh package: https://github.com/mikedh/trimesh/blob/master/trimesh/voxel/creation.py
    Shift the model that the minimum corner is in the origin and scale it
    that the side of each voxel is 1 in local coordinates

    Parameters
    -----------
    mesh:        Mesh object
    pitch:       float, side length of a single voxel cube in original scale
    max_iter:    int, cap maximum subdivisions
    edge_factor: float

    Returns
    -----------
    VoxelGrid instance representing the voxelized mesh.
"""
function voxelize(mesh, pitch::Float64, max_iter=10, edge_factor=2.0)::VoxelGrid
    max_edge = pitch / edge_factor
    v = coordinates(mesh)
    low = ones(3)*typemax(Float64)
    up = ones(3)*typemin(Float64)
    for p in v
        low = minimum.(zip(low, p))
        up = maximum.(zip(up, p))
    end
#    l, u = [collect(e) for e in extrema(v)]
#    low = minimum.(zip(l,u))
#    up = maximum.(zip(l,u))
    offset = low
    trans = Translation(-offset)

    dx, dy, dz = ceil.(Int8, up.-low)
    voxels = zeros(Int8, dx, dy, dz)
    for point in v
        p = floor.(Int, trans(point) ./ pitch .+ 1)
        voxels[p[1], p[2], p[3]] = 1
    end
    VoxelGrid(voxels, pitch, offset)
end

end # module
