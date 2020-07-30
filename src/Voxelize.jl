module Voxelize
using AbstractPlotting
using CoordinateTransformations
using GeometryBasics
using LinearAlgebra: norm, UniformScaling

export voxelize, voxels

struct VoxelGrid
    voxels::Array{Int8,3}
    scale::Float64
    offset::Array{Float64,1}
end

distance(p₁, p₂) = norm(p₁ - p₂)

function split_edge!(new, p₁, p₂, length::Float64, iter::Int, max_iter::Int=20)
    if iter <= max_iter && distance(p₁, p₂) > length
        new_p = (p₁ + p₂) / 2
        push!(new, new_p)
        split_edge!(new, p₁, new_p, length, iter+1, max_iter)
        split_edge!(new, p₂, new_p, length, iter+1, max_iter)
    end
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
    vertices = copy(mesh.position)

    for triangle in mesh
        for edge in  [(1, 2) (2, 3) (3, 1)]
            p₁ = triangle[edge[1]]
            p₂ = triangle[edge[2]]
            split_edge!(vertices, p₁, p₂, max_edge, 0, max_iter)
        end
    end
    @show size(vertices)
    vmin = Point3(typemax(Float32))
    vmax = Point3(typemin(Float32))
    for p in vertices
        vmin = min.(p, vmin)
        vmax = max.(p, vmax)
    end
    widths = vmax .- vmin

    translation = Translation(-vmin) # shift mesh minimum into origin
    scale = LinearMap(UniformScaling(1/pitch)) # scale into local coordinates
    trans = scale ∘ translation
    vertices = map(trans, vertices)

    grid_size = ceil.(Int, widths ./ pitch)
    voxels = zeros(Int8, grid_size...)
    Threads.@threads for vertex in vertices
        p = floor.(Int, vertex .+ 1) # add one for indexing
        voxels[p...] = 1
    end
    VoxelGrid(voxels, pitch, vmin)
end

function voxels(grid::VoxelGrid)
    volume(grid.voxels, algorithm=:iso, isovalue=1, isorange=0.5)
end

end # module
