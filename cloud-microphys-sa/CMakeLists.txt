find_package(MPI REQUIRED COMPONENTS Fortran)

set(srcs
  src/input.F90
  src/output.F90
  src/gfdl_cloud_microphys_cpu.F90
  src/gfdl_cloud_microphys.F90
  src/gfdl_cloud_microphys_doc.F90
  src/gfdl_cloud_microphys_doc_cpu.F90
  src/gfdl_cloud_microphys_doc_stripped.F90
  src/serial_driver_cpu.F90
  src/serial_driver_gpu.F90
  src/serial_driver_doc.F90
  src/serial_driver_doc_cpu.F90
  src/serial_driver_doc_stripped.F90
  src/main.F90
)

add_executable(cloud_microphys_driver.x ${srcs})
target_link_libraries(cloud_microphys_driver.x PRIVATE MPI::MPI_Fortran)
install(TARGETS cloud_microphys_driver.x DESTINATION bin)
target_compile_definitions(cloud_microphys_driver.x PRIVATE $<$<BOOL:${GPU_BUILD}>:GPU_BUILD>)

