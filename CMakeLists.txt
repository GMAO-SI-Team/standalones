cmake_minimum_required (VERSION 3.17)
cmake_policy (SET CMP0053 NEW)
cmake_policy (SET CMP0054 NEW)

project (
  tp-core-driver
  VERSION 1.0.0
  LANGUAGES Fortran)

if ("${PROJECT_SOURCE_DIR}" STREQUAL "${PROJECT_BINARY_DIR}")
   message(SEND_ERROR "In-source builds are disabled. Please
           issue cmake command in separate build directory.")
endif ("${PROJECT_SOURCE_DIR}" STREQUAL "${PROJECT_BINARY_DIR}")

# Set the default build type to release
if (NOT CMAKE_BUILD_TYPE)
  message (STATUS "Setting build type to 'Release' as none was specified.")
  set (CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property (CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Release" "Aggressive")
endif ()

list (APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/support)
include (esma_check_install_prefix)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/compiler)
include (esma_compiler)

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

