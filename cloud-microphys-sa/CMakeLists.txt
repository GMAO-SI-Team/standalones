find_package(MPI REQUIRED COMPONENTS Fortran)

set(common_srcs
  src/input.F90
  src/output.F90
  src/gfdl_cloud_microphys_cpu_orig.F90
  src/serial_driver_cpu.F90
  src/main.F90
)

# "cpu"    - serial
# "" (gpu) - OpenMP GPU
# "doc"    - DO CONCURRENT (without OpenMP)

set(cpu_srcs
)

set(omp_srcs
  src/gfdl_cloud_microphys_gpu_orig.F90
  src/serial_driver_gpu.F90
)

set(doc_srcs
  src/gfdl_cloud_microphys_gpu_doc.F90
  src/serial_driver_doc.F90
)

set(omp_no_target_srcs
  src/gfdl_cloud_microphys_omp_cpu.F90
  src/serial_driver_omp_cpu.F90
)

## CPU driver
# <no flags>
add_executable(cloud_microphys_driver_cpu_serial.x ${common_srcs} ${cpu_srcs})
target_link_libraries(cloud_microphys_driver_cpu_serial.x PRIVATE MPI::MPI_Fortran)
install(TARGETS cloud_microphys_driver_cpu_serial.x DESTINATION bin)

## GPU driver with OpenMP
# -mp=gpu
add_executable(cloud_microphys_driver_omp_on_gpu.x ${common_srcs} ${omp_srcs})
target_link_libraries(cloud_microphys_driver_omp_on_gpu.x PRIVATE MPI::MPI_Fortran)
install(TARGETS cloud_microphys_driver_omp_on_gpu.x DESTINATION bin)
target_compile_definitions(cloud_microphys_driver_omp_on_gpu.x PRIVATE OMP_BUILD)
target_compile_definitions(cloud_microphys_driver_omp_on_gpu.x PRIVATE OMP_TYPE="GPU")
target_compile_options(cloud_microphys_driver_omp_on_gpu.x PRIVATE "-mp=gpu")
target_link_options(cloud_microphys_driver_omp_on_gpu.x PRIVATE "-mp=gpu")

## CPU driver with OpenMP NO TARGET
# -mp=multicore
add_executable(cloud_microphys_driver_omp_on_cpu_no_target.x ${common_srcs} ${omp_no_target_srcs})
target_link_libraries(cloud_microphys_driver_omp_on_cpu_no_target.x PRIVATE MPI::MPI_Fortran)
install(TARGETS cloud_microphys_driver_omp_on_cpu_no_target.x DESTINATION bin)
target_compile_definitions(cloud_microphys_driver_omp_on_cpu_no_target.x PRIVATE OMP_NO_TARGET)
target_compile_options(cloud_microphys_driver_omp_on_cpu_no_target.x PRIVATE "-mp=multicore")
target_link_options(cloud_microphys_driver_omp_on_cpu_no_target.x PRIVATE "-mp=multicore")

## CPU driver with OpenMP
# -mp=multicore
add_executable(cloud_microphys_driver_omp_on_cpu.x ${common_srcs} ${omp_srcs})
target_link_libraries(cloud_microphys_driver_omp_on_cpu.x PRIVATE MPI::MPI_Fortran)
install(TARGETS cloud_microphys_driver_omp_on_cpu.x DESTINATION bin)
target_compile_definitions(cloud_microphys_driver_omp_on_cpu.x PRIVATE OMP_BUILD)
target_compile_definitions(cloud_microphys_driver_omp_on_cpu.x PRIVATE OMP_TYPE="CPU")
target_compile_options(cloud_microphys_driver_omp_on_cpu.x PRIVATE "-mp=multicore")
target_link_options(cloud_microphys_driver_omp_on_cpu.x PRIVATE "-mp=multicore")

## DOC multicore driver
# -stdpar=multicore (for do concurrent)
add_executable(cloud_microphys_driver_doc_multicore.x ${common_srcs} ${doc_srcs})
target_link_libraries(cloud_microphys_driver_doc_multicore.x PRIVATE MPI::MPI_Fortran)
install(TARGETS cloud_microphys_driver_doc_multicore.x DESTINATION bin)
target_compile_definitions(cloud_microphys_driver_doc_multicore.x PRIVATE DOC_BUILD)
target_compile_definitions(cloud_microphys_driver_doc_multicore.x PRIVATE DOC_TYPE="MULTICORE")
target_compile_options(cloud_microphys_driver_doc_multicore.x PRIVATE "-stdpar=multicore")
target_link_options(cloud_microphys_driver_doc_multicore.x PRIVATE "-stdpar=multicore")
#target_compile_options(cloud_microphys_driver_doc_multicore.x PRIVATE "-Mconcur=allcores")
#target_link_options(cloud_microphys_driver_doc_multicore.x PRIVATE    "-Mconcur=allcores")

## DOC gpu driver
# -stdpar=gpu -gpu=managed
add_executable(cloud_microphys_driver_doc_gpu.x ${common_srcs} ${doc_srcs})
target_link_libraries(cloud_microphys_driver_doc_gpu.x PRIVATE MPI::MPI_Fortran)
install(TARGETS cloud_microphys_driver_doc_gpu.x DESTINATION bin)
target_compile_definitions(cloud_microphys_driver_doc_gpu.x PRIVATE DOC_BUILD)
target_compile_definitions(cloud_microphys_driver_doc_gpu.x PRIVATE DOC_TYPE="GPU")
target_compile_options(cloud_microphys_driver_doc_gpu.x PRIVATE "-stdpar=gpu")
target_compile_options(cloud_microphys_driver_doc_gpu.x PRIVATE "-gpu=managed")
target_link_options(cloud_microphys_driver_doc_gpu.x PRIVATE "-stdpar=gpu")
target_link_options(cloud_microphys_driver_doc_gpu.x PRIVATE "-gpu=managed")



#### OLD VERSION
#add_executable(cloud_microphys_driver.x ${srcs})
##target_link_libraries(cloud_microphys_driver.x PRIVATE MPI::MPI_Fortran)
#install(TARGETS cloud_microphys_driver.x DESTINATION bin)
#target_compile_definitions(cloud_microphys_driver.x PRIVATE $<$<BOOL:${GPU_BUILD}>:GPU_BUILD>)

#set(gpu_str_srcs
#  src/gfdl_cloud_microphys_stripped.F90
#  src/serial_driver_gpu_stripped.F90
#)

#if (DOC_CPU)
#  list(APPEND srcs
#    src/gfdl_cloud_microphys_doc_cpu.F90
#    src/serial_driver_doc_cpu.F90
#  )
#  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -DDOC_CPU")
#endif ()

