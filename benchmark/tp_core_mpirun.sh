#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name=tp_core_benchmark
#SBATCH --ntasks=16 --cpus-per-task=45
#SBATCH --time=00:02:00
#SBATCH --chdir=/discover/nobackup/mgsanbor/standalones/benchmark/generated
#SBATCH -o mpi_output.%j
#SBATCH -e mpi_error.%j

export EXE_PATH="/discover/nobackup/mgsanbor/standalones/benchmark/tp_core_driver.x"

if ! [ -x "${EXE_PATH}" ]; then
    echo "Executable not found!" >&2
    exit 1
fi

mpirun -np 16 "${EXE_PATH}" 10000 20

exit 0

