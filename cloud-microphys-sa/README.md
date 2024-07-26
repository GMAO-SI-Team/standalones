# Standalone executing cloud microphysics code

The executable is called `cloud_microphys_driver.x` and can be found in the `install/bin` directory.

## Running

#### Usage

```shell
mpirun --n <num-ranks> /path/to/cloud_microphys_driver.x
```
This requires input data to be available in `./input-data`.

#### Input data

On Discover, several sets of input data are available at

`/discover/nobackup/pchakrab/input/microphys-driver/<resolution>/np<num-ranks>`.

To use a particular set (C360, np72), try
```shell
ln -s /discover/nobackup/pchakrab/input/microphys-driver/C360/np72 input-data
```

#### Comparing CPU and GPU run times

Ensure that the CPU and GPU are doing the same/similar amount of work for the sake of comparisons. In the case where there are more CPU nodes or cores than GPU's, consider scaling results or inputs accordingly.

### GFDL Micrphys Files

In `src/`, there are multiple versions of the GFDL cloud microphysics module. They are as follows:
 - gfdl\_cloud\_microphys\_cpu\_orig.F90 - The original CPU version of the module
 - gfdl\_cloud\_microphys\_cpu\_doc.F90 - A clone of the CPU implementation using DO CONCURRENT in place of DO. Not in use.
 - gfdl\_cloud\_microphys\_gpu\_orig.F90 - A GPU implementation of the module using OpenMP directives
 - gfdl\_cloud\_microphys\_gpu\_doc.F90 - A clone of the GPU implementation using DO CONCURRENT in place of DO, where trivial

There are also `serial_driver_<ver>.F90` files that act as wrappers for each.

