
module UIControls

using Parameters
import UUIDs

export Slider, Button, Field, value, on

abstract type AbstractUIControl end

# mutable struct Slider <: UIControl
# end

# typedict(x) = Dict(fn=>getfield(x, fn) for fn ∈ fieldnames(typeof(x)))
typedict(x) = Dict(fn=>getfield(x, fn) for fn ∈ filter(x->!startswith(string(x), "_"), fieldnames(typeof(x))))

function on(func::Function, control::AbstractUIControl)
    control._func = func    
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