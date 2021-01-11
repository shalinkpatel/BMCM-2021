### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ a0f92f18-542d-11eb-1a5a-cf851148a599
begin
	using Plots, StatsPlots, CSV, DataFrames, DataFramesMeta, Turing, Pipe, PlutoUI
	plotly()
end

# ╔═╡ 44c8328a-542c-11eb-3b23-cf40ac15fccd
data = CSV.File("../data/filtered_dataset.csv") |> DataFrame

# ╔═╡ 59b1a1d6-542c-11eb-1af9-e93e39232507
names(data)

# ╔═╡ 095f998a-542d-11eb-3083-0b26b709d295
@bind variable Select([string(i) => i for i ∈ names(data)])

# ╔═╡ 251344e6-542e-11eb-10bf-fd7d81778a4a
unique(data[:, :judge])

# ╔═╡ 85ff03b4-542c-11eb-3a31-d5b3d01d6065
missing_filter(df :: DataFrame, name :: String) = filter(x -> !ismissing(x), df[:, Symbol(name)])

# ╔═╡ 5c5c2e7e-542c-11eb-2f6e-d5d55be90f33
histogram(missing_filter(data, variable), legend=false, title="Distribution of $(variable)")

# ╔═╡ Cell order:
# ╠═a0f92f18-542d-11eb-1a5a-cf851148a599
# ╠═44c8328a-542c-11eb-3b23-cf40ac15fccd
# ╠═59b1a1d6-542c-11eb-1af9-e93e39232507
# ╟─095f998a-542d-11eb-3083-0b26b709d295
# ╠═5c5c2e7e-542c-11eb-2f6e-d5d55be90f33
# ╠═251344e6-542e-11eb-10bf-fd7d81778a4a
# ╟─85ff03b4-542c-11eb-3a31-d5b3d01d6065
