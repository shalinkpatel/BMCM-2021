### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ d84e151c-5687-11eb-10d6-6f2de1177528
begin
	include("util.jl")
	include("generation/sentencing.jl")
	using CSV, DataFrames, Plots, StatsPlots
	gr()
end

# ╔═╡ 71f73f02-56df-11eb-0fde-195f836871e8
using Pipe, Distributions

# ╔═╡ 8bb5e48c-583f-11eb-0676-65d8502a1304
using StatsBase

# ╔═╡ f794bfb8-5687-11eb-0324-1f5626746d50
raw_data = CSV.File("../data/circuit6.csv") |> DataFrame;

# ╔═╡ 11d321ce-56dd-11eb-1671-8b2309f365e5
md"
### All Judges
"

# ╔═╡ 2b7680bc-568a-11eb-11a1-5f27d61f7e5e
all_judges = filter_data(raw_data);

# ╔═╡ a7e807d2-5689-11eb-21d9-a9b563b8f98e
all_judges_profile = JudgeProfile(all_judges);

# ╔═╡ ba5f9992-568a-11eb-296e-43303a0d10c9
begin
	sample_point = (all_judges_profile.profile[7, :] |> Array)[((1:3) ∪ (5:(end-1)))]
	sentencing = sentencing_generation(all_judges_profile, sample_point, 1000)
	plot(sentencing[:, 1:2, :])
end

# ╔═╡ 265cdd4c-56dd-11eb-3bac-3f9ef7e90325
md"
### Compare Two Judges
"

# ╔═╡ f055e2fc-568c-11eb-3251-79bf593a138d
judges = unique(raw_data[:, :judge])

# ╔═╡ fe2faff4-568c-11eb-23a1-17c8b722a9b8
john_profile = JudgeProfile(select_judge(raw_data, judges[1]));

# ╔═╡ e57203d0-568d-11eb-003a-39ce4822da5d
william_profile = JudgeProfile(select_judge(raw_data, judges[2]));

# ╔═╡ 441a7b9e-568f-11eb-2c10-5ddd73fe4c5e
profiles = [all_judges_profile, john_profile, william_profile];

# ╔═╡ bdebb8c0-568f-11eb-2678-f3dfbdfd3844
profile_names = ["all judges", "john", "william"]

# ╔═╡ 6a2033ce-568f-11eb-1c73-779d61cbbf8d
begin
	plots = [plot(title=name) for name ∈ ["Age", "Citizen", "Crimhist", "Sex", "Educ", "Race"]]
	for (i, profile) ∈ enumerate(profiles)
		plot!(plots[1], profile.age_dist, label=profile_names[i])
		plot!(plots[2], profile.citizen_dist, label=profile_names[i])
		plot!(plots[3], profile.crimhist_dist, label=profile_names[i])
		plot!(plots[4], profile.monsex_dist, label=profile_names[i])
		plot!(plots[5], profile.neweduc_dist, label=profile_names[i])
		plot!(plots[6], profile.newrace_dist, label=profile_names[i])
	end
	plot(plots..., legend=:outertopright, layout=(3, 2))
end

# ╔═╡ 0fe0ec94-56dc-11eb-09d0-afd73f29a3a6
begin
	density(john_profile.profile[:, :PRISTOT], label="John", title="PRISTOT Dist")
	density!(william_profile.profile[:, :PRISTOT], label="William")
end

# ╔═╡ 042c5750-56dd-11eb-225b-f33351bc9a5d
md"
### Effective Comparison
We check to see if this is akin to random selection
"

# ╔═╡ 7ebe2876-56dd-11eb-37a7-ab1550d397f2
begin
	choices = rand(size(all_judges, 1)) .< 0.5;
	john_data = all_judges[choices, :];
	william_data = all_judges[.!choices, :];
end

