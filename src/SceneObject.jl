

name(so::AbstractSceneObject) = so._name
geometry(so::AbstractSceneObject) = @error "method not implemented"
# components(so::AbstractSceneObject) = so._components

tr(so::AbstractSceneObject) = so._tr
function tr!(so::AbstractSceneObject, tr::Transform) 
    s._tr = tr
    # update scene
end

local_tr(so::AbstractSceneObject) = so._tr
function local_tr!(so::AbstractSceneObject, local_tr::Transform) 
    so._tr = local_tr
    update!(so)
    # update scene
end


vis(so::AbstractSceneObject) = so._vis
function vis!(so::AbstractSceneObject, vis::MeshCat.Visualizer) 
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

    update!(so)
end

material(so::AbstractSceneObject) = so._material
function material!(so::AbstractSceneObject, mat::Material)
    so._material = mat
    update!(so)
end


function update!(so::AbstractSceneObject)
    v = vis(parent(so))[name(so)]
    vis!(so, v)

    render!(so)
end

#-----------------------------------------------------------------
mutable struct EmptySceneObject <: AbstractSceneObject
    _name::String
    _tr::Transform
    _vis::Union{MeshCat.Visualizer, Nothing}
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
    box = GeometryBasics.HyperRectangle(GeometryBasics.Vec(0., 0, 0), GeometryBasics.Vec(0., 0, 0))
    return box 
end

function render!(e::EmptySceneObject) 
end


#-----------------------------------------------------------------
# Box
#-----------------------------------------------------------------
mutable struct Box <: AbstractSceneObject
    _name::String
    _tr::Transform
    _vis::Union{MeshCat.Visualizer, Nothing}
    _scene::Union{AbstractScene, Nothing}
    _parent::Union{AbstractSceneObject, Nothing}
    _material::Union{Material, Nothing}

    _size::SVector{3, Float64}

    function Box(;
        name::String = "defulatBoxObject", 
        tr::Transform = identitytransform(), 
        size::SVector{3, Float64} = SVector(1.0, 1.0, 1.0),
        material::Union{Material, Nothing} = nothing,
        parent = nothing 
    )
        return new(name, tr, nothing, nothing, parent, material, size)
    end
end

Base.size(b::Box) = b._size

# function geometry(b::Box) 
#     min_point = size(b) * -0.5

#     return box 
# end

function render!(b::Box) 
    v = vis(b)
    min_point = size(b) * -0.5
    mat = material(b)
    box = GeometryBasics.HyperRectangle(GeometryBasics.Vec(min_point...), GeometryBasics.Vec(size(b)...))
    if (mat !== nothing)
        MeshCat.setobject!(v, box, material(mat))
    else
        MeshCat.setobject!(v, box)
    end

    MeshCat.settransform!(v, tr2affine(local_tr(b)))
end

#-----------------------------------------------------------------
# MeshCat.Mesh
#-----------------------------------------------------------------
mutable struct Mesh <: AbstractSceneObject
    _name::String
    _tr::Transform
    _vis::Union{MeshCat.Visualizer, Nothing}
    _scene::Union{AbstractScene, Nothing}
    _parent::Union{AbstractSceneObject, Nothing}
    _material::Union{Material, Nothing}

    _mesh::GeometryBasics.AbstractMesh

    function Mesh(mesh::GeometryBasics.AbstractMesh;
        name::String = "defulatMeshObject", 
        tr::Transform = identitytransform(), 
        material::Union{Material, Nothing} = nothing,
        parent = nothing
    )
        return new(name, tr, nothing, nothing, parent, material, mesh)
    end
end

mesh(m::Mesh) = m._mesh


function render!(m::Mesh) 
    v = vis(m)
    mat = material(m)
    if (mat !== nothing)
        MeshCat.setobject!(v, mesh(m), material(mat))
    else
        MeshCat.setobject!(v, mesh(m))
    end

    MeshCat.settransform!(v, tr2affine(local_tr(m)))
end

#-----------------------------------------------------------------

#-----------------------------------------------------------------
# Arrow
#-----------------------------------------------------------------
mutable struct Arrow <: AbstractSceneObject
    _name::String
    _tr::Transform
    _vis::Union{MeshCat.Visualizer, Nothing}
    _scene::Union{AbstractScene, Nothing}
    _parent::Union{AbstractSceneObject, Nothing}
    _material::Union{Material, Nothing}

    _from::SVector{3, Float64}
    _to::SVector{3, Float64}

    function Arrow(from::SVector{3, Float64}, to::SVector{3, Float64};
        name::String = "defulatMeshObject", 
        tr::Transform = identitytransform(), 
        material::Union{Material, Nothing} = nothing,
        parent = nothing
    )
        return new(name, tr, nothing, nothing, parent, material, from, to)
    end
