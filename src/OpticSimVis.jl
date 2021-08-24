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
import ColorSchemes
import FileIO
import MeshIO

using OpticSim, OpticSim.Geometry, OpticSim.Emitters
using StaticArrays
import UUIDs
import Base64

include("Misc.jl")
include("Material.jl")
include("SceneObject.jl")
include("Scene.jl")

include("OpticSimAPI/General.jl")
include("OpticSimAPI/Emitters.jl")
include("OpticSimAPI/HeadEyeModel.jl")

include("JSInterface/JuliaJSBridge.jl")
include("UI/UIVariables.jl")
include("UI/UIControls.jl")
include("UI/SimpleUI.jl")
include("UI/FlexUI.jl")

using ..UIControls
using ..UIVariables
using ..SimpleUI

# export UIVariables
# export FlexUI

        
#------------------------------------------------------------------------------
# EXports
#------------------------------------------------------------------------------
export  BasicValidation, on, Variable

export  Container,
        Slider,
        Button,        
        MeshCatViewer,
        Label,
        Image,
        PanZoom,
        Field,
        ButtonToggle,
        RadioGroup,
        CheckBox,
        ExpansionPanel, 
        Accordion,
        Tabs,
        Tab,

        VContainer,
        HContainer,
        H1Label,
        H2Label,
        H3Label,
        H4Label,

        DummyExport

export FlexUI        

end # module
