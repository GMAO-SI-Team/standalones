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
# target_link_libraries(tp_core_driver.x ${MPI_Fortran_Libraries})
install(TARGETS tp_core_driver.x DESTINATION bin)
target_compile_options(tp_core_driver.x PRIVATE "-nostdpar")
target_link_options(tp_core_driver.x PRIVATE "-nostdpar")

add_executable(tp_core_driver_multicore.x ${srcs})
install(TARGETS tp_core_driver_multicore.x DESTINATION bin)
target_compile_options(tp_core_driver_multicore.x PRIVATE "-stdpar=multicore")
target_link_options(tp_core_driver_multicore.x PRIVATE "-stdpar=multicore")

add_executable(tp_core_driver_gpu.x ${srcs})
install(TARGETS tp_core_driver_gpu.x DESTINATION bin)
target_compile_options(tp_core_driver_gpu.x PRIVATE "-stdpar=gpu")
target_link_options(tp_core_driver_gpu.x PRIVATE "-stdpar=gpu")
target_compile_options(tp_core_driver_gpu.x PRIVATE "-gpu=managed")
target_link_options(tp_core_driver_gpu.x PRIVATE "-gpu=managed")

add_executable(tp_core_driver_gpu_unified.x ${srcs})
install(TARGETS tp_core_driver_gpu_unified.x DESTINATION bin)
target_compile_options(tp_core_driver_gpu_unified.x PRIVATE "-stdpar=gpu")
target_link_options(tp_core_driver_gpu_unified.x PRIVATE "-stdpar=gpu")
target_compile_options(tp_core_driver_gpu_unified.x PRIVATE "-gpu=unified")
target_link_options(tp_core_driver_gpu_unified.x PRIVATE "-gpu=unified")

add_executable(tp_core_driver_mvect.x ${srcs})
install(TARGETS tp_core_driver_mvect.x DESTINATION bin)
target_compile_options(tp_core_driver_mvect.x PRIVATE "-Mvect=simd")
target_link_options(tp_core_driver_mvect.x PRIVATE "-Mvect=simd")

add_executable(tp_core_driver_mconcur.x ${srcs})
install(TARGETS tp_core_driver_mconcur.x DESTINATION bin)
target_compile_options(tp_core_driver_mconcur.x PRIVATE "-Mconcur=allcores")
target_link_options(tp_core_driver_mconcur.x PRIVATE "-Mconcur=allcores")

