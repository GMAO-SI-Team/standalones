program main

  use mpi
  use MicrophysicsSerialDriverCPU, only: serial_driver_cpu => serial_driver
#ifdef GPU_BUILD
  use MicrophysicsSerialDriverGPU, only: serial_driver_gpu => serial_driver
#ifdef GPU_STRIPPED
  use MicrophysicsSerialDriverGPUStripped, only: serial_driver_gpu_stripped => serial_driver
#endif // GPU_STRIPPED
  use MicrophysicsSerialDriverDOC, only: serial_driver_doc => serial_driver
#ifdef DOC_CPU
  use MicrophysicsSerialDriverDOCCPU, only: serial_driver_doc_cpu => serial_driver
#endif // DOC_CPU
  use MicrophysicsSerialDriverDOCStripped, only: serial_driver_doc_stripped => serial_driver
#endif // GPU_BUILD
  use input_mod, only: InputScalars_T, InputArrays_T, get_data_from_file
  use output_mod, only: OutputArrays_T, write_output_difference => write_difference

  implicit none

  integer, parameter :: NUM_GPU_RUNS = 1
  integer :: irank, nranks, mpi_err, i, j
  type(InputScalars_T) :: sclr
  type(InputArrays_T) :: inarr
  type(OutputArrays_T) :: outarr, outarr_cpu
  character(len=256) :: file_name
  character(len=*), parameter :: fmt = '(1x, a1, i2, a1, 1x, a, f11.7, 1x, a1)'
  real :: cpu_time_, doc_cpu_time_, gpu_time_(NUM_GPU_RUNS), doc_time_(NUM_GPU_RUNS), doc_stripped_time_(NUM_GPU_RUNS), gpu_stripped_time_(NUM_GPU_RUNS)
  logical :: outfile_exists
  integer, parameter :: outfile_unit = 16
  character(len=256), parameter :: outfile = 'benchmark_cloud/table.dat'

  inquire(file=outfile, exist=outfile_exists)
  if (outfile_exists) then
     open(outfile_unit, file=outfile, status="old", position="append", action="write")
  else
     open(outfile_unit, file=outfile, status="new", action="write")
  endif

  call MPI_Init(mpi_err)
  call MPI_Comm_rank(MPI_COMM_WORLD, irank, mpi_err)
  call MPI_Comm_size(MPI_COMM_WORLD, nranks, mpi_err)

  ! Input file
  write(file_name, '(a26, i2.2, a4)') 'input-data/microphys_data.', irank, '.bin'

  ! Read input data
  call get_data_from_file(file_name, sclr, inarr)
  call sclr%write_scalars()
  ! call inarr%write_arrays()

  ! CPU run
  print *, 'CPU run'
  call serial_driver_cpu(irank, sclr, inarr, outarr_cpu, cpu_time_)
  call outarr_cpu%write_arrays()
  print *, 'Done with CPU'
  write(*, fmt) '[', irank, ']', 'Time taken (cpu):', cpu_time_, 's'

#ifdef GPU_BUILD
  ! GPU run
  call serial_driver_gpu(irank, NUM_GPU_RUNS, sclr, inarr, outarr, gpu_time_)
  call print_info(outfile_unit, outarr, outarr_cpu, mpi_err, irank, nranks, gpu_time_, 'GPU')

#ifdef GPU_STRIPPED
  ! GPU stripped run
  call serial_driver_gpu_stripped(irank, NUM_GPU_RUNS, sclr, inarr, outarr, gpu_stripped_time_)
  call print_info(outfile_unit, outarr, outarr_cpu, mpi_err, irank, nranks, gpu_stripped_time_, 'GPU - no OpenMP')
#endif // GPU_STRIPPED

  ! DO CONCURRENT GPU Run
  call serial_driver_doc(irank, NUM_GPU_RUNS, sclr, inarr, outarr, doc_time_)
  call print_info(outfile_unit, outarr, outarr_cpu, mpi_err, irank, nranks, doc_time_, 'GPU - DO CONCURRENT, no OpenMP')

  ! DO CONCURRENT (Stripped) GPU Run
  !call serial_driver_doc_stripped(irank, NUM_GPU_RUNS, sclr, inarr, outarr, doc_stripped_time_)
  !call print_info(outarr, outarr_cpu, mpi_err, irank, nranks, doc_stripped_time_, 'GPU - DO CONCURRENT, no OpenMP')

#ifdef DOC_CPU
  ! DOC CPU run
  print *, 'DOC CPU run'
  call serial_driver_doc_cpu(irank, sclr, inarr, outarr, doc_cpu_time_)
  call outarr%write_arrays()
  call write_output_difference(outarr_cpu, outarr)

  write(*, *)
  write(*, fmt) '[', irank, ']', 'Time taken (doc_cpu):', doc_cpu_time_, 's'

#endif // DOC_CPU

#endif // GPU_BUILD

  call MPI_Finalize(mpi_err)

  close(outfile_unit)

  ! return 0

contains

  subroutine print_info(outfile_unit, outarr, outarr_cpu, mpi_err, irank, nranks, time_, canonical_name)
     ! Arguments
     integer, intent(in) :: outfile_unit
     type(OutputArrays_T), intent(in) :: outarr, outarr_cpu
     integer, intent(in) :: irank, nranks
     integer, intent(inout) :: mpi_err
     real, intent(in) :: time_(NUM_GPU_RUNS)
     character(len=*), intent(in) :: canonical_name

     ! Locals
     character(len=*), parameter :: fmt_print = '(1x, a1, i2, a, a, a2, 1x, f11.7, 1x, a1)'
     character(len=*), parameter :: fmt_data = '(1x)'
     integer :: i, j

     ! Code
     !call outarr%write_arrays()
     !call write_output_difference(outarr_cpu, outarr)

     call MPI_Barrier(MPI_COMM_WORLD, mpi_err)

     print *, 'Done with ', canonical_name
     ! Write output differences to stdout
     do i = 0, nranks-1
        if (i == irank) then
           write(*, *)
           do j = 1, NUM_GPU_RUNS
              write(*, fmt_print) '[', irank, '] Time taken (', canonical_name, '):', time_(j), 's'
           end do
           call write_output_difference(outarr_cpu, outarr)
        end if
        call MPI_Barrier(MPI_COMM_WORLD, mpi_err)
     end do

     ! write to outfile: code version (eg. GPU, CPU, GPU no OpenMP), compiler flags/options, OMP_THREAD_COUNT(?), runtime, diffs
     ! (RMSE?, stdev?, avg?)
  end subroutine print_info

end program main
