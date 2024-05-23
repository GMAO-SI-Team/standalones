set(srcs
  input.F90 
  output.F90
  gfdl_cloud_microphys.F90
  gfdl_cloud_microphys_cpu.F90
  driver.F90
  )

add_executable(microphys_driver.x ${srcs})
install(TARGETS microphys_driver.x DESTINATION bin)

