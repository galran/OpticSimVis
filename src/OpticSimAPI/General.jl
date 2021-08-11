



# main draw function
# function draw(obj; kwargs...)
#     scene, lscene = Vis.scene(resolution)
#     draw!(lscene, ob; kwargs...)
#     display(scene)

#     if (get_current_mode() == :pluto || get_current_mode() == :docs)
#         return scene
#     end
# end


# function draw!(ob; kwargs...)
#     if current_3d_scene === nothing
#         scene, lscene = Vis.scene()
#     else
#         scene = current_main_scene
#         lscene = current_3d_scene
#     end
#     draw!(lscene, ob; kwargs...)
#     display(scene)

#     if (get_current_mode() == :pluto || get_current_mode() == :docs)
#         return scene
#     end
# end


#-----------------------------------------------------------------------------------------------
#   MESH from FILE
#-----------------------------------------------------------------------------------------------
function draw!(scene::Scene, ob::AbstractString; kwargs...)
    if any(endswith(lowercase(ob), x) for x in [".obj", "ply", ".2dm", ".off", ".stl"])
        meshdata = FileIO.load(ob)
        return draw!(scene, meshdata; kwargs...)
    else
        @error "Unsupported file type"
    end
end

#-----------------------------------------------------------------------------------------------
#   MESH
#-----------------------------------------------------------------------------------------------
function draw!(scene::Scene, mesh::GeometryBasics.AbstractMesh; kwargs...)
    name = "Mesh-$(UUIDs.uuid1())"
    mat = Material(;kwargs...)
    scene_mesh = Mesh(mesh, material=mat, name=name)

    OpticSimVis.set_parent!(scene_mesh , OpticSimVis.root(scene))

    return Dict{Symbol, Any}(
        :scene => scene,
        :scene_object => scene_mesh,
    )
end

#-----------------------------------------------------------------------------------------------
#   TriangleMesh (OpticSim type)
#-----------------------------------------------------------------------------------------------
function draw!(scene::Scene, tmesh::TriangleMesh{T}; kwargs...) where {T<:Real}
    mesh = to_mesh(tmesh)
    return draw!(scene, mesh; kwargs...)
    # if normals
    #     @warn "Normals being drawn from triangulated mesh, precision may be low"
    #     norigins = [Makie.Point3f0(centroid(t)) for t in tmesh.triangles[1:10:end]]
    #     ndirs = [Makie.Point3f0(normal(t)) for t in tmesh.triangles[1:10:end]]
    #     if length(norigins) > 0
    #         Makie.arrows!(scene, norigins, ndirs, arrowsize = 0.2, arrowcolor = normalcolor, linecolor = normalcolor, linewidth = 2)
    #     end
    # end
end


#-----------------------------------------------------------------------------------------------
#   Surface{T}
#-----------------------------------------------------------------------------------------------
function draw!(scene::Scene, surf::Surface{T}; numdivisions::Int = 30, kwargs...) where {T<:Real}
    tmesh = makemesh(surf, numdivisions)
    if nothing === tmesh
        return
    end
    return draw!(scene, tmesh; kwargs...)
    # if normals
    #     ndirs = Makie.Point3f0.(samplesurface(surf, normal, numdivisions ÷ 10))
    #     norigins = Makie.Point3f0.(samplesurface(surf, point, numdivisions ÷ 10))
    #     Makie.arrows!(scene, norigins, ndirs, arrowsize = 0.2, arrowcolor = normalcolor, linecolor = normalcolor, linewidth = 2)
    # end
end