end

from(a::Arrow) = a._from
to(a::Arrow) = a._to

function render!(a::Arrow) 
    v = vis(a)
    mat = material(a)
    if (mat === nothing)
        mat = Material()
    end

    f = from(a)
    t = to(a)
    vec = t - f
    point = GeometryBasics.Point(f...)
    vec = GeometryBasics.Vec((t - f)...)

    arrow = MeshCat.ArrowVisualizer(v)
    MeshCat.setobject!(arrow, material(mat))
    MeshCat.settransform!(arrow, point, vec, shaft_radius=0.1)
end
#-----------------------------------------------------------------

#-----------------------------------------------------------------
# Axes
#-----------------------------------------------------------------
mutable struct Axes <: AbstractSceneObject
    _name::String
    _tr::Transform
    _vis::Union{MeshCat.Visualizer, Nothing}
    _scene::Union{AbstractScene, Nothing}
    _parent::Union{AbstractSceneObject, Nothing}
    _material::Union{Material, Nothing}

    _scale::SVector{3, Float64}

    function Axes(scale::SVector{3, Float64} = SVector(1.0, 0.6, 0.6);
        name::String = "defulatAxesObject", 
        tr::Transform = identitytransform(), 
        material::Union{Material, Nothing} = nothing,
        parent = nothing
    )
        return new(name, tr, nothing, nothing, parent, material, scale)
    end
end

scale(a::Axes) = a._scale

function render!(a::Axes) 
    v = vis(a)
    mat = material(a)
    if (mat === nothing)
        mat = Material()
    end

    point = GeometryBasics.Point(0.0, 0.0, 0.0)

    color!(mat, Colors.RGBA(0.9, 0.1, 0.1, 1.0))
    vec = GeometryBasics.Vec(1.0, 0.0, 0.0)
    arrow = MeshCat.ArrowVisualizer(v["X"])
    MeshCat.setobject!(arrow, material(mat))
    MeshCat.settransform!(arrow, point, vec, shaft_radius=0.1)

    color!(mat, Colors.RGBA(0.1, 0.9, 0.1, 1.0))
    vec = GeometryBasics.Vec(0.0, 1.0, 0.0)
    arrow = MeshCat.ArrowVisualizer(v["Y"])
    MeshCat.setobject!(arrow, material(mat))
    MeshCat.settransform!(arrow, point, vec, shaft_radius=0.1)

    color!(mat, Colors.RGBA(0.1, 0.1, 0.9, 1.0))
    vec = GeometryBasics.Vec(0.0, 0.0, 1.0)
    arrow = MeshCat.ArrowVisualizer(v["Z"])
    MeshCat.setobject!(arrow, material(mat))
    MeshCat.settransform!(arrow, point, vec, shaft_radius=0.1)

    @info local_tr(a)
    MeshCat.settransform!(v, tr2affine(local_tr(a)))
end
#-----------------------------------------------------------------

#-----------------------------------------------------------------
# Line Segments
#-----------------------------------------------------------------
mutable struct LineSegments <: AbstractSceneObject
    _name::String
    _tr::Transform
    _vis::Union{MeshCat.Visualizer, Nothing}
    _scene::Union{AbstractScene, Nothing}
    _parent::Union{AbstractSceneObject, Nothing}
    _material::Union{Material, Nothing}

    _points::Vector{SVector{3, Float64}}

    function LineSegments(points::Vector{SVector{3, Float64}} = [];
        name::String = "defulatMeshObject", 
        tr::Transform = identitytransform(), 
        material::Union{Material, Nothing} = nothing,
        parent = nothing
    )
        return new(name, tr, nothing, nothing, parent, material, points)
    end
end

points(ls::LineSegments) = ls._points


function render!(ls::LineSegments) 
    v = vis(ls)
    mat = material(ls)

    pts = points(ls)
    pts2 = GeometryBasics.Point.(pts)

    # @info lines_material(mat)
    # @info lines_material(mat)
    if (mat !== nothing)
        MeshCat.setobject!(v, MeshCat.LineSegments(GeometryBasics.Point.(points(ls)), lines_material(mat)))
    else
        MeshCat.setobject!(v, MeshCat.LineSegments(GeometryBasics.Point.(points(ls))))
    end
    MeshCat.settransform!(v, tr2affine(local_tr(ls)))
end

#-----------------------------------------------------------------
