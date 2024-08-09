#!/bin/bash

# A simple program to run tp-core and save the output to a file

export DIR_PATH="/home/mgsanbor/standalones"
export EXE_PATH="${DIR_PATH}/benchmark/tp_core_driver.x"

JOB_ID=$(date +%s)

if ! [ -x "${EXE_PATH}" ]; then
    echo "Executable not found!" >&2
    exit 1
fi

RESOLUTION=2880
N_ITERS=20

echo "Resolution: ${RESOLUTION}, number of iters: ${N_ITERS}"
time "${EXE_PATH}" "${RESOLUTION}" "${N_ITERS}" > "${DIR_PATH}/benchmark/raw_output/raw_output.${JOB_ID}"

exit 0

