## Setup instructions

To download and access the data files use `git lfs` which can be found here https://git-lfs.github.com/.

The initial exploration is done using Julia. You would want to add the following packages using the `]` character initially in the Julia REPL.
```
add Plots, StatsPlots, CSV, DataFrames, DataFramesMeta, Turing, Pipe, PlutoUI, Pluto
```
Then you want to open the `code/initial.jl` file using a Pluto server which is run in the Julia REPL using 
```julia
using Pluto; Pluto.run()
```