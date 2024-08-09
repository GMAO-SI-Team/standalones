#!/bin/bash

# A more advanced test program to run tp-core and save the data about multiple executions of tp-core to one table (OUTFILE).

# File location variables
STANDALONES=$'/home/mgsanbor/standalones'
EXECUTABLE="${STANDALONES}/install/bin/tp_core_driver.x"
OUTFILE="${STANDALONES}/benchmark/data.csv"

# Check for the correct number of arguments passed to the script
if [[ $# -lt 2 ]]
then
    echo "Please enter resolution and iter params!"
    echo "Usage: $0 <res> <iter>"
    exit 1
fi

# Check that the build is accurate/up-to-date
if [[ "${STANDALONES}/CMakeUserPresets.json" -nt "${EXECUTABLE}" ]]
then
    echo "You must recompile to apply the new CMake options!"
    exit 2
fi

# Add file header if non-existant
if ! [ -f ${OUTFILE} ]
then
    echo "host, os, fc, fflags, res, n_iter, time, sum_x, sum_y" > ${OUTFILE}
fi

# Evaluate information about the build and run context
HOST=$(hostname)
OS_VERSION=$(cat /etc/os-release | grep -Ee "PRETTY_NAME" | sed 's/PRETTY_NAME=\"\([^\"]\+\)\"/\1/')

# Assume nvfortran for now. Can alternatively strip this from the CMakePresets.json file
FC=$(nvfortran --version | awk 'NR==2 {print $1 "-" $2}')

# A poor man's implementation to get compiler flags. Assumes CMakeUserPresets.json contains only one entry.
FFLAGS=$(cat CMakeUserPresets.json | grep -Ee "CMAKE_Fortran_FLAGS" | sed 's/^\ \+"CMAKE_Fortran_FLAGS"\: "\([^"]*\).\+$/\1/')

# Get runtime data
TP_CORE=$("${EXECUTABLE}" $1 $2)

# Extract runtime info
TIME_TAKEN=$(echo "${TP_CORE}" | head -1 | sed 's/^\s*time taken:\s*\([0-9\.E-]\+\)[^$]*$/\1/')
SUMMA=$(echo "${TP_CORE}" | tail -1 | sed 's/^[^(]*(fx): \([0-9\.]\+\)[^$]*$/\1/')

# Save to file OUTFILE and repeat basic version to user running script
echo "${HOST}, ${OS_VERSION}, ${FC}, ${FFLAGS}, $1, $2, ${TIME_TAKEN}, ${SUMMA}" | awk '{$1=$1;print}' >> ${OUTFILE}
echo "Took ${TIME_TAKEN}s using ${FC} ${FFLAGS} on ${HOST} (${OS_VERSION}) for inputs: $1 $2"

