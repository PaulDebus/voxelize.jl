module jlVoxel
using GeometryBasics
using CoordinateTransformations
using Rotations
using AbstractPlotting
using LinearAlgebra: norm

export voxelize, voxels

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
function voxelize(mesh::GeometryBasics.Mesh, pitch::Float64; max_iter=10, edge_factor=2.0)::VoxelGrid
    max_edge = pitch / edge_factor
    v = coordinates(mesh)
    boundingbox = Rect(v)

    offset = minimum(boundingbox)
    trans = Translation(-offset)

    grid_size = ceil.(Int, boundingbox.widths ./ pitch)
    voxels = zeros(Int8, grid_size...)
    distance(p1::Point, p2::Point) = norm(p1 - p2)
    for point in v
        p = floor.(Int, trans(point) ./ pitch .+ 1)
        voxels[p...] = 1
    end
    VoxelGrid(voxels, pitch, offset)
end

function voxels(grid::VoxelGrid)
    volume(grid.voxels, algorithm=:iso, isovalue=1, isorange=0.5)
end

end # module
