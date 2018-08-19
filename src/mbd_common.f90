! This Source Code Form is subject to the terms of the Mozilla Public
! License, v. 2.0. If a copy of the MPL was not distributed with this
! file, You can obtain one at http://mozilla.org/MPL/2.0/.
module mbd_common

implicit none

private
public :: tostr, diff3, diff5, print_matrix, dp, lower, pi, mbd_exc, diff7, &
    findval

integer, parameter :: dp = kind(0.d0)
real(dp), parameter :: pi = acos(-1.d0)

interface tostr
    module procedure tostr_int_
    module procedure tostr_dble_
end interface

integer, parameter, public :: &
    MBD_EXC_NEG_EIGVALS = 1, &
    MBD_EXC_NEG_POL = 2, &
    MBD_EXC_LINALG = 3

type :: mbd_exc
    integer :: code = 0
    character(50) :: origin = '(unknown)'
    character(150) :: msg = ''
end type

contains


character(len=50) elemental function tostr_int_(k, format)
    implicit none

    integer, intent(in) :: k
    character(*), intent(in), optional :: format

    if (present(format)) then
        write (tostr_int_, format) k
    else
        write (tostr_int_, "(i20)") k
    end if
    tostr_int_ = adjustl(tostr_int_)
end function tostr_int_


character(len=50) elemental function tostr_dble_(x, format)
    implicit none

    double precision, intent(in) :: x
    character(*), intent(in), optional :: format

    if (present(format)) then
        write (tostr_dble_, format) x
    else
        write (tostr_dble_, "(g50.17e3)") x
    end if
    tostr_dble_ = adjustl(tostr_dble_)
end function tostr_dble_


real(dp) pure function diff3(x, delta)
    real(dp), intent(in) :: x(-1:)
    real(dp), intent(in) :: delta

    diff3 = (x(1)-x(-1))/(2*delta)
end function


real(dp) pure function diff5(x, delta)
    real(dp), intent(in) :: x(-2:)
    real(dp), intent(in) :: delta

    diff5 = (1.d0/12*x(-2)-2.d0/3*x(-1)+2.d0/3*x(1)-1.d0/12*x(2))/delta
end function


real(dp) pure function diff7(x, delta)
    real(dp), intent(in) :: x(-3:)
    real(dp), intent(in) :: delta

    diff7 = (-1.d0/60*x(-3)+3.d0/20*x(-2)-3.d0/4*x(-1)+3.d0/4*x(1)-3.d0/20*x(2)+1.d0/60*x(3))/delta
end function


subroutine print_matrix(label, A, prec)
    character(len=*), intent(in) :: label
    real(dp), intent(in) :: A(:, :)
    integer, optional, intent(in) :: prec

    integer :: m, n, i, j, prec_
    character(len=10) :: fm

    if (present(prec)) then
        prec_ = prec
    else
        prec_ = 3
    end if
    m = size(A, 1)
    n = size(A, 2)
    write (fm, '("(g",i2,".",i1,")")') prec_+8, prec_
    write (6, '(A,":")') label
    do i = 1, m
        do j = 1, n
            write (6, fm, advance="no") A(i, j)
        end do
        write (6, *)
    end do
end subroutine


elemental pure function lower(str)
    character(len=*), intent(in) :: str
    character(len=len(str)) :: lower

    integer :: i

    do i = 1, len(str)
        select case (str(i:i))
            case ('A':'Z')
                lower(i:i) = achar(iachar(str(i:i))+32)
            case default
                lower(i:i) = str(i:i)
        end select
    end do
end function


integer pure function findval(array, val)
    integer, intent(in) :: array(:), val

    integer :: i

    findval = 0
    do i = 1, size(array)
        if (val == array(i)) then
            findval = i
            return
        end if
    end do
end function

end module
