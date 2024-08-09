#!/bin/bash

for SIZE in 100 1000 2000 2880 10000
do
    for I in {1..5}
    do
        /discover/nobackup/mgsanbor/standalones/benchmark/run_interactive $SIZE 1
    done
done

