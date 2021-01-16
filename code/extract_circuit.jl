using DataFrames, DataFramesMeta, CSV

circuit = 10

dataset = CSV.File("../data/FinalDataset.csv") |> DataFrame
subset = @linq dataset |> 
    where(:CIRCDIST .== circuit) |> 
    select(:AGE, :CIRCDIST, :CITIZEN, :CRIMHIST, :CRIMPTS, :judge, :NEWEDUC,
            :NEWRACE, :MONSEX, :OFFICE, :PRISTOT, :PROBATN, :SENTDATE, :SENTMON, :SENTYR)

CSV.write("../data/circuit$(circuit).csv", subset)
