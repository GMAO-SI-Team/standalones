find_package(MPI REQUIRED COMPONENTS Fortran)

set(srcs
  src/input.F90 
  src/output.F90
  # src/gfdl_cloud_microphys.F90
  src/gfdl_cloud_microphys_cpu.F90
  src/main.F90
  )

add_executable(cloud_microphys_driver.x ${srcs})
target_link_libraries(cloud_microphys_driver.x PRIVATE MPI::MPI_Fortran)
install(TARGETS cloud_microphys_driver.x DESTINATION bin)

