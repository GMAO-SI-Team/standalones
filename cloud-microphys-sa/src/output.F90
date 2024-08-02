module output_mod

#ifdef _OPENMP
  use omp_lib, only: omp_get_max_threads, omp_get_num_procs
#endif
  use iso_fortran_env, only: compiler_options, compiler_version

  implicit none

  private

  public OutputArrays_T, write_arrays, write_difference, get_data_from_file, write_data_to_file, print_info

  character(len=*), parameter :: fmt_diff = '(1x, a10, 1x, a1, 1x, e15.9, 1x, a1, 1x, e15.9)'
  character(len=*), parameter :: fmt_out = '(1x, a10, 3x, e18.10, 3x, e18.10, 3x, e18.10)'

  type OutputArrays_T
     real, allocatable, dimension (:, :) :: rain, snow, ice, graupel
     real, allocatable, dimension (:, :, :) :: m2_rain, m2_sol ! Rain and Ice fluxes (Pa kg/kg)
     real, allocatable, dimension (:, :, :) :: revap ! Rain evaporation
     real, allocatable, dimension (:, :, :) :: isubl ! Ice sublimation
   contains
     procedure, public :: write_arrays
  end type OutputArrays_T

  interface OutputArrays_T
     procedure :: initialize_
  end interface OutputArrays_T

