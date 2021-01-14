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

# ╔═╡ f794bfb8-5687-11eb-0324-1f5626746d50
raw_data = CSV.File("../data/circuit6.csv") |> DataFrame;

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

# ╔═╡ Cell order:
# ╠═d84e151c-5687-11eb-10d6-6f2de1177528
# ╠═f794bfb8-5687-11eb-0324-1f5626746d50
# ╠═2b7680bc-568a-11eb-11a1-5f27d61f7e5e
# ╠═a7e807d2-5689-11eb-21d9-a9b563b8f98e
# ╠═ba5f9992-568a-11eb-296e-43303a0d10c9
# ╠═f055e2fc-568c-11eb-3251-79bf593a138d
# ╠═fe2faff4-568c-11eb-23a1-17c8b722a9b8
# ╠═e57203d0-568d-11eb-003a-39ce4822da5d
# ╠═441a7b9e-568f-11eb-2c10-5ddd73fe4c5e
# ╠═bdebb8c0-568f-11eb-2678-f3dfbdfd3844
# ╠═6a2033ce-568f-11eb-1c73-779d61cbbf8d
