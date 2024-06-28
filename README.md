# Standalones for tp-core and cloud microphysics

## Building

To build you must have CMake, GNU Make (or Ninja), Fortran compiler, and an MPI stack

> [!NOTE]
> On Discover, one can load the modules `cmake` and `comp/nvhpc/22.3`

The steps to build are:

```shell
cmake -B build -S . --install-prefix=$(pwd)/install
cmake --build build --target install
```

This will build in a directory called `build/` and install to `install/`.

> [!NOTE]
>  This relies on `FC` being set in your environment. If it isn't, add `-DCMAKE_Fortran_COMPILER=<compiler>` to the first CMake call.

> [!NOTE]
> This builds the CPU version of the the microphysics code. To build the GPU version as well, add `-DGPU_BUILD=On` to the first CMake call.

> [!NOTE]
> Other presets can be used for building to include things such as compiler flags. To include the presets, add the `--preset=accelerated` to the first command for GPU acceleration to be enabled. (This may or may not run faster.)

## Benchmarking

> The `benchmark/` folder contains ways to test the speed of tp-core and save run data to a file. See benchmark/run\_interactive for more detail. Some paths may need to be updated in these files to work correctly.
