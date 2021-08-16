
module JuliaJSBridge

using WebIO, Observables, Blink

export JuliaJS

function HTMLFromObj(obj)
    io = IOBuffer()
	Base.show(io, MIME"text/html"(), obj)
    res = String(take!(io))
 
    return res
end


mutable struct JuliaJS
    _win::Blink.Window
    _scope::WebIO.Scope
    _obs::Observable
    _update_func::Union{Nothing, Function}
    _update_func_tag::Any       # an additional parameter to be sent to the function
end

win(jjs::JuliaJS) = jjs._win
scope(jjs::JuliaJS) = jjs._scope
obs(jjs::JuliaJS) = jjs._obs
update_func(jjs::JuliaJS) = jjs._update_func
update_func_tag(jjs::JuliaJS) = jjs._update_func_tag

function JuliaJS(win::Blink.Window; update_func::Union{Nothing, Function}=nothing, update_func_tag::Any=nothing)
    scope = Scope()

    update_obs = Observable(scope, "OnUpdateJulia", Dict{Any,Any}( "ran"=>"gal"))

    res = JuliaJS(win, scope, update_obs, update_func, update_func_tag)

    on(update_obs) do val
        onJuliaJSUpdate(res, val)
    end

    return res
end    

function onJuliaJSUpdate(jjs::JuliaJS, args)
    # @show p1
    # @show args

    if (update_func(jjs) !== nothing)
        update_func(jjs)(args, update_func_tag(jjs))
    end

    # if (p2["meta_data"]["OP"] == "HTMLRequest")
    #     guid = p2["meta_data"]["GUID"]
        
    #     @show p2["meta_data"]["From"]

    #     html = "?"

    #     # if (p2["meta_data"]["From"] == 1) 
    #     #     button_collapse_all1 = button("Button 1")
    #     #     on(button_collapse_all1) do val
    #     #         @info "Button 1"
    #     #     end
    #     #     html = HTMLFromObj(button_collapse_all1);
    #     # elseif (p2["meta_data"]["From"] == 2) 
    #     #     button_collapse_all2 = button("Button 2")
    #     #     on(button_collapse_all2) do val
    #     #         @info "Button 2"
    #     #     end
    #     #     html = HTMLFromObj(button_collapse_all2);
    #     # elseif (p2["meta_data"]["From"] == 3) 
    #     #     text_filter2 = textbox("Filter:")
    #     #     on(text_filter2) do val
    #     #         @info "text_filter" val
    #     #     end
    #     #     html = HTMLFromObj(text_filter2);
    #     # else
    #     #     temp = Node(:span,
    #     #         Node(:p, "This is sentence 1"),
    #     #         Node(:p, "This is sentence 22222"),
    #     #         Node(:p, "Source: $(p2["meta_data"]["From"])"),
    #     #     )

    #     #     html = HTMLFromObj(temp);
    #     # end


    #     # @info "Running The Code"
    #     # @info jjs
    #     # @js_ win(jjs) begin
    #     #     console.log("1234")
    #     #     JuliaJS.SetHTMLFromJulia($(guid), $(html))
    #     #     console.log("4321")
    #     # end
    #     # @info "After Running The Code"

    # end
end

function readLocalJSFile()
    fn = splitext(@__FILE__)[1] * ".js"
    data = read(fn)
    data = String(UInt8.(data))   # conver to a string from vector of bytes
    return data
end


function node(jj::JuliaJS)

    # @info jj._obs
    # @info typeof(jj._obs)
    # @info "OBS ID = [$(Observables.obsid(jj._obs))]"
    # @info "SCOPE ID = [$(WebIO.scopeid(jj._scope))]"
    scope_id = WebIO.scopeid(jj._scope);
    obs_id = Observables.obsid(jj._obs)
    
    js = readLocalJSFile()
    js = js * """
    console.log("Hi from JuliaJSCommunicator");

    JuliaJS["ToJulia"] = function (meta_data, data) {
        WebIO.setval(
            {
                "name":"OnUpdateJulia",
                "scope": "$(scope_id)",
                "id": "$(obs_id)",
                "type":"observable"
            },
            {
                "meta_data": meta_data,
                "data": data, 
            }
        );            
    }
    
    """


    res = Node(:dom,
        jj._scope,
        Node(:script, js),
    )


    return res;
end

"""
    JS_loader_node(filenames...)

Return a `WebIO.Node` object that contains all the supplied files as children nodes. Recognized extentions files such
as '.js' and '.css' are contains in a :script and :style nodes respectivly.
"""
function JS_loader_node(filenames...)
    nodes = []
    for filename in filenames
        ext = lowercase(splitext(filename)[2])
        data = read(filename)
        data = String(UInt8.(data))   # conver to a string from vector of bytes
        if (ext == ".js")
            push!(nodes, Node(:script, data))
        elseif (ext == ".css")
            push!(nodes, Node(:style, data))
        else
            push!(nodes, Node(:dom, data))
        end
    end
    
    return Node(:dom, nodes...)
end

function application_node(jjs::JuliaJS, app_dir::String)

    dist_dir = joinpath(app_dir, "dist", basename(app_dir))
    
    # if ther is no dist folder, assume the files are in the given folder    
    if (!isdir(dist_dir))
        dist_dir = app_dir   
    end

    @show dist_dir

    ls = readdir(dist_dir, join=true)

    node = Node(:dom, 
        JuliaJSBridge.node(jjs),
        JS_loader_node(joinpath(dirname(@__FILE__), "localjs.js")), 
        JS_loader_node(
            [fn for fn in ls if startswith(basename(fn), "styles")][1],
            [fn for fn in ls if startswith(basename(fn), "main")][1],
            [fn for fn in ls if startswith(basename(fn), "polyfills")][1],
            [fn for fn in ls if startswith(basename(fn), "runtime")][1],
        ),
    )
    
    return node
end



end # module JuliaJSBridge()