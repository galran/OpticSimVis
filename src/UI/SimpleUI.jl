
module SimpleUI

import Blink
import ..JuliaJSBridge
import ..UIControls
import ..OpticSimVis
import WebIO

export  App, 
        win, 
        jjs, 
        controls, controls!, 
        viewerUrl, viewerUrl!, 
        renderFunction, renderFunction!,
        run

mutable struct App
    _win::Union{Nothing, Blink.Window}
    _jjs::Union{Nothing, JuliaJSBridge.JuliaJS}

    _controls::Vector{UIControls.AbstractUIControl}
    _viewer_url::String
    _render_function::Union{Nothing, Function}
end

function App(; 
    controls::Vector, 
    viewer_url::String, 
    render_function::Union{Nothing, Function} = nothing
)
    app = App(nothing, nothing, Vector{UIControls.AbstractUIControl}[], "", nothing)
    controls!(app, controls)
    viewerUrl!(app, viewer_url)
    renderFunction!(app, render_function)
    return app
end


OpticSimVis.win(app::App) = app._win
function win!(app::App, win::Blink.Window)
    app._win = win
end

jjs(app::App) = app._jjs
function jjs!(app::App, jjs::JuliaJSBridge.JuliaJS)
    app._jjs = jjs
end

controls(app::App) = app._controls
function controls!(app::App, controls::Vector)
    app._controls = convert(Vector{UIControls.AbstractUIControl}, controls)
end

viewerUrl(app::App) = app._viewer_url
function viewerUrl!(app::App, url::String)
    app._viewer_url = url
end

renderFunction(app::App) = app._render_function
function renderFunction!(app::App, render_func::Function)
    app._render_function = render_func
end

function Base.run(app::App)
    window_defaults = Blink.@d(
        :title => "Ran Gal", 
        :width => 1600, 
        :height => 1200,
        # this will allow us to load local file which is a security risk
        :webPreferences => Blink.@d(:webSecurity => false)
    )
    win =Blink. Window(window_defaults)

    win!(app, win)

    bridge = JuliaJSBridge.JuliaJS(win; update_func=onControlsUpdate, update_func_tag=app)
    jjs!(app, bridge)

    app_dir = raw"D:\Projects\Rays\Tests\UI\SimpleUI\dist\SimpleUI"
    app_node = JuliaJSBridge.application_node(jjs(app), app_dir)
    
    ui = WebIO.Node(:dom, 
        app_node,
        WebIO.Node(Symbol("app-root"), ""),
    )

    # show the blink window
    Blink.body!(win, ui, async=false)
    Blink.AtomShell.opentools(win)

    # set the controls through JavaScript and also the viewer url
    js_controls = [UIControls.typedict(c) for c in controls(app)]
    viewer_url = viewerUrl(app)
    Blink.@js_ win begin
        # JuliaJS.SetHTMLFromJulia($(guid), $(html))
        # console.log("Controls", $(js_controls))
        window.fireAngularEvent("setUIControls", [$(js_controls)])
        window.fireAngularEvent("setViewerUrl", [$(viewer_url)])
    end


end

function onControlsUpdate(args::Dict{Any, Any}, app)
    data = args["data"]
    id = data["id"]
    index = findfirst(x -> x.id == id, controls(app))
    c = controls(app)[index]

    # get the new value
    val = nothing
    if (data["type"] == "slider")
        val = get(data, "value", 0.0)
        c.value = val
    elseif (data["type"] == "button")
        val = get(data, "text", "")
    elseif (data["type"] == "field")
        val = get(data, "value", "")
        c.value = string(val)
    else
        @error "unrecognized control type"
    end

    if (c._func !== nothing)
        c._func(val)
    end

    if (renderFunction(app) !== nothing)
        renderFunction(app)()
    end

end

end # modeule SimpleUI