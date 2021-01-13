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
	gr()
end

# ╔═╡ 44c8328a-542c-11eb-3b23-cf40ac15fccd
data = CSV.File("../data/circuit6.csv") |> DataFrame

# ╔═╡ 59b1a1d6-542c-11eb-1af9-e93e39232507
names(data)

# ╔═╡ 095f998a-542d-11eb-3083-0b26b709d295
@bind variable Select([string(i) => Symbol(i) for i ∈ names(data)])

# ╔═╡ 251344e6-542e-11eb-10bf-fd7d81778a4a
judges = unique(data[:, :judge])

# ╔═╡ 85ff03b4-542c-11eb-3a31-d5b3d01d6065
missing_filter(df :: DataFrame, name :: String) = begin
	sub = df[:, [:judge, Symbol(name)]]
	return sub[completecases(sub), :]
end

# ╔═╡ 062d6b88-55e1-11eb-046a-1b69265dc4a8
function compare_across_judges(data :: DataFrame, variable :: String)
	@df missing_filter(data, variable) histogram(
		cols(Symbol(variable)),
		group=:judge,
		opacity=0.5
	)
end

# ╔═╡ 944c2e9a-55e1-11eb-1c60-1baa43817c80
compare_across_judges(data, variable)

# ╔═╡ Cell order:
# ╠═a0f92f18-542d-11eb-1a5a-cf851148a599
# ╠═44c8328a-542c-11eb-3b23-cf40ac15fccd
# ╠═59b1a1d6-542c-11eb-1af9-e93e39232507
# ╟─095f998a-542d-11eb-3083-0b26b709d295
# ╠═944c2e9a-55e1-11eb-1c60-1baa43817c80
# ╠═251344e6-542e-11eb-10bf-fd7d81778a4a
# ╠═062d6b88-55e1-11eb-046a-1b69265dc4a8
# ╟─85ff03b4-542c-11eb-3a31-d5b3d01d6065
