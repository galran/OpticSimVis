
module UIControls

using Parameters
import UUIDs

export Slider, Button, Field, value, on, asInt

abstract type AbstractUIControl end

# mutable struct Slider <: UIControl
# end

# typedict(x) = Dict(fn=>getfield(x, fn) for fn ∈ fieldnames(typeof(x)))
typedict(x) = Dict(fn=>getfield(x, fn) for fn ∈ filter(x->!startswith(string(x), "_"), fieldnames(typeof(x))))

function on(func::Function, control::AbstractUIControl)
    control._func = func    
end

function asInt(control::AbstractUIControl)::Int
    try
        val = value(control)
        @show val, typeof(val)
        if (isa(val, String))
            return Int(floor(parse(Float64, val)))
        end
        if (isa(val, Int64))
            return val
        end
        if (isa(val, Float64))
            return Int(floor(val))
        end
    catch
        return 0
    end
end

function asFloat(control::AbstractUIControl)::Int
    try
        val = value(control)
        if (isa(val, String))
            return parse(Float64, val)
        end
        if (isa(val, Int))
            return convert(Float64, val)
        end
        if (isa(val, Float64))
            return val
        end
        @error "should not reach here"
    catch
        return 0
    end
end

@with_kw mutable struct Slider <: AbstractUIControl 
    type::String = "slider"
    id::String = string(UUIDs.uuid1())
    caption::String = "default slider"
    min::Float64 = 0.0
    max::Float64 = 100.0
    value::Float64 = 0
    step::Float64 = 1.0

    _func::Union{Nothing, Function} = nothing
end
value(c::Slider) = c.value

@with_kw mutable struct Button <: AbstractUIControl 
    type::String = "button"
    id::String = string(UUIDs.uuid1())
    caption::String = "default button"
    text::String = "Click"

    _func::Union{Nothing, Function} = nothing
end
value(c::Button) = c.text

@with_kw mutable struct Field <: AbstractUIControl 
    type::String = "field"
    id::String = string(UUIDs.uuid1())
    caption::String = "default field"
    value::String = "Click"

    _func::Union{Nothing, Function} = nothing
end
value(c::Field) = c.value


end # module UIControlsget