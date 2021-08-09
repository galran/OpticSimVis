module OpticSimVis

greet() = println("Hello World!")

using Blink

using MeshCat
using CoordinateTransformations
using Rotations
using GeometryBasics: HyperRectangle, Vec, Point, Mesh
using Colors: RGBA, RGB

using OpticSim, OpticSim.Geometry
using StaticArrays

include("Misc.jl")
include("SceneObject.jl")
include("Scene.jl")
 
end # module
