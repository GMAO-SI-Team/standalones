# Standalone executing FV3 tp-core code

The executable is called `tp_core_driver.x` and can be found in the `install/bin` directory.

## Running

#### Usage

```shell
/path/to/tp_core_driver.x <resolution> <number-of-iterations>
```
where `resolution` can be, say `2880`. Number of iterations can be set to some number, say `20` - this is the number of times the routine `fv_tp_2d` from `tp_core.F90` gets called.

#### Input data

All input variables are initialized by the driver itself (one should, however, ensure the validity of these values), except for the optional *intent(in)* variables - `mfx`, `mfy`, `mass`, `nord`, `damp_c`.

> [!NOTE]
>  Since `mass`, `nord` and `damp_c` are absent, the routine `deln_flux` does not get executed.
