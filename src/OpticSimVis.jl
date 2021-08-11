module OpticSimVis

greet() = println("Hello World!")

using Blink

import MeshCat
using CoordinateTransformations
using Rotations
import GeometryBasics
# using GeometryBasics: HyperRectangle, Vec, Point, Mesh
using Colors: RGBA, RGB
import Colors
import FileIO
import MeshIO

using OpticSim, OpticSim.Geometry, OpticSim.Emitters
using StaticArrays
import UUIDs

include("Misc.jl")
include("Material.jl")
include("SceneObject.jl")
include("Scene.jl")

include("OpticSimAPI/General.jl")
include("OpticSimAPI/Emitters.jl")
 
end # module
