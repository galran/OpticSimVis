

module EmittersConsts
    const ARRROW_LENGTH = 0.5
    const ARRROW_SIZE = 0.01
    const MARKER_SIZE = 1
end


#-------------------------------------
# draw debug information - local axes and positions
#-------------------------------------
function maybe_draw_debug_info(scene::Scene, o::Origins.AbstractOriginDistribution; transform::Geometry.Transform = Transform(), debug::Bool=false, kwargs...) where {T<:Real}

    # dir = forward(transform)
    # uv = SVector{3}(right(transform))
    # vv = SVector{3}(up(transform))
    # pos = origin(transform)

    # if (debug)
    #     # this is a stupid hack to force makie to render in 3d - for some scenes, makie decide with no apperent reason to show in 2d instead of 3d
    #     Makie.scatter!(scene, [pos[1], pos[1]+0.1], [pos[2], pos[2]+0.1], [pos[3], pos[3]+0.1], color=:red, markersize=0)

    #     # draw the origin and normal of the surface
    #     Makie.scatter!(scene, pos, color=:blue, markersize = MARKER_SIZE * visual_size(o))

    #     # normal
    #     arrow_size = ARRROW_SIZE * visual_size(o)
    #     arrow_start = pos
    #     arrow_end = dir * ARRROW_LENGTH * visual_size(o) 
    #     Makie.arrows!(scene.scene, [Makie.Point3f0(arrow_start)], [Makie.Point3f0(arrow_end)], arrowsize=arrow_size, linewidth=arrow_size * 0.5, linecolor=:blue, arrowcolor=:blue)
    #     arrow_end = uv * 0.5 * ARRROW_LENGTH * visual_size(o) 
    #     Makie.arrows!(scene.scene, [Makie.Point3f0(arrow_start)], [Makie.Point3f0(arrow_end)], arrowsize= 0.5 * arrow_size, linewidth=arrow_size * 0.5, linecolor=:red, arrowcolor=:red)
    #     arrow_end = vv * 0.5 * ARRROW_LENGTH * visual_size(o) 
    #     Makie.arrows!(scene.scene, [Makie.Point3f0(arrow_start)], [Makie.Point3f0(arrow_end)], arrowsize= 0.5 * arrow_size, linewidth=arrow_size * 0.5, linecolor=:green, arrowcolor=:green)

    #     # draw all the samples origins
    #     positions = map(x -> transform*x, collect(o))
    #     positions = collect(Makie.Point3f0, positions)
    #     Makie.scatter!(scene, positions, color=:green, markersize = MARKER_SIZE * visual_size(o))

    #     # positions = collect(Makie.Point3f0, o)
    #     # Makie.scatter!(scene, positions, color=:green, markersize = MARKER_SIZE * visual_size(o))
    # end

end


#-------------------------------------
# draw hexapolar origin
#-------------------------------------
function draw!(scene::Scene, o::Origins.Hexapolar{T}; transform::Geometry.Transform{T} = Transform(), kwargs...) where {T<:Real}
    dir = forward(transform)
    uv = SVector{3}(right(transform))
    vv = SVector{3}(up(transform))
    pos = origin(transform)

    plane = OpticSim.Plane(dir, pos)
    ellipse = OpticSim.Ellipse(plane, o.halfsizeu, o.halfsizev, uv, vv)
    draw!(scene, ellipse;  kwargs...)

    # maybe_draw_debug_info(scene, o; transform=transform, kwargs...)
end



#-------------------------------------
# draw source
#-------------------------------------
function draw!(scene::Scene, s::Sources.Source{T}; parent_transform::Geometry.Transform = Transform(), debug::Bool=false, kwargs...) where {T<:Real}
   
    obj = draw!(scene, s.origins;  transform=parent_transform * s.transform, debug=debug, kwargs...)

    if (debug)
        m = zeros(T, length(s), 7)
        for (index, optical_ray) in enumerate(s)
            ray = OpticSim.ray(optical_ray)
            ray = parent_transform * ray
            m[index, 1:7] = [ray.origin... ray.direction... OpticSim.power(optical_ray)]
        end
        
        m[:, 4:6] .*= m[:, 7] * EmittersConsts.ARRROW_LENGTH * visual_size(s.origins)  

        base_so = obj[:scene_object]


        
        points = Vector{SVector{3, Float64}}(undef, size(m)[1] * 2)
        for i in 1:size(m)[1]
            point = SVector(m[i,1], m[i, 2], m[i, 3])
            dir = SVector(m[i,4], m[i, 5], m[i, 6])
            point2 = point + dir
            index = (i-1) * 2 + 1
            points[index] = point
            points[index+1] = point2
        end

        @info typeof(points)
        segments_mat = OpticSimVis.Material(color=RGBA(0.9, 0.9, 0.1, 0.5))
        segments = OpticSimVis.LineSegments(points; 
            tr=Transform(Vec3(0.0, 0.0, 0.0)), 
            material=segments_mat, 
            name="Debug Rays")
        OpticSimVis.set_parent!(segments, base_so)
    

        # debug_so = EmptySceneObject(name="Debug")
        # OpticSimVis.set_parent!(debug_so , base_so)

        # arrow_mat = OpticSimVis.Material(color=RGBA(0.7, 0.7, 0.1, 0.5))
        # for i in 1:size(m)[1]
        #     point = SVector(m[i,1], m[i, 2], m[i, 3])
        #     dir = SVector(m[i,4], m[i, 5], m[i, 6])
        #     point2 = point + dir
        #     arrow = OpticSimVis.Arrow(point, point2; material=arrow_mat, name="Arrow_$i")
        #     OpticSimVis.set_parent!(arrow , debug_so)
        # end

        # Makie.arrows!(scene, [Makie.Point3f0(origin(ray))], [Makie.Point3f0(rayscale * direction(ray))]; kwargs..., arrowsize = min(0.05, rayscale * 0.05), arrowcolor = color, linecolor = color, linewidth = 2)
        # color = :yellow
        # arrow_size = ARRROW_SIZE * visual_size(s.origins)
        # Makie.arrows!(scene, m[:,1], m[:,2], m[:,3], m[:,4], m[:,5], m[:,6]; kwargs...,  arrowcolor=color, linecolor=color, arrowsize=arrow_size, linewidth=arrow_size*0.5)
    end

    return obj
end



