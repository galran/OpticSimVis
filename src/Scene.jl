


struct Scene <: AbstractScene
    _vis::Visualizer
    _windows::Union{Blink.Window, Nothing}
    _root::AbstractSceneObject

    function Scene()
        vis = Visualizer()
        win = Blink.Window()
        Blink.AtomShell.opentools(win)
        open(vis, win)
 
        root = prepare_scene!(vis)

        return new(vis, win, root)
    end

    function Scene(vis::Visualizer)
        vis = Visualizer()

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


function prepare_scene!(vis::Visualizer)
    root = EmptySceneObject(name="OpticSim")
    root_vis = vis["OpticSim"]
    vis!(root, root_vis)
    return root
end

# function add!(s::Scene, so::AbstractSceneObject)
#     path = MeshCat.Path(["OpticSim", name(so)])
#     @info path

#     scene!(so, s)

#     vis = setobject!(toor(root(s)[path], box, green_material)

#     root(s)[name(so)] = 
# end




