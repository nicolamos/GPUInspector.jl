module CairoMakieExt

using GPUInspector
import GPUInspector: MonitoringResults, _defaultylims, _symbol2title_and_label, savefig_monitoring_results
using CairoMakie

function savefig_monitoring_results(
    r::MonitoringResults, symbols=keys(r.results); ext=:pdf
)
    if symbols isa Symbol
        _savefig_monitoring_results(r, symbols; ext)
    else
        for s in symbols
            _savefig_monitoring_results(r, s; ext)
        end
    end
    return nothing
end

function savefig_monitoring_results(filename::String, r::MonitoringResults; symbol=nothing)
    if isnothing(symbol)
        # if no symbol is provided, we pick the first one
        symbol = first(keys(r.results))
    end
    _savefig_monitoring_results(r, symbol; filename)
    return nothing
end

function _savefig_monitoring_results(r::MonitoringResults, s::Symbol; ext=:pdf, filename=nothing)
    times = r.times
    values = r.results[s]
    title, ylabel = _symbol2title_and_label(s)
    ylims = _defaultylims(values)
    device_labels = [str for (str, uuid) in r.devices]

    f = CairoMakie.Figure(; size=(1000, 500))
    ax = f[1, 1] = CairoMakie.Axis(f; xlabel="Time [s]", ylabel=ylabel, title=title)
    ylims!(ax, ylims)
    CairoMakie.scatterlines!(times, getindex.(values, 1); label=device_labels[1])
    for i in 2:length(first(values))
        CairoMakie.scatterlines!(times, getindex.(values, i); label=device_labels[i])
    end
    f[1, 2] = CairoMakie.Legend(f, ax, "Devices"; framevisible=false)
    
    if isnothing(filename)
        filename =
            replace(replace(replace(lowercase(title), " " => "_"), "(" => ""), ")" => "") *
            "_plot.$(string(ext))"
    end
    CairoMakie.save(filename, f)
    return nothing
end

end # module