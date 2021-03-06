! Simple demonstration of how to use dftd3 as a library.
!
! Copyright (C) 2016, Bálint Aradi
!
! This program is free software; you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation; either version 1, or (at your option)
! any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
! GNU General Public License for more details.
!
! For the GNU General Public License, see <http://www.gnu.org/licenses/>
!

! Tests the dftd3 API by calculating the dispersion for a small DNA fragment.
!
program testapi
  use dftd3_api
  implicit none

  ! Working precision
  integer, parameter :: wp = kind(1.0d0)

  ! Same conversion factor as in dftd3
  real(wp), parameter :: AA__Bohr = 1.0_wp / 0.52917726_wp

  integer, parameter :: nAtoms = 60
  
  ! Coordinates in Angstrom as found in dna.xyz/dna.poscar
  ! They must be converted to Bohr before passed to dftd3
  real(wp), parameter :: coords(3, nAtoms) = reshape([ &
       &  0.0000000000E+00,   0.0000000000E+00,   0.0000000000E+00, &
       &  1.5975370000E+00,   3.4000000000E+00,   1.3555503000E+01, &
       &  1.1681140000E+00,   3.4000000000E+00,   2.5437400000E+00, &
       &  1.7676000000E-02,   3.4000000000E+00,   4.2538900001E-01, &
       &  3.4850740000E+00,   3.4000000000E+00,   2.7710270000E+00, &
       &  7.6768400000E-01,   3.3989780000E+00,   5.3936670000E+00, &
       &  7.3234780000E+00,   3.3979460000E+00,   7.2046630001E+00, &
       &  7.9973540000E+00,   7.9979460000E+00,   8.9431150000E+00, &
       &  9.3421600000E-01,   7.9989780000E+00,   6.8246890001E+00, &
       &  3.5392970000E+00,   3.4000000000E+00,   1.4690835000E+01, &
       &  6.9468890000E+00,   0.0000000000E+00,   2.2098390000E+00, &
       &  2.1664490000E+00,   0.0000000000E+00,   6.0490399999E-01, &
       &  5.9764900000E-01,   0.0000000000E+00,   3.9665170000E+00, &
       &  2.8963550000E+00,   0.0000000000E+00,   3.5978550000E+00, &
       &  1.2476610000E+00,   3.4000000000E+00,   1.4887828000E+01, &
       &  0.0000000000E+00,   0.0000000000E+00,   1.3774990000E+00, &
       &  2.9777280000E+00,   3.4000000000E+00,   1.3506948000E+01, &
       &  2.8687810000E+00,   3.3969730000E+00,   8.5489480001E+00, &
       &  2.3989960000E+00,   3.4000000000E+00,   1.9811340000E+00, &
       &  1.3544010000E+00,   0.0000000000E+00,   1.7258800001E+00, &
       &  7.5127000000E-02,   3.4000000000E+00,   1.7561490000E+00, &
       &  1.9061090000E+00,   3.3979900000E+00,   6.1902930000E+00, &
       &  1.6452660000E+00,   0.0000000000E+00,   3.1097239999E+00, &
       &  7.4527150000E+00,   3.3989650000E+00,   5.8167949999E+00, &
       &  3.7678320000E+00,   7.9969730000E+00,   9.3428280000E+00, &
       &  3.9381800000E-01,   3.3969410000E+00,   8.0702940000E+00, &
       &  2.4691580000E+00,   3.4000000000E+00,   5.6879400000E-01, &
       &  2.2376450000E+00,   7.9979900000E+00,   7.3060369999E+00, &
       &  2.3830090000E+00,   7.9969600000E+00,   8.7641970000E+00, &
       &  1.2524580000E+00,   7.9969410000E+00,   9.5084980001E+00, &
       &  7.3404620000E+00,   0.0000000000E+00,   3.4823659999E+00, &
       &  7.7698420000E+00,   7.9989650000E+00,   7.5679350000E+00, &
       &  1.3225960000E+00,   0.0000000000E+00,   1.4602476000E+01, &
       &  1.6763420000E+00,   3.3969600000E+00,   7.6375549999E+00, &
       &  6.4875910000E+00,   3.3989510000E+00,   5.0697310000E+00, &
       &  3.2008920000E+00,   7.9979920000E+00,   6.5318389999E+00, &
       &  6.6466190000E+00,   7.9989510000E+00,   7.0905070000E+00, &
       &  3.0344090000E+00,   3.3979920000E+00,   5.6861440000E+00, &
       &  7.1293820000E+00,   3.4000000000E+00,   2.2924470000E+00, &
       &  9.5438700000E-01,   3.4000000000E+00,   1.2777516000E+01, &
       &  3.5095790000E+00,   3.4000000000E+00,   1.2564143000E+01, &
       &  4.3985140000E+00,   3.4000000000E+00,   2.3442280000E+00, &
       &  9.1011100000E-01,   3.3989880000E+00,   4.3575570000E+00, &
       &  3.4995660000E+00,   2.5189940000E+00,   8.3675460000E+00, &
       &  3.4995590000E+00,   4.2749920000E+00,   8.3685660000E+00, &
       &  2.5648610000E+00,   3.3959430000E+00,   9.6000430000E+00, &
       &  3.3898970000E+00,   3.4000000000E+00,   3.7890790001E+00, &
       &  7.1643930000E+00,   7.9979410000E+00,   9.5158290000E+00, &
       &  1.2708850000E+00,   7.9969160000E+00,   1.0593501000E+01, &
       &  3.7408510000E+00,   7.9959430000E+00,   1.0436648000E+01, &
       &  4.3321080000E+00,   8.7499200000E-01,   9.0081480000E+00, &
       &  4.3318560000E+00,   7.1189940000E+00,   9.0071590001E+00, &
       &  8.0880600000E-01,   7.9989880000E+00,   5.7863820000E+00, &
       &  3.0628790000E+00,   0.0000000000E+00,   4.6066960000E+00, &
       &  3.6714350000E+00,   0.0000000000E+00,   2.9530440000E+00, &
       &  1.5975370000E+00,   0.0000000000E+00,   1.3555503000E+01, &
       &  7.1803370000E+00,   0.0000000000E+00,   1.4410882000E+01, &
       &  6.5619480000E+00,   0.0000000000E+00,   4.2412910000E+00, &
       &  1.3605600000E-01,   3.3969160000E+00,   9.1243960000E+00, &
       &  6.3723670000E+00,   3.3979410000E+00,   7.5470280000E+00 &
       &] * AA__Bohr, [3, nAtoms])
  
  integer, parameter :: species(nAtoms) = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, &
     & 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, &
     & 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4]

  ! Lattice vectors in Angstrom as found in dna.xyz/dna.poscar
  ! They must be converted to Bohr before passed to dftd3
  real(wp), parameter :: latVecs(3, 3) = reshape([&
       &  8.0000000000E+00,   0.0000000000E+00,   0.0000000000E+00, &
       &  0.0000000000E+00,   8.0000000000E+00,   0.0000000000E+00, &
       &  0.0000000000E+00,   0.0000000000E+00,   1.5000000000E+01  &
       & ] * AA__Bohr, [3, 3])

  integer, parameter :: nSpecies = 4
  character(2), parameter :: speciesNames(nSpecies) = [ 'N ', 'C ', 'O ', 'H ']
  

  type(dftd3_input) :: input
  type(dftd3_calc) :: dftd3
  integer :: atnum(nAtoms), i
  real(wp) :: edisp
  real(wp) :: grads(3, nAtoms), stress(3, 3)

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! Initialize input
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  ! You can set input variables if you like, or just leave them on their
  ! defaults, which are the same as the dftd3 program uses.
  
  !! Threebody interactions (default: .false.)
  !input%threebody = .true.
  !
  !! Numerical gradients (default: .false.)
  !input%numgrad = .false.
  !
  !! Cutoffs (below you find the defaults)
  !input%cutoff = sqrt(9000.0_wp)
  !input%cutoff_cn = sqrt(1600.0_wp)

  ! Initialize dftd3
  call dftd3_init(dftd3, input)

  ! Choose functional. Alternatively you could set the parameters manually
  ! by the dftd3_set_params() function.
  call dftd3_set_functional(dftd3, func='dftb3', version=4, tz=.false.)

  ! Convert species name to atomic number for each atom
  atnum(:) = get_atomic_number(speciesNames(species))

  ! Calculate dispersion and gradients for non-periodic case
  call dftd3_dispersion(dftd3, coords, atnum, edisp, grads)
  write(*, "(A)") "*** Dispersion for non-periodic case"
  write(*, "(A,ES20.12)") "Energy [au]:", edisp
  write(*, "(A)") "Gradients [au]:"
  write(*, "(3ES20.12)") grads
  write(*, *)
  
  ! Calculate dispersion and gradients for periodic case
  call dftd3_pbc_dispersion(dftd3, coords, atnum, latVecs, edisp, grads, stress)
  write(*, "(A)") "*** Dispersion for periodic case"
  write(*, "(A,ES20.12)") "Energy [au]:", edisp
  write(*, "(A)") "Gradients [au]:"
  write(*, "(3ES20.12)") grads
  write(*, "(A)") "Stress [au]:"
  write(*, "(3ES20.12)") stress

end program testapi
