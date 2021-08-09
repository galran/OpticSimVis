

name(so::AbstractSceneObject) = so._name
geometry(so::AbstractSceneObject) = @error "method not implemented"
# components(so::AbstractSceneObject) = so._components

tr(so::AbstractSceneObject) = so._tr
function tr!(so::AbstractSceneObject, tr::Transform) 
    s._tr = tr
    # update scene
end

local_tr(so::AbstractSceneObject) = so._tr


vis(so::AbstractSceneObject) = so._vis
function vis!(so::AbstractSceneObject, vis::Visualizer) 
    so._vis = vis
end

scene(so::AbstractSceneObject) = so._scene
function scene!(so::AbstractSceneObject, s::AbstractScene) 
    s._scene = s
    # update scene
end

parent(so::AbstractSceneObject) = so._parent
function set_parent!(so::AbstractSceneObject, parent_so::AbstractSceneObject)
    so._parent = parent_so

    v = vis(parent(so))[name(so)]
    vis!(so, v)
    setobject!(v, geometry(so))

    settransform!(v, tr2affine(local_tr(so)))
end


#-----------------------------------------------------------------
mutable struct EmptySceneObject <: AbstractSceneObject
    _name::String
    _tr::Transform
    _vis::Union{Visualizer, Nothing}
    _scene::Union{AbstractScene, Nothing}
    _parent::Union{AbstractSceneObject, Nothing}

    function EmptySceneObject(;
        name::String = "defulatEmptySceneObject", 
        tr::Transform = identitytransform() 
    )
        return new(name, tr, nothing, nothing)
    end
end

function geometry(e::EmptySceneObject) 
    # dummy zero size box
    box = HyperRectangle(Vec(0., 0, 0), Vec(0., 0, 0))
    return box 
end

#-----------------------------------------------------------------

#-----------------------------------------------------------------
mutable struct Box <: AbstractSceneObject
    _name::String
    _tr::Transform
    _vis::Union{Visualizer, Nothing}
    _scene::Union{AbstractScene, Nothing}
    _parent::Union{AbstractSceneObject, Nothing}

    _size::SVector{3, Float64}

    function Box(;
        name::String = "defulatSceneObject", 
        tr::Transform = identitytransform(), 
        size::SVector{3, Float64} = SVector(1.0, 1.0, 1.0)
    )
        return new(name, tr, nothing, nothing, nothing, size)
    end
end

size(b::Box) = b._size

function geometry(b::Box) 
    box = HyperRectangle(Vec(0.0, 0.0, 0.0), Vec(size(b)...))
    return box 
end
#-----------------------------------------------------------------



# #-----------------------------------------------------------------
# mutable struct SceneObject
#     _name::String
#     _tr::Transform
#     _components::Vector{SceneComponent}

#     function SceneObject(name::String = "defulatSceneObject", tr::Transform = identitytransform())
#         return new(name, tr, [])
#     end
# end

# name(so::SceneObject) = so._name
# tr(so::SceneObject) = so._tr
# components(so::SceneObject) = so._components

# function add(so::SceneObject, sc::SceneComponent)
#     push!(components(so), sc)
# end
# #-----------------------------------------------------------------

# abstract type SceneComponent end

# #-----------------------------------------------------------------
# struct Box <: SceneComponent
#     _size::SVector{3, Float64}

#     function Box(size::SVector{3, Float64} = SVector(1.0, 1.0, 1.0))
#         return new(size)
#     end
# end

# size(b::Box) = b._size
# #-----------------------------------------------------------------


