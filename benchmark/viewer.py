#!/usr/bin/false3

# Imports
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# Load data
df = pd.read_csv("/discover/nobackup/mgsanbor/standalones/benchmark/on_node_runs/data.csv", header=None)

# Denote column names
# note: sum(fx) and sum(fy) are for parity checks, and for some reason are duplicated
df.columns = [ "host", "SLES-ver", "fc", "fflags", "resolution", "iterations", "time", "sum(fx)", "sum(fy)", "sum(fx)2", "sum(fy)2" ]

# Keep only relevant info
df_plot = df[[ "fflags", "resolution", "time" ]]

# Try to convert to numeric
df_plot["resolution"] = pd.to_numeric(df_plot["resolution"], errors="coerce")
df_plot["time"] = pd.to_numeric(df_plot["time"], errors="coerce")

# Discard missing values
df_plot.dropna(subset=["resolution", "time"], inplace=True)

# Jitter offset
j_offs = 100

# Build plot
plt.figure(figsize=(10, 6))

unique_groups = df_plot["fflags"].unique()
group_offsets = np.linspace(-0.5, 0.5, len(unique_groups))

for offset, group_name in zip(group_offsets, unique_groups):
    group_data = df_plot[df_plot["fflags"] == group_name]
    jittered_x = group_data["resolution"] + offset * 400 # apply offset
    plt.scatter(jittered_x, group_data["time"], label=group_name, alpha=0.7)

#for ff, group_data in df_plot.groupby("fflags"):
#    jittered_data = group_data["resolution"] + np.random.uniform(-j_offs, j_offs, size=len(group_data))
#    plt.scatter(jittered_data, group_data["time"], label=ff, alpha=0.7)

plt.xlabel("Resolution")
plt.ylabel("Time")
plt.title("Time by flags used")
plt.legend(title="Flags:")
plt.grid(True)
plt.show()

