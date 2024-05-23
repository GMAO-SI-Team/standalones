# tp-core-driver

## Building

To build you must have CMake, GNU Make (or Ninja), and a Fortran compiler

The steps to build are:

```
cmake -B build -S . --install-prefix=$(pwd)/install
cmake --build build --target install
```

This will build in a directory called `build/` and install to `install/`. 

NOTE: This relies on `FC` being set in your environment. If it isn't, add `-DCMAKE_Fortran_COMPILER=<compiler>` to the first CMake
call.
