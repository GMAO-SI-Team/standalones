module MicrophysicsSerialDriverDOC

  use input_mod, only: InputScalars_T, InputArrays_T
  use output_mod, only: OutputArrays_T
  use gfdl2_cloud_microphys_doc_mod, only: gfdl_cloud_microphys_doc_init => gfdl_cloud_microphys_init
  use gfdl2_cloud_microphys_doc_mod, only: gfdl_cloud_microphys_doc_driver => gfdl_cloud_microphys_driver

  implicit none

  private

  public :: serial_driver

contains

  subroutine serial_driver(irank, n_doc_runs, sclr, inarr, outarr, doc_time_)

    implicit none

    ! Arguments
    integer, intent(in):: irank
    integer, intent(in) :: n_doc_runs
    type(InputScalars_T), intent(in) :: sclr
    type(InputArrays_T), intent(in) :: inarr
    type(OutputArrays_T), intent(out) :: outarr
    real, intent(out) :: doc_time_(n_doc_runs)

    ! Locals
    real :: start, finish
    integer :: i_doc_run

    ! Set output arrays
    outarr = OutputArrays_T(sclr%iis, sclr%iie, sclr%jjs, sclr%jje, sclr%kks, sclr%kke)
    ! call outarr%write_arrays()

    call gfdl_cloud_microphys_doc_init()

    do i_doc_run = 1, n_doc_runs
       call cpu_time(start)
       call gfdl_cloud_microphys_doc_driver ( &
            ! intent (in)
            inarr%qv, inarr%ql, inarr%qr, &
            ! intent (inout)
            inarr%qi, inarr%qs, &
            ! intent (in)
            inarr%qg, inarr%qa, inarr%qn, &
            ! intent (inout)
            inarr%qv_dt, inarr%ql_dt, inarr%qr_dt, inarr%qi_dt, &
            inarr%qs_dt, inarr%qg_dt, inarr%qa_dt, inarr%pt_dt, &
            ! intent (in)
            inarr%pt, &
            ! intent (inout)
            inarr%w, &
            ! intent (in)
            inarr%uin, inarr%vin, &
            ! intent (inout)
            inarr%udt, inarr%vdt, &
            ! intent (in)
            inarr%dz, inarr%delp, inarr%area, sclr%dt_in, inarr%land, inarr%cnv_fraction, &
            inarr%srf_type, inarr%eis, inarr%rhcrit, sclr%anv_icefall, sclr%lsc_icefall, &
            ! intent (out)
            outarr%revap, outarr%isubl, &
            outarr%rain, outarr%snow, outarr%ice, outarr%graupel, &
            outarr%m2_rain, outarr%m2_sol, &
            ! intent (in)
            sclr%hydrostatic, sclr%phys_hydrostatic, &
            sclr%iis, sclr%iie, sclr%jjs, sclr%jje, sclr%kks, sclr%kke, sclr%ktop, sclr%kbot)
       call cpu_time(finish)
       doc_time_(i_doc_run) = finish - start
    end do

  end subroutine serial_driver

end module MicrophysicsSerialDriverDOC

