
#ifndef DOC_TYPE
#define DOC_TYPE '(UNKNOWN)'
#endif // DOC_TYPE

#ifndef OMP_TYPE
#define OMP_TYPE '(UNKNOWN)'
#endif

program main

#ifdef MPI_VERSION
  use mpi
#endif // MPI_VERSION
  use MicrophysicsSerialDriverCPU, only: serial_driver_cpu => serial_driver
!#if defined(OMP_BUILD) || defined(OMP_NO_TARGET)
#ifdef _OPENMP
  use omp_lib, only: omp_get_max_threads, omp_get_num_procs
#endif
#ifdef OMP_BUILD
  use MicrophysicsSerialDriverGPU, only: serial_driver_gpu => serial_driver
#endif // OMP_BUILD
#ifdef GPU_STRIPPED
  use MicrophysicsSerialDriverGPUStripped, only: serial_driver_gpu_stripped => serial_driver
#endif // GPU_STRIPPED
#ifdef DOC_BUILD
  use MicrophysicsSerialDriverDOC, only: serial_driver_doc => serial_driver
#endif // DOC_BUILD
#ifdef OMP_NO_TARGET
  use MicrophysicsSerialDriverOMPCPU, only: serial_driver_omp_cpu => serial_driver
#endif // OMP_NO_TARGET
  use input_mod, only: InputScalars_T, InputArrays_T, get_data_from_file, get_data_from_file_scaled
  use output_mod, only: OutputArrays_T, write_output_difference => write_difference, get_cpu_data => get_data_from_file, write_data_to_file
  use iso_fortran_env, only: compiler_options, compiler_version

  implicit none

  integer, parameter :: NUM_GPU_RUNS = 3, SCALE_I = 4, SCALE_J = 4
  integer :: irank, nranks, mpi_err, i, j
  type(InputScalars_T) :: sclr
  type(InputArrays_T) :: inarr
  type(OutputArrays_T) :: outarr, outarr_cpu
  character(len=256) :: input_file_name, savestate_file_name, canonical_name
  character(len=*), parameter :: fmt = '(1x, a1, i2, a1, 1x, a, f11.7, 1x, a1)'
  real :: cpu_time_, doc_cpu_time_, gpu_time_(NUM_GPU_RUNS), doc_time_(NUM_GPU_RUNS), doc_stripped_time_(NUM_GPU_RUNS), gpu_stripped_time_(NUM_GPU_RUNS)
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
           OMP_NUM_THREADS, compiler ident,  hostname, acc_num_threads"
  endif
  print *, 'Saving output data to: ', outfile

#ifdef MPI_VERSION
  call MPI_Init(mpi_err)
  call MPI_Comm_rank(MPI_COMM_WORLD, irank, mpi_err)
  call MPI_Comm_size(MPI_COMM_WORLD, nranks, mpi_err)
#endif // MPI_VERSION

  ! Preapre file name variables
  write(input_file_name, '(a26, i2.2, a4)') 'input-data/microphys_data.', irank, '.bin'
  write(savestate_file_name, '(a10, i2.2, a1, i2.2, a10)') 'input/np6_', SCALE_I, '_', SCALE_J, '_result.bin'

  ! Read input data
  !call get_data_from_file(file_name, sclr, inarr)
  print *, 'Using input size multiplier of: ', SCALE_I, 'x', SCALE_J, ' = ', SCALE_I, SCALE_J
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
     print *, 'No previous CPU results found, running now'
     call serial_driver_cpu(irank, sclr, inarr, outarr_cpu, cpu_time_)
     call outarr_cpu%write_arrays()
     print *, 'Done with CPU, saving for future runs'
     write(*, fmt) '[', irank, ']', 'Time taken (cpu):', cpu_time_, 's'

     call write_data_to_file(savestate_file_name, outarr_cpu)
  endif

#ifdef OMP_BUILD
  ! GPU run
  write(canonical_name, '(a)') OMP_TYPE // '; with OpenMP'
  print *, 'Running ', trim(canonical_name)
  call serial_driver_gpu(irank, NUM_GPU_RUNS, sclr, inarr, outarr, gpu_time_)
  call print_info(outfile_unit, outarr, outarr_cpu, mpi_err, irank, nranks, cpu_time_, gpu_time_, canonical_name)
#endif // OMP_BUILD

#ifdef GPU_STRIPPED
  ! GPU stripped run
  write(canonical_name, '(a)') 'GPU - no OpenMP'
  print *, 'Running ', (canonical_name)
  call serial_driver_gpu_stripped(irank, NUM_GPU_RUNS, sclr, inarr, outarr, gpu_stripped_time_)
  call print_info(outfile_unit, outarr, outarr_cpu, mpi_err, irank, nranks, cpu_time_, gpu_stripped_time_, canonical_name)
#endif // GPU_STRIPPED

