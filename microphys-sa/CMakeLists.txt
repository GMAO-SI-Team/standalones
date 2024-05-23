find_package(MPI REQUIRED COMPONENTS Fortran)

set(srcs
  input.F90 
  output.F90
  gfdl_cloud_microphys.F90
  gfdl_cloud_microphys_cpu.F90
  driver.F90
  )

add_executable(microphys_driver.x ${srcs})
target_link_libraries(microphys_driver.x PRIVATE MPI::MPI_Fortran)
install(TARGETS microphys_driver.x DESTINATION bin)

