set(srcs
  src/tp_core.F90
  stubs/fv_mp_mod_stub.F90
  stubs/fv_grid_utils_stub.F90
  stubs/fv_arrays_stub.F90
  input/input_arrays.f90
  output/output_arrays.f90
  driver_cpu.f90
  main.f90)

add_executable(tp-core-driver ${srcs})
install(TARGETS tp-core-driver DESTINATION bin)

