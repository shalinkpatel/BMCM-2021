using Turing, Distributions, Plots, StatsPlots, CSV, DataFrames, DataFramesMeta, Pipe

struct JudgeProfile
    profile :: DataFrame
    train :: Vector
    age_dist :: LogNormal
    citizen_dist :: DiscreteNonParametric
    crimhist_dist :: DiscreteNonParametric
    monsex_dist :: DiscreteNonParametric
    neweduc_dist :: DiscreteNonParametric
    newrace_dist :: DiscreteNonParametric
    ω₀ :: Gamma
    Ω₀ :: Vector{Gamma}
end

@model function sentencing_inference(age, citizen, crimhist, crimpts, neweduc, newrace, monsex, pristot)
    ω ~ Gamma(2, 2)

    for i ∈ 1:length(crimpts)
        crimpts[i] ~ Exponential(ω[1] * crimhist[i] + 0.0001)
    end

    Ω = Vector(undef, 6)
    Ω .~ Gamma(2, 2)

    for i ∈ 1:length(pristot)
        pristot[i] ~ Pareto(Ω[1] * age[i] + Ω[2] * citizen[i] + Ω[3] * monsex[i] + Ω[4] * neweduc[i] + Ω[5] * newrace[i] + Ω[6] * crimpts[i]) - 1
    end
end

@model function sentencing_generation(age, citizen, crimpts, neweduc, newrace, monsex, Ω₀)
    Ω = Vector(undef, 6)
    for i ∈ 1:6
        Ω[i] ~ Ω₀[i]
    end
    pristot ~ Pareto(Ω[1] * age + Ω[2] * citizen + Ω[3] * monsex + Ω[4] * neweduc + Ω[5] * newrace + Ω[6] * crimpts) - 1
    return pristot
end

function JudgeProfile(profile :: DataFrame)
    train = @pipe profile |> Array |> Int.(_) |> [_[:, i] for i ∈ 1:size(_, 2)]
    age_dist = fit_mle(LogNormal, profile[:, :AGE])
    citizen_dist = fit_mle(DiscreteNonParametric, profile[:, :CITIZEN])
    crimhist_dist = fit_mle(DiscreteNonParametric, profile[:, :CRIMHIST])
    monsex_dist = fit_mle(DiscreteNonParametric, profile[:, :MONSEX])
    neweduc_dist = fit_mle(DiscreteNonParametric, profile[:, :NEWEDUC])
    newrace_dist = fit_mle(DiscreteNonParametric, profile[:, :NEWRACE])
    inference_samples = sample(sentencing_inference(train...), NUTS(), 1000)
    Ω₀ = [fit_mle(Gamma, inference_samples[Symbol("Ω[$(i)]")] |> Array) for i ∈ 1:6]
    ω₀ = fit_mle(Gamma, inference_samples[:ω])
    return JudgeProfile(profile, train, age_dist, citizen_dist, crimhist_dist, monsex_dist, neweduc_dist, newrace_dist, ω₀, Ω₀)
end

sentencing_inference(profile :: JudgeProfile, n :: Int) = sample(sentencing_inference(profile.train...), NUTS(), n)
sentencing_generation(profile :: JudgeProfile, point :: Vector{Int}, n :: Int) = 
    sample(sentencing_generation(point..., profile.Ω₀), Prior(), n)