#ifdef DOC_BUILD
  ! DO CONCURRENT (?) Run
  write(canonical_name, '(a)') DOC_TYPE // ': DO CONCURRENT; no OpenMP'
  print *, 'Running ', (canonical_name)
  call serial_driver_doc(irank, NUM_GPU_RUNS, sclr, inarr, outarr, doc_time_)
  call print_info(outfile_unit, outarr, outarr_cpu, mpi_err, irank, nranks, cpu_time_, doc_time_, canonical_name)
#endif // DOC_BUILD

#ifdef OMP_NO_TARGET
  ! OMP without "target" commands/directives (intended for CPU)
  write(canonical_name, '(a)') 'CPU : OpenMP (no target)'
  print *, 'Running ', (canonical_name)
  call serial_driver_omp_cpu(irank, NUM_GPU_RUNS, sclr, inarr, outarr, doc_time_)
  call print_info(outfile_unit, outarr, outarr_cpu, mpi_err, irank, nranks, cpu_time_, doc_time_, canonical_name)
#endif // OMP_NO_TARGET

#ifdef MPI_VERSION
  call MPI_Finalize(mpi_err)
#endif // MPI_VERSION

  close(outfile_unit)

contains

  subroutine print_info(outfile_unit, outarr, outarr_cpu, mpi_err, irank, nranks, cpu_time_, time_, canonical_name)
     ! Arguments
     integer, intent(in) :: outfile_unit
     type(OutputArrays_T), intent(in) :: outarr, outarr_cpu
     integer, intent(in) :: irank, nranks
     integer, intent(inout) :: mpi_err
     real, intent(in) :: cpu_time_, time_(NUM_GPU_RUNS)
     character(len=*), intent(in) :: canonical_name

     ! Locals
     character(len=*), parameter :: fmt_print = '(1x, a1, i2, a, a, a2, 1x, f11.7, 1x, a1)'
     character(len=*), parameter :: fmt_data = '(a, a1, 2(f11.7, a1), e15.9, a1, i, a1, i, a1, a, a1, a, a1, a)'
     integer :: i, j, num_threads
     character(len=256) :: host_name, acc_num_cores
     real :: rms

     ! Code
     !call outarr%write_arrays()
     !call write_output_difference(outarr_cpu, outarr)

#ifdef MPI_VERSION
     call MPI_Barrier(MPI_COMM_WORLD, mpi_err)
#endif // MPI_VERSION

     print *, 'Done with ', trim(canonical_name)
     ! Write output differences to stdout
     do i = 0, nranks
        if (i == irank) then
           write(*, *)
           do j = 1, NUM_GPU_RUNS
              write(*, fmt_print) '[', irank, '] Time taken (', trim(canonical_name), '):', time_(j), 's'
           end do
           call write_output_difference(outarr_cpu, outarr)
        end if
#ifdef MPI_VERSION
        call MPI_Barrier(MPI_COMM_WORLD, mpi_err)
#endif // MPI_VERSION
     end do

     ! write to outfile: code version (eg. GPU, CPU, GPU no OpenMP), compiler flags/options, OMP_THREAD_COUNT(?), runtime, diffs
     ! Calculate root mean squared error
     rms = sqrt( (&
           &   ( ( norm2(outarr_cpu%revap-outarr%revap)/norm2(outarr_cpu%revap) ) ** 2) &
           & + ( ( norm2(outarr_cpu%isubl-outarr%isubl)/norm2(outarr_cpu%isubl) ) ** 2) &
           & + ( ( norm2(outarr_cpu%rain-outarr%rain)/norm2(outarr_cpu%rain) ) ** 2) &
           & + ( ( norm2(outarr_cpu%snow-outarr%snow)/norm2(outarr_cpu%snow) ) ** 2) &
           & + ( ( norm2(outarr_cpu%ice-outarr%ice)/norm2(outarr_cpu%ice) ) ** 2) &
           & + ( ( norm2(outarr_cpu%graupel-outarr%graupel)/norm2(outarr_cpu%graupel) ) ** 2) &
           & + ( ( norm2(outarr_cpu%m2_rain-outarr%m2_rain)/norm2(outarr_cpu%m2_rain) ) ** 2) &
           & + ( ( norm2(outarr_cpu%m2_sol-outarr%m2_sol)/norm2(outarr_cpu%m2_sol) ) ** 2) &
           & ) / 8. )

!#if defined(OMP_BUILD) || defined(OMP_NO_TARGET)
#ifdef _OPENMP
     !num_threads = omp_get_num_threads()
     num_threads = omp_get_max_threads()
     print *, "max threads: ", omp_get_max_threads()
     print *, "num procs: ", omp_get_num_procs()
#else
     num_threads = -1
#endif

     call hostnm(host_name)
     call get_environment_variable("ACC_NUM_CORES", acc_num_cores)

     write(outfile_unit, fmt_data) trim(canonical_name), ',', cpu_time_, ',', time_(NUM_GPU_RUNS), ',', &
           rms, ',', nranks, ',', num_threads, ',', compiler_version(), ',', trim(host_name), ',', &
           trim(acc_num_cores)
  end subroutine print_info

end program main
