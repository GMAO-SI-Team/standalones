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
  type(OutputArrays_T) :: outarr1, outarr2, outarr3, outarr4, outarr5, outarr_cpu
  character(len=256) :: file_name
  character(len=*), parameter :: fmt = '(1x, a1, i2, a1, 1x, a, f11.7, 1x, a1)'
  real :: cpu_time_, doc_cpu_time_, gpu_time_(NUM_GPU_RUNS), doc_time_(NUM_GPU_RUNS), doc_stripped_time_(NUM_GPU_RUNS), gpu_stripped_time_(NUM_GPU_RUNS)

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

#ifdef GPU_BUILD
  print *, "Done with CPU"

  ! GPU run
  print *, 'GPU run'
  call serial_driver_gpu(irank, NUM_GPU_RUNS, sclr, inarr, outarr2, gpu_time_)
  call outarr2%write_arrays()
  !call write_output_difference(outarr_cpu, outarr2)

  ! Hold for all to finish
  call MPI_Barrier(MPI_COMM_WORLD, mpi_err)

  print *, "Done with GPU"
  ! Write output differences to stdout
  do i = 0, nranks-1
     if (i == irank) then
        write(*, *)
        write(*, fmt) '[', irank, ']', 'Time taken (cpu):', cpu_time_, 's'
        do j = 1, NUM_GPU_RUNS
           write(*, fmt) '[', irank, ']', 'Time taken (gpu):', gpu_time_(j), 's'
        end do
        call write_output_difference(outarr_cpu, outarr2)
     end if
     call MPI_Barrier(MPI_COMM_WORLD, mpi_err)
  end do

#ifdef GPU_STRIPPED
  ! This may be a one-and-done, hence the #ifdef guards
  ! GPU stripped run
  print *, 'GPU Stripped run'
  call serial_driver_gpu_stripped(irank, NUM_GPU_RUNS, sclr, inarr, outarr5, gpu_stripped_time_)
  call outarr5%write_arrays()
  call write_output_difference(outarr_cpu, outarr5)

  ! Hold for all to finish
  call MPI_Barrier(MPI_COMM_WORLD, mpi_err)

  print *, "Done with GPU Stripped"
  ! Write output differences to stdout
  do i = 0, nranks-1
     if (i == irank) then
        write(*, *)
        do j = 1, NUM_GPU_RUNS
           write(*, fmt) '[', irank, ']', 'Time taken (gpu_str):', gpu_stripped_time_(j), 's'
        end do
        call write_output_difference(outarr_cpu, outarr5)
     end if
     call MPI_Barrier(MPI_COMM_WORLD, mpi_err)
  end do
#endif // GPU_STRIPPED

  ! DO CONCURRENT GPU Run
  call serial_driver_doc(irank, NUM_GPU_RUNS, sclr, inarr, outarr3, doc_time_)
  call outarr3%write_arrays()

  ! Hold for all to finish
  call MPI_Barrier(MPI_COMM_WORLD, mpi_err)

  print *, "Done with DOC"

  ! Write output differences to stdout
  do i = 0, nranks-1
     if (i == irank) then
        write(*, *)
        do j = 1, NUM_GPU_RUNS
           write(*, fmt) '[', irank, ']', 'Time taken (doc):', doc_time_(j), 's'
        end do
        call write_output_difference(outarr_cpu, outarr3)
     end if
     call MPI_Barrier(MPI_COMM_WORLD, mpi_err)
  end do

  ! DO CONCURRENT (Stripped) GPU Run
  call serial_driver_doc_stripped(irank, NUM_GPU_RUNS, sclr, inarr, outarr4, doc_stripped_time_)
  call outarr4%write_arrays()

  ! Hold for all to finish
  call MPI_Barrier(MPI_COMM_WORLD, mpi_err)

  print *, "Done with DOC Stripped"

  ! Write output differences to stdout
  do i = 0, nranks-1
     if (i == irank) then
        write(*, *)
        do j = 1, NUM_GPU_RUNS
           write(*, fmt) '[', irank, ']', 'Time taken (doc_str):', doc_stripped_time_(j), 's'
        end do
        call write_output_difference(outarr_cpu, outarr4)
     end if
     call MPI_Barrier(MPI_COMM_WORLD, mpi_err)
  end do

#ifdef DOC_CPU
  ! DOC CPU run
  print *, 'DOC CPU run'
  call serial_driver_doc_cpu(irank, sclr, inarr, outarr1, doc_cpu_time_)
  call outarr1%write_arrays()
  call write_output_difference(outarr_cpu, outarr1)

  write(*, *)
  write(*, fmt) '[', irank, ']', 'Time taken (doc_cpu):', doc_cpu_time_, 's'

#endif // DOC_CPU

#endif // GPU_BUILD

  call MPI_Finalize(mpi_err)

end program main
