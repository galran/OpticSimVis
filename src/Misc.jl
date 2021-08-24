
# declaration of basic types 
abstract type AbstractScene end
abstract type AbstractSceneObject end
abstract type AbstractMaterial end
abstract type AbstractUIApp end
abstract type AbstractUIVariable end
abstract type AbstractUIValidation end
abstract type AbstractUIControl end

export  AbstractScene,
        AbstractSceneObject,
        AbstractMaterial,
        AbstractUIApp,
        AbstractUIVariable,
        AbstractUIValidation,
        AbstractUIControl


function updateVariable!(app::AbstractUIApp, var::AbstractUIVariable)
    @error "abstract function - should not reach here"
end

show_png(io, x) = show(io, MIME"image/png"(), x)
show_svg(io, x) = show(io, MIME"image/svg+xml"(), x)

base64png(img) = "data:image/png;base64,$(Base64.base64encode(show_png, img))"
base64svg(img) = "data:image/svg+xml;base64,$(Base64.base64encode(show_svg, img))"


#---------------------------------------------------------------
#   Transform to AffineMat that can be used in the renderer
#---------------------------------------------------------------
function tr2affine(tr::Transform)
    return AffineMap(tr[1:3,1:3], Geometry.origin(tr))
end


#---------------------------------------------------------------
#   Color conversion methods
#---------------------------------------------------------------
function to_color(c::Tuple{Int64, Int64, Int64})
    return Colors.RGBA((c ./ 255)...)
end

function to_color(c::Tuple{Float64, Int64, Int64})
    return Colors.RGBA(c...)
end

function to_color(c::Colors.RGBA)
    return c
end

function to_color(c::Colors.RGB)
    return RGBA(c)
end

function to_color(c::Symbol)
    return return to_color(Colors.color_names[string(c)])
end


#---------------------------------------------------------------
#   TriangleMesh to GeometryBasics.Mesh that can be rendered
#---------------------------------------------------------------
function to_mesh(tm::OpticSim.TriangleMesh{T}) where {T<:Real}
    len = length(tm.triangles)
    points = Vector{GeometryBasics.Point3{Float64}}(undef, len * 3)
    indices = Vector{GeometryBasics.TriangleFace{Int64}}(undef, len)
    @inbounds @simd for i in 0:(len - 1)
        t = tm.triangles[i + 1]
        points[i * 3 + 1] = OpticSim.vertex(t, 1)
        points[i * 3 + 2] = OpticSim.vertex(t, 2)
        points[i * 3 + 3] = OpticSim.vertex(t, 3)
        indices[i + 1] = GeometryBasics.TriangleFace{Int64}(i * 3 + 1, i * 3 + 2, i * 3 + 3)
    end

    # create the mesh
    mesh = GeometryBasics.Mesh(points, indices)
    return mesh
end