contains

  function initialize_(iis, iie, jjs, jje, kks, kke) result (arr)

    ! Arguments
    integer, intent(in) :: iis, iie, jjs, jje, kks, kke
    type(OutputArrays_T) :: arr ! output

    ! Start
    ! print *, 'Initializing output arrays:'
    ! print *, iis, iie, jjs, jje, kks, kke
    allocate(arr%rain(iis:iie, jjs:jje), source = 0.)
    ! print *, 'shape(rain): ', shape(arr%rain)
    allocate(arr%snow, arr%ice, arr%graupel, mold = arr%rain)
    arr%snow = 0.
    arr%ice = 0.
    arr%graupel = 0.

    allocate(arr%m2_rain(iis:iie, jjs:jje, kks:kke), source = 0.)
    ! print *, 'shape(m2_rain): ', shape(arr%m2_rain)
    allocate(arr%m2_sol, arr%revap, arr%isubl, mold = arr%m2_rain)
    arr%m2_sol = 0.
    arr%revap = 0.
    arr%isubl = 0.

  end function initialize_

  subroutine write_arrays(self)

    ! Arguments
    class(OutputArrays_T), intent(in) :: self

    ! Start
    write(*, fmt_out) 'revap', minval(self%revap), maxval(self%revap), sum(self%revap)
    write(*, fmt_out) 'isubl', minval(self%isubl), maxval(self%isubl), sum(self%isubl)
    write(*, fmt_out) 'rain', minval(self%rain), maxval(self%rain), sum(self%rain)
    write(*, fmt_out) 'snow', minval(self%snow), maxval(self%snow), sum(self%snow)
    write(*, fmt_out) 'ice', minval(self%ice), maxval(self%ice), sum(self%ice)
    write(*, fmt_out) 'graupel', minval(self%graupel), maxval(self%graupel), sum(self%graupel)
    write(*, fmt_out) 'm2_rain', minval(self%m2_rain), maxval(self%m2_rain), sum(self%m2_rain)
    write(*, fmt_out) 'm2_sol', minval(self%m2_sol), maxval(self%m2_sol), sum(self%m2_sol)

  end subroutine write_arrays

  subroutine write_difference(arr1, arr2)

    ! Arguments
    type(OutputArrays_T), intent(in) :: arr1, arr2

    ! Start
    print *, ''
    print *, '-----------|-----------------|-----------------'
    print *, '   out var |     abs error   |     rel error'
    print *, '-----------|-----------------|-----------------'

    write(*, fmt_diff) 'revap', '|', norm2(arr2%revap-arr1%revap), '|', norm2(arr2%revap-arr1%revap)/norm2(arr1%revap)
    write(*, fmt_diff) 'isubl', '|', norm2(arr2%isubl-arr1%isubl), '|', norm2(arr2%isubl-arr1%isubl)/norm2(arr1%isubl)
    write(*, fmt_diff) 'rain', '|', norm2(arr2%rain-arr1%rain), '|', norm2(arr2%rain-arr1%rain)/norm2(arr1%rain)
    write(*, fmt_diff) 'snow', '|', norm2(arr2%snow-arr1%snow), '|', norm2(arr2%snow-arr1%snow)/norm2(arr1%snow)
    write(*, fmt_diff) 'ice', '|', norm2(arr2%ice-arr1%ice), '|', norm2(arr2%ice-arr1%ice)/norm2(arr1%ice)
    write(*, fmt_diff) 'graupel', '|', norm2(arr2%graupel-arr1%graupel), '|', norm2(arr2%graupel-arr1%graupel)/norm2(arr1%graupel)
    write(*, fmt_diff) 'm2_rain', '|', norm2(arr2%m2_rain-arr1%m2_rain), '|', norm2(arr2%m2_rain-arr1%m2_rain)/norm2(arr1%m2_rain)
    write(*, fmt_diff) 'm2_sol', '|', norm2(arr2%m2_sol-arr1%m2_sol), '|', norm2(arr2%m2_sol-arr1%m2_sol)/norm2(arr1%m2_sol)
    print *, '-----------|-----------------|-----------------'

  end subroutine write_difference

  subroutine get_data_from_file(file_name, arr)
     ! Arguments
     character(len=*), intent(in) :: file_name
     type(OutputArrays_T), intent(out) :: arr

     ! Locals
     integer :: file_handle, ios
     integer :: iis, iie, jjs, jje, kks, kke

     ! Start
     open(newunit=file_handle, file=file_name, form='unformatted', & !position='rewind',
           status='old', iostat=ios)

     ! scalars
     read(file_handle, iostat=ios) iis, iie, jjs, jje, kks, kke

     ! Allocate and initialize the outarr
     arr = OutputArrays_T(iis, iie, jjs, jje, kks, kke)

     ! Read into arrays
     read(file_handle, iostat=ios) &
        arr%rain, arr%snow, arr%ice, arr%graupel, &
        arr%m2_rain, arr%m2_sol, arr%revap, arr%isubl
     close(file_handle, iostat=ios)
  end subroutine get_data_from_file

  subroutine write_data_to_file(file_name, arr)
     ! Arguments
     character(len=*), intent(in) :: file_name
     type(OutputArrays_T), intent(in) :: arr

     ! Locals
     integer :: file_handle, ios
     integer :: iis, iie, jjs, jje, kks, kke

     ! Open file
     open(newunit=file_handle, file=file_name, status='replace', form='unformatted', action='write', iostat=ios)

     ! Set array boundaries
     iis = lbound(arr%m2_rain, 1)
     iie = ubound(arr%m2_rain, 1)
     jjs = lbound(arr%m2_rain, 2)
     jje = ubound(arr%m2_rain, 2)
     kks = lbound(arr%m2_rain, 3)
     kke = ubound(arr%m2_rain, 3)

     ! Write output
     write(file_handle, iostat=ios) iis, iie, jjs, jje, kks, kke
     write(file_handle, iostat=ios) &
        arr%rain, arr%snow, arr%ice, arr%graupel, &
        arr%m2_rain, arr%m2_sol, arr%revap, arr%isubl
     close(file_handle)

  end subroutine write_data_to_file

  subroutine print_info(outfile_unit, outarr, outarr_cpu, mpi_err, irank, nranks, cpu_time_, time_, canonical_name, scale_i, scale_j)
     ! Arguments
     integer, intent(in) :: outfile_unit
     type(OutputArrays_T), intent(in) :: outarr, outarr_cpu
     integer, intent(in) :: irank, nranks
     integer, intent(inout) :: mpi_err
     real, intent(in) :: cpu_time_, time_(:)
     character(len=*), intent(in) :: canonical_name
     integer, intent(in) :: scale_i, scale_j

     ! Locals
     character(len=*), parameter :: fmt_print = '(1x, a1, i2, a, a, a2, 1x, f11.7, 1x, a1)'
     character(len=*), parameter :: fmt_data = '(a, a1, 2(f11.7, a1), e15.9, a1, i, a1, i, a1, a, a1, a, a1, a, a1, i2, a1, i2)'
     integer :: i, j, num_threads
     character(len=256) :: host_name, acc_num_cores
     real :: rms

     ! Code
#ifdef MPI_VERSION
     call MPI_Barrier(MPI_COMM_WORLD, mpi_err)
#endif // MPI_VERSION

     print *, 'Done with ', trim(canonical_name)
     ! Write output differences to stdout
     do i = 0, nranks
        if (i == irank) then
           write(*, *)
           do j = 1, size(time_)
              write(*, fmt_print) '[', irank, '] Time taken (', trim(canonical_name), '):', time_(j), 's'
           end do
           call write_difference(outarr_cpu, outarr)
        end if
#ifdef MPI_VERSION
        call MPI_Barrier(MPI_COMM_WORLD, mpi_err)
#endif // MPI_VERSION
     end do

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

#ifdef _OPENMP
     num_threads = omp_get_max_threads()
#else
     num_threads = -1
#endif

     call hostnm(host_name)
     call get_environment_variable("ACC_NUM_CORES", acc_num_cores)

     write(outfile_unit, fmt_data) trim(canonical_name), ',', cpu_time_, ',', time_(size(time_)), ',', &
           rms, ',', nranks, ',', num_threads, ',', compiler_version(), ',', trim(host_name), ',', &
           trim(acc_num_cores), ',', scale_i, ',', scale_j
  end subroutine print_info

end module output_mod
