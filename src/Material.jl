




#-----------------------------------------------------------------
mutable struct Material <: AbstractMaterial

    _color::RGBA{Float64}
    _line_width::Float64
    _wireframe::Bool
    _wireframe_line_width::Float64
end

function Material(;
    color = Colors.color_names["magenta"],
    line_width::Float64  = 1.0, 
    wireframe::Bool = false, 
    wireframe_line_width::Float64  = 1.0,
    kwargs...)
    return Material(to_color(color), line_width, wireframe, wireframe_line_width)
end



color(m::Material) = m._color
function color!(m::Material, color::RGBA{Float64}) 
    m._color = color
end

lineWidth(m::Material) = m._line_width
wireframe(m::Material) = m._wireframe
wireframeLineWidth(m::Material) = m._wireframe_line_width

function material(m::Material) 
    mat = MeshCat.MeshPhongMaterial(
        color=color(m),
        linewidth = lineWidth(m),
        wireframe = wireframe(m),
        wireframeLinewidth = wireframeLineWidth(m),
    )
    return mat
end

function lines_material(m::Material) 
    mat = MeshCat.LineBasicMaterial(
        color=color(m),
        linewidth = lineWidth(m),
        wireframe = wireframe(m),
        wireframeLinewidth = wireframeLineWidth(m),
    )
    return mat
end

#-----------------------------------------------------------------
