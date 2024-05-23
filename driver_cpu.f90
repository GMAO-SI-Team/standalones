module driver_cpu_mod

  use tp_core_mod, only: fv_tp_2d
  use fv_arrays_mod, only: fv_grid_bounds_type, fv_grid_type
  use input_arrays_mod, only: InputArrays_T
  use output_arrays_mod, only: OutputArrays_T

  implicit none

  private

  public run_driver

  integer, parameter :: hord = 8
  real, parameter :: lim_fac = 1.0

contains

  subroutine run_driver() bind(C, name='run_driver')

    ! Locals
    type(fv_grid_bounds_type) :: bd
    type(fv_grid_type) :: gridstruct
    type(InputArrays_T) :: in_arrays
    type(OutputArrays_T) :: out_arrays
    integer :: npx, npy
    integer :: iter
    real :: start, finish
    integer :: n, n_iterations

    ! Get resolution and number of iterations
    call get_cmdline_args_(n, n_iterations)

    ! Initialize
    bd = fv_grid_bounds_type(n)
    npx = n + 1; npy = n + 1
    gridstruct = fv_grid_type(bd, npx, npy, .false., 0)
    in_arrays = InputArrays_T(bd, npx, npy, gridstruct)
    out_arrays = OutputArrays_T(bd)

    ! Run fv_tp_2d
    call cpu_time(start)
    do iter = 1, n_iterations
       call fv_tp_2d( &
            in_arrays%q, in_arrays%crx, in_arrays%cry, &
            npx, npy, hord, &
            out_arrays%fx, out_arrays%fy, &
            in_arrays%xfx, in_arrays%yfx, &
            gridstruct, bd, &
            in_arrays%ra_x, in_arrays%ra_y, &
            lim_fac)
    end do
    call cpu_time(finish)
    
    print *, 'time taken: ', finish - start, 's'
    print *, 'sum(fx): ', sum(out_arrays%fx), ', sum(fy): ', sum(out_arrays%fy)

  end subroutine run_driver

  subroutine usage(program_name)

    ! Arguments
    character(len=256) :: program_name

    print *, 'Usage: ', trim(program_name), ' <resolution> <number-of-iterations>'

  end subroutine usage

  subroutine get_cmdline_args_(resolution, n_iterations)

    ! Arguments
    integer, intent(out) :: resolution
    integer, intent(out) :: n_iterations
    ! Local
    integer :: argc
    character(len=256) :: program_name, res_char, niter_char

    call get_command_argument(0, program_name)
    argc = command_argument_count()
    if (2 /= argc) then
       call usage(program_name)
       error stop ' ERROR: cmdline argument count is incorrect'
    end if
    call get_command_argument(1, res_char); read(res_char, *) resolution
    call get_command_argument(2, niter_char); read(niter_char, *) n_iterations

    
  end subroutine get_cmdline_args_

end module driver_cpu_mod
