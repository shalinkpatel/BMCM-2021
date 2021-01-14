using Turing, Distributions, Plots, StatsPlots, CSV, DataFrames, DataFramesMeta, Pipe

@model function sentencing(age, citizen, crimhist, crimpts, neweduc, newrace, monsex, pristot)
    age .~ LogNormal(3.54, 0.30)
    citizen .~ Categorical([0.78, 0.06, 0.14, 0.02])
    crimhist .~ DiscreteNonParametric([0, 1], [0.14, 0.86])
    monsex .~ DiscreteNonParametric([0, 1], [0.915, 0.085])
    neweduc .~ Categorical([0.4, 0, 0.37, 0, 0.16, 0.07])
    newrace .~ Categorical([0.35, 0.2, 0.4, 0, 0, 0.05])

    ω₁ ~ Normal(2, 2)
    ω₂ ~ Normal(1/25, 1/100)

    for i ∈ 1:length(crimpts)
        crimpts[i] ~ Exponential(ω₁ * crimhist[i] + ω₂ * age[i])
    end

    Ω₁ ~ Normal(1, 2)
    Ω₂ ~ Normal(1, 2)
    Ω₃ ~ Normal(1, 2)
    Ω₄ ~ Normal(1, 2)
    Ω₅ ~ Normal(1, 2)
    Ω₆ ~ Normal(1, 2)

    for i ∈ 1:length(pristot)
        pristot[i] ~ Pareto(Ω₁ * age[i] + Ω₂ * citizen[i] + Ω₃ * monsex[i] + Ω₄ * neweduc[i] + Ω₅ * newrace[i] + Ω₆ * crimpts[i]) - 1
    end
end
    
data = CSV.File("data/circuit6.csv") |> DataFrame
filtered = @linq data |> select(:AGE, :CITIZEN, :CRIMHIST, :CRIMPTS, :NEWEDUC, :NEWRACE, :MONSEX, :PRISTOT)
filtered = filtered[completecases(filtered), :]
train = @pipe filtered |> Array |> Int.(_) |> [_[1:10, i] for i ∈ 1:size(_, 2)]

samples = sample(sentencing(train...), PG(5), 10)