# ╔═╡ 1ca6e986-56de-11eb-354b-ad996f427da4
function generate_posterier(data :: DataFrame, judge :: JudgeProfile)
	samples = []
	for i ∈ 1:size(data, 1)
		sample_point = (data[i, :] |> Array)[((1:3) ∪ (5:(end-1)))]
		sentencing = sentencing_generation(judge, sample_point, 100)
		samples = vcat(samples, sentencing[:pristot] |> Array)
	end
	return samples
end

# ╔═╡ ab39e89c-56de-11eb-2a54-e7d45b70eb5b
john_posterior = @pipe generate_posterier(john_data, john_profile) |> Float64.(_) |> reshape(_, size(_ ,1))

# ╔═╡ c2723dba-56df-11eb-3fa8-bfb8eba3e291
william_posterior = @pipe generate_posterier(william_data, william_profile) |> Float64.(_) |> reshape(_, size(_ ,1))

# ╔═╡ 238e6088-56e0-11eb-0493-c950c4d37ecd
begin
	density(john_posterior, label="Randomized John", title="Random vs. Actual John")
	density!(john_profile.profile[:, :PRISTOT], label="Actual John")
end

# ╔═╡ 78c8f7a4-56e0-11eb-259a-258a22c828e4
begin
	density(william_posterior, label="Randomized William", title="Random vs. Actual William")
	density!(william_profile.profile[:, :PRISTOT], label="Actual William")
end

# ╔═╡ 90b288dc-583f-11eb-1195-19fba2e4ad72
kldivergence(fit_mle(Exponential, john_posterior), fit_mle(Exponential, Float64.(john_profile.profile[:, :PRISTOT])))

# ╔═╡ f8750318-5840-11eb-1fef-fdf9c965ef1a
kldivergence(fit_mle(Exponential, william_posterior), fit_mle(Exponential, Float64.(william_profile.profile[:, :PRISTOT])))

# ╔═╡ Cell order:
# ╠═d84e151c-5687-11eb-10d6-6f2de1177528
# ╠═f794bfb8-5687-11eb-0324-1f5626746d50
# ╟─11d321ce-56dd-11eb-1671-8b2309f365e5
# ╠═2b7680bc-568a-11eb-11a1-5f27d61f7e5e
# ╠═a7e807d2-5689-11eb-21d9-a9b563b8f98e
# ╠═ba5f9992-568a-11eb-296e-43303a0d10c9
# ╟─265cdd4c-56dd-11eb-3bac-3f9ef7e90325
# ╠═f055e2fc-568c-11eb-3251-79bf593a138d
# ╠═fe2faff4-568c-11eb-23a1-17c8b722a9b8
# ╠═e57203d0-568d-11eb-003a-39ce4822da5d
# ╠═441a7b9e-568f-11eb-2c10-5ddd73fe4c5e
# ╠═bdebb8c0-568f-11eb-2678-f3dfbdfd3844
# ╠═6a2033ce-568f-11eb-1c73-779d61cbbf8d
# ╠═0fe0ec94-56dc-11eb-09d0-afd73f29a3a6
# ╟─042c5750-56dd-11eb-225b-f33351bc9a5d
# ╠═71f73f02-56df-11eb-0fde-195f836871e8
# ╠═7ebe2876-56dd-11eb-37a7-ab1550d397f2
# ╠═1ca6e986-56de-11eb-354b-ad996f427da4
# ╠═ab39e89c-56de-11eb-2a54-e7d45b70eb5b
# ╠═c2723dba-56df-11eb-3fa8-bfb8eba3e291
# ╠═238e6088-56e0-11eb-0493-c950c4d37ecd
# ╠═78c8f7a4-56e0-11eb-259a-258a22c828e4
# ╠═8bb5e48c-583f-11eb-0676-65d8502a1304
# ╠═90b288dc-583f-11eb-1195-19fba2e4ad72
# ╠═f8750318-5840-11eb-1fef-fdf9c965ef1a
