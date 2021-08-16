


struct Scene <: AbstractScene
    _vis::MeshCat.Visualizer
    _windows::Union{Blink.Window, Nothing}
    _root::AbstractSceneObject

    function Scene(; openWindow::Bool = false)
        vis = MeshCat.Visualizer()
 
        win = nothing
        if (openWindow)
            window_defaults = Blink.@d(
                :title => "OpticSim Viewer", 
                :width=>1200, 
                :height=>800,
            )
            win = Blink.Window(window_defaults)
            
            Blink.AtomShell.opentools(win)
            open(vis, win)
        end
 
        root = prepare_scene!(vis)

        return new(vis, win, root)
    end

    function Scene(vis::MeshCat.Visualizer)
        vis = MeshCat.Visualizer()

        # make sure this is an OpticSim Scene
        root = vis["OpticSim"]
        @assert root !== nothing

        return new(vis, nothing, root)
    end
end

# returns the URL for the local server
url(s::Scene) = MeshCat.url(s._vis.core)

vis(s::Scene) = s._vis
win(s::Scene) = s._window
root(s::Scene) = s._root

function clear(s::Scene)
    root_so = root(s)
    root_children = prop(root_so, :children)
    while(length(root_children) > 0)
        delete!(root_children[1])
        root_children = prop(root_so, :children)
    end

    # index = findfirst(x -> x===so, parent_children)
    # if (index === nothing)
    #     @error "Can't find the child $(name(so)) to delete"
    # end
    # deleteat!(parent_children, index)

    # v = vis(so)
    # delete!(v)
end

function prepare_scene!(vis::MeshCat.Visualizer)
    root = EmptySceneObject(name="OpticSim")
    root_vis = vis["OpticSim"]
    vis!(root, root_vis)

    # flip Y and Z axes
    MeshCat.settransform!(root_vis, tr2affine(Transform(unitX3(), unitZ3(), unitY3())))

    return root
end

function set_camera!(s::Scene, tr::Transform)
    cam_vis = vis(s)["/Cameras/default/rotated/<object>"]

    MeshCat.settransform!(cam_vis, tr2affine(tr))
end

function set_Y_up!(s::Scene)
    MeshCat.settransform!(vis(s), tr2affine(Transform(unitX3(), unitZ3(), unitY3())))
end

function set_Z_up!(s::Scene)
    MeshCat.settransform!(vis(s), tr2affine(Transform(unitX3(), unitY3(), unitZ3())))
end


# function add!(s::Scene, so::AbstractSceneObject)
#     path = MeshCat.Path(["OpticSim", name(so)])
#     @info path

#     scene!(so, s)

#     vis = setobject!(toor(root(s)[path], box, green_material)

#     root(s)[name(so)] = 
# end




