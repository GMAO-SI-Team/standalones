program main

  use mpi
  use MicrophysicsSerialDriverCPU, only: serial_driver_cpu => serial_driver
#ifdef GPU_BUILD
  use MicrophysicsSerialDriverGPU, only: serial_driver_gpu => serial_driver
#endif
  use input_mod, only: InputScalars_T, InputArrays_T, get_data_from_file
  use output_mod, only: OutputArrays_T, write_output_difference => write_difference

  implicit none

  integer, parameter :: NUM_GPU_RUNS = 1
  integer :: irank, nranks, mpi_err, i, j
  type(InputScalars_T) :: sclr
  type(InputArrays_T) :: inarr
  type(OutputArrays_T) :: outarr1, outarr2
  character(len=256) :: file_name
  character(len=*), parameter :: fmt = '(1x, a1, i2, a1, 1x, a, f11.7, 1x, a1)'
  real :: cpu_time_, gpu_time_(NUM_GPU_RUNS)

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
  call serial_driver_cpu(irank, sclr, inarr, outarr1, cpu_time_)
  call outarr1%write_arrays()

#ifdef GPU_BUILD
  ! GPU run
  print *, 'GPU run'
  call serial_driver_gpu(irank, NUM_GPU_RUNS, sclr, inarr, outarr2, gpu_time_)
  call outarr2%write_arrays()

  ! Write output differences to stdout
  call MPI_Barrier(MPI_COMM_WORLD, mpi_err)
  do i = 0, nranks-1
     if (i == irank) then
        write(*, *)
        write(*, fmt) '[', irank, ']', 'Time taken (cpu):', cpu_time_, 's'
        do j = 1, NUM_GPU_RUNS
           write(*, fmt) '[', irank, ']', 'Time taken (gpu):', gpu_time_(j), 's'
        end do
        call write_output_difference(outarr1, outarr2)
     end if
     call MPI_Barrier(MPI_COMM_WORLD, mpi_err)
  end do
#endif

  call MPI_Finalize(mpi_err)

end program main
