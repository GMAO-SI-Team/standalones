set(srcs
  src/tp_core.F90
  src/stubs/fv_mp_mod_stub.F90
  src/stubs/fv_grid_utils_stub.F90
  src/stubs/fv_arrays_stub.F90
  src/input_arrays.f90
  src/output_arrays.f90
  src/driver_cpu.f90
  src/main.f90)

add_executable(tp_core_driver.x ${srcs})
install(TARGETS tp_core_driver.x DESTINATION bin)

