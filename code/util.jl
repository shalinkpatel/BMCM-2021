using DataFrames, DataFramesMeta

function filter_data(raw_data :: DataFrame)
    filtered = @linq raw_data |> select(:AGE, :CITIZEN, :CRIMHIST, :CRIMPTS, :NEWEDUC, :NEWRACE, :MONSEX, :PRISTOT)
    filtered = filtered[completecases(filtered), :]
    return coalesce.(filtered, 0)
end

function select_judge(raw_data :: DataFrame, judge :: String)
    tmp = @linq raw_data |> where(:judge .== judge)
    return filter_data(tmp)
end