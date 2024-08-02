
program main

  use mpi
  use MicrophysicsSerialDriverCPU, only: serial_driver_cpu => serial_driver
  use input_mod, only: InputScalars_T, InputArrays_T, get_data_from_file, get_data_from_file_scaled
  use output_mod, only: OutputArrays_T, write_output_difference => write_difference, &
        get_cpu_data => get_data_from_file, write_data_to_file, print_info
  use iso_fortran_env, only: compiler_options, compiler_version

  implicit none

  integer, parameter :: NUM_GPU_RUNS = 1, SCALE_I = 4, SCALE_J = 4
  integer :: irank, nranks, mpi_err, i, j
  type(InputScalars_T) :: sclr
  type(InputArrays_T) :: inarr
  type(OutputArrays_T) :: outarr, outarr_cpu
  character(len=256) :: input_file_name, savestate_file_name, canonical_name
  character(len=*), parameter :: fmt = '(1x, a1, i2, a1, 1x, a, f11.7, 1x, a1)'
  real :: cpu_time_, test_time_scalar_, test_time_arr_(NUM_GPU_RUNS)
  logical :: outfile_exists, savestate_exists
  integer, parameter :: outfile_unit = 16
  character(len=256), parameter :: outfile = 'benchmark_cloud/table.dat'

  !print *, "Compiler options: ", compiler_options()
  print *, 'Compiler version: ', compiler_version()

  inquire(file=outfile, exist=outfile_exists)
  if (outfile_exists) then
     open(outfile_unit, file=outfile, status="old", position="append", action="write")
  else
     open(outfile_unit, file=outfile, status="new", action="write")
     write(outfile_unit, '(A)') "code version, cpu time, test time, RMSE from CPU, nranks, &
           OMP_NUM_THREADS, compiler ident,  hostname, acc_num_threads, scale_i, scale_j"
  endif
  print *, 'Saving output data to: ', trim(outfile)

  call MPI_Init(mpi_err)
  call MPI_Comm_rank(MPI_COMM_WORLD, irank, mpi_err)
  call MPI_Comm_size(MPI_COMM_WORLD, nranks, mpi_err)

  ! Preapre file name variables
  write(input_file_name, '(a26, i2.2, a4)') 'input-data/microphys_data.', irank, '.bin'
  write(savestate_file_name, '(a10, i2.2, a1, i2.2, a10)') 'input/np6_', SCALE_I, '_', SCALE_J, '_result.bin'

  ! Read input data
  !call get_data_from_file(file_name, sclr, inarr)
  print *, 'Using input size multiplier of: ', SCALE_I, 'x', SCALE_J, ' = ', (SCALE_I * SCALE_J)
  call get_data_from_file_scaled(input_file_name, sclr, inarr, SCALE_I, SCALE_J)
  !call sclr%write_scalars()
  !call inarr%write_arrays()

  ! CPU run iff a saved version does not yet exist
  inquire(file=savestate_file_name, exist=savestate_exists)
  if (savestate_exists) then
     print *, 'Found results from previous CPU run'
     call get_cpu_data(savestate_file_name, outarr_cpu)
     cpu_time_ = 0.
  else
     print *, 'No previous CPU results found, not running with this version (may be unstable!)'
     stop 1
  endif

  ! CPU with Mconcur
  write(canonical_name, '(a)') 'CPU : Mconcur'
  print *, 'Running ', (canonical_name)
  call serial_driver_cpu(irank, sclr, inarr, outarr, test_time_scalar_)
  test_time_arr_(NUM_GPU_RUNS) = test_time_scalar_
  call print_info(outfile_unit, outarr, outarr_cpu, mpi_err, irank, nranks, &
        cpu_time_, test_time_arr_, canonical_name, SCALE_I, SCALE_J)

  call MPI_Finalize(mpi_err)

  close(outfile_unit)

end program main
