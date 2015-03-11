!> \file
!> \author Chris Bradley
!> \brief This module handles all constants shared across constraint condition routines.
!>
!> \section LICENSE
!>
!> Version: MPL 1.1/GPL 2.0/LGPL 2.1
!>
!> The contents of this file are subject to the Mozilla Public License
!> Version 1.1 (the "License"); you may not use this file except in
!> compliance with the License. You may obtain a copy of the License at
!> http://www.mozilla.org/MPL/
!>
!> Software distributed under the License is distributed on an "AS IS"
!> basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
!> License for the specific language governing rights and limitations
!> under the License.
!>
!> The Original Code is OpenCMISS
!>
!> The Initial Developer of the Original Code is University of Auckland,
!> Auckland, New Zealand, the University of Oxford, Oxford, United
!> Kingdom and King's College, London, United Kingdom. Portions created
!> by the University of Auckland, the University of Oxford and King's
!> College, London are Copyright (C) 2007-2010 by the University of
!> Auckland, the University of Oxford and King's College, London.
!> All Rights Reserved.
!>
!> Contributor(s):
!>
!> Alternatively, the contents of this file may be used under the terms of
!> either the GNU General Public License Version 2 or later (the "GPL"), or
!> the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
!> in which case the provisions of the GPL or the LGPL are applicable instead
!> of those above. If you wish to allow use of your version of this file only
!> under the terms of either the GPL or the LGPL, and not to allow others to
!> use your version of this file under the terms of the MPL, indicate your
!> decision by deleting the provisions above and replace them with the notice
!> and other provisions required by the GPL or the LGPL. If you do not delete
!> the provisions above, a recipient may use your version of this file under
!> the terms of any one of the MPL, the GPL or the LGPL.
!>

!> This module defines all constants shared across constraint matrices routines.
MODULE CONSTRAINT_MATRICES_CONSTANTS

  USE KINDS

  IMPLICIT NONE

  !Module parameters

  !> \addtogroup CONSTRAINT_MATRICES_ROUTINES_ConstraintMatricesTimeDependenceTypes CONSTRAINT_MATRICES_ROUTINES::ConstraintMatricesTimeDependenceTypes
  !> \brief Constraint matrices time dependency types
  !> \see CONSTRAINT_MATRICES_ROUTINES
  !>@{
  INTEGER(INTG), PARAMETER :: NUMBER_OF_CONSTRAINT_MATRIX_TYPES=3
  INTEGER(INTG), PARAMETER :: CONSTRAINT_MATRIX_STATIC=1 !<Constraint matrix is of static type \see CONSTRAINT_MATRICES_ROUTINES_ConstraintMatricesTimeDependenceTypes,CONSTRAINT_MATRICES_ROUTINES
  INTEGER(INTG), PARAMETER :: CONSTRAINT_MATRIX_FIRST_ORDER_DYNAMIC=2 !<Constraint matrix is of first order dynamic type \see CONSTRAINT_MATRICES_ROUTINES_ConstraintMatricesTimeDependenceTypes,CONSTRAINT_MATRICES_ROUTINES
  INTEGER(INTG), PARAMETER :: CONSTRAINT_MATRIX_SECOND_ORDER_DYNAMIC=3 !<Constraint matrix is of second order dynamic type \see CONSTRAINT_MATRICES_ROUTINES_ConstraintMatricesTimeDependenceTypes,CONSTRAINT_MATRICES_ROUTINES
  !>@}

  !> \addtogroup CONSTRAINT_MATRICES_CONSTANTS_DynamicMatrixTypes CONSTRAINT_MATRICES_CONSTANTS:DynamicMatrixTypes
  !> \brief Type of matrix in a dynamic constraint condition
  !>@{
  INTEGER(INTG), PARAMETER :: CONSTRAINT_MATRIX_STIFFNESS=1 !<A stiffness matrix (multiplies displacement values)
  INTEGER(INTG), PARAMETER :: CONSTRAINT_MATRIX_DAMPING=2 !<A damping matrix (multiplies velocity values)
  INTEGER(INTG), PARAMETER :: CONSTRAINT_MATRIX_MASS=3 !<A mass matrix (multiplies acceleration values)
  !>@}
  

END MODULE CONSTRAINT_MATRICES_CONSTANTS