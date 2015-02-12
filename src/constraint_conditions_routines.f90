!> \file
!> \author Chris Bradley
!> \brief This module contains all constraint conditions routines.
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
!> Contributor(s): Sander Arens
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

!>This module contains all constraint conditions routines.
MODULE CONSTRAINT_CONDITIONS_ROUTINES

  USE BASE_ROUTINES
  USE BASIS_ROUTINES
  USE FIELD_ROUTINES
  USE INPUT_OUTPUT
  USE CONSTRAINT_CONDITIONS_CONSTANTS
  USE CONSTRAINT_EQUATIONS_ROUTINES
  USE CONSTRAINT_MAPPING_ROUTINES
  USE CONSTRAINT_MATRICES_ROUTINES
  USE CONSTRAINT_OPERATORS_ROUTINES
  USE ISO_VARYING_STRING
  USE KINDS
  USE MATRIX_VECTOR
  USE STRINGS
  USE TIMER
  USE TYPES

  IMPLICIT NONE

  !Module types

  !Module variables

  !Interfaces

  PUBLIC CONSTRAINT_CONDITION_ASSEMBLE

  PUBLIC CONSTRAINT_CONDITION_CREATE_FINISH,CONSTRAINT_CONDITION_CREATE_START

  PUBLIC CONSTRAINT_CONDITION_DEPENDENT_VARIABLE_ADD

  PUBLIC CONSTRAINT_CONDITION_DESTROY

  PUBLIC CONSTRAINT_CONDITION_EQUATIONS_CREATE_FINISH,CONSTRAINT_CONDITION_EQUATIONS_CREATE_START

  PUBLIC CONSTRAINT_CONDITION_EQUATIONS_DESTROY
  
  PUBLIC CONSTRAINT_CONDITION_JACOBIAN_EVALUATE,CONSTRAINT_CONDITION_RESIDUAL_EVALUATE

  PUBLIC CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_FINISH,CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_START

  PUBLIC CONSTRAINT_CONDITION_METHOD_GET,CONSTRAINT_CONDITION_METHOD_SET

  PUBLIC CONSTRAINT_CONDITION_OPERATOR_GET,CONSTRAINT_CONDITION_OPERATOR_SET

  PUBLIC CONSTRAINT_CONDITION_USER_NUMBER_FIND

  PUBLIC CONSTRAINT_CONDITIONS_FINALISE,CONSTRAINT_CONDITIONS_INITIALISE

CONTAINS

  !
  !================================================================================================================================
  !

  !>Assembles the equations for an constraint condition.
  SUBROUTINE CONSTRAINT_CONDITION_ASSEMBLE(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to assemble the equations for.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(VARYING_STRING) :: LOCAL_ERROR
 
    CALL ENTERS("CONSTRAINT_CONDITION_ASSEMBLE",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
      IF(ASSOCIATED(EQUATIONS)) THEN
        IF(CONSTRAINT_EQUATIONS%CONSTRAINT_EQUATIONS_FINISHED) THEN
          SELECT CASE(CONSTRAINT_CONDITION%METHOD)
          CASE(CONSTRAINT_CONDITION_LAGRANGE_MULTIPLIERS_METHOD,CONSTRAINT_CONDITION_PENALTY_METHOD)
            SELECT CASE(CONSTRAINT_EQUATIONS%TIME_DEPENDENCE)
            CASE(CONSTRAINT_CONDITION_STATIC)
              SELECT CASE(CONSTRAINT_EQUATIONS%LINEARITY)
              CASE(CONSTRAINT_CONDITION_LINEAR)
                SELECT CASE(CONSTRAINT_CONDITION%SOLUTION_METHOD)
                CASE(CONSTRAINT_CONDITION_FEM_SOLUTION_METHOD)
                  CALL CONSTRAINT_CONDITION_ASSEMBLE_STATIC_LINEAR_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_BEM_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_FD_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_FV_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_GFEM_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_GFV_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The constraint condition solution method of "// &
                    & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%SOLUTION_METHOD,"*",ERR,ERROR))// &
                    & " is invalid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                END SELECT
              CASE(CONSTRAINT_CONDITION_NONLINEAR)
                SELECT CASE(CONSTRAINT_CONDITION%SOLUTION_METHOD)
                CASE(CONSTRAINT_CONDITION_FEM_SOLUTION_METHOD)
                  CALL CONSTRAINT_CONDITION_ASSEMBLE_STATIC_NONLINEAR_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_BEM_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_FD_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_FV_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_GFEM_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_GFV_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The constraint condition solution method of "// &
                    & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%SOLUTION_METHOD,"*",ERR,ERROR))// &
                    & " is invalid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                END SELECT
              CASE(CONSTRAINT_CONDITION_NONLINEAR_BCS)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="The equations linearity of "// &
                  & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_EQUATIONS%LINEARITY,"*",ERR,ERROR))//" is invalid."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(CONSTRAINT_CONDITION_FIRST_ORDER_DYNAMIC,CONSTRAINT_CONDITION_SECOND_ORDER_DYNAMIC)
              SELECT CASE(CONSTRAINT_EQUATIONS%LINEARITY)
              CASE(CONSTRAINT_CONDITION_LINEAR)
                SELECT CASE(CONSTRAINT_CONDITION%SOLUTION_METHOD)
                CASE(CONSTRAINT_CONDITION_FEM_SOLUTION_METHOD)
                  CALL CONSTRAINT_CONDITION_ASSEMBLE_DYNAMIC_LINEAR_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_BEM_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_FD_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_FV_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_GFEM_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE(CONSTRAINT_CONDITION_GFV_SOLUTION_METHOD)
                  CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The constraint condition solution method of "// &
                    & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%SOLUTION_METHOD,"*",ERR,ERROR))// &
                    & " is invalid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                END SELECT
              CASE(CONSTRAINT_CONDITION_NONLINEAR)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_NONLINEAR_BCS)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="The constraint condition linearity of "// &
                  & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_EQUATIONS%LINEARITY,"*",ERR,ERROR))//" is invalid."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(CONSTRAINT_CONDITION_TIME_STEPPING)
              CALL FLAG_ERROR("Time stepping equations are not assembled.",ERR,ERROR,*999)
            CASE DEFAULT
              LOCAL_ERROR="The equations time dependence type of "// &
                & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_EQUATIONS%TIME_DEPENDENCE,"*",ERR,ERROR))//" is invalid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            END SELECT
          CASE(CONSTRAINT_CONDITION_AUGMENTED_LAGRANGE_METHOD)
            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
          CASE(CONSTRAINT_CONDITION_POINT_TO_POINT_METHOD)
            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
          CASE DEFAULT
            LOCAL_ERROR="The constraint condition method of "// &
              & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%METHOD,"*",ERR,ERROR))// &
              & " is invalid."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Constraint equations have not been finished.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Constraint condition equations is not associated.",ERR,ERROR,*999)
      ENDIF      
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_ASSEMBLE")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_ASSEMBLE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_ASSEMBLE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_ASSEMBLE

  !
  !================================================================================================================================
  !
  
  !>Assembles the equations stiffness matrix and rhs for a dynamic linear constraint condition using the finite element method.
  SUBROUTINE CONSTRAINT_CONDITION_ASSEMBLE_DYNAMIC_LINEAR_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to assemble the equations for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: element_idx,ne,NUMBER_OF_TIMES
    REAL(SP) :: ELEMENT_USER_ELAPSED,ELEMENT_SYSTEM_ELAPSED,USER_ELAPSED,USER_TIME1(1),USER_TIME2(1),USER_TIME3(1),USER_TIME4(1), &
      & USER_TIME5(1),USER_TIME6(1),SYSTEM_ELAPSED,SYSTEM_TIME1(1),SYSTEM_TIME2(1),SYSTEM_TIME3(1),SYSTEM_TIME4(1), &
      & SYSTEM_TIME5(1),SYSTEM_TIME6(1)
    TYPE(DOMAIN_MAPPING_TYPE), POINTER :: ELEMENTS_MAPPING
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(CONSTRAINT_MATRICES_TYPE), POINTER :: CONSTRAINT_MATRICES
    TYPE(FIELD_TYPE), POINTER :: LAGRANGE_FIELD
    
    CALL ENTERS("CONSTRAINT_CONDITION_ASSEMBLE_DYNAMIC_LINEAR_FEM",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      LAGRANGE_FIELD=>CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD
      IF(ASSOCIATED(LAGRANGE_FIELD)) THEN
        CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
        IF(ASSOCIATED(EQUATIONS)) THEN
          CONSTRAINT_MATRICES=>CONSTRAINT_EQUATIONS%CONSTRAINT_MATRICES
          IF(ASSOCIATED(CONSTRAINT_MATRICES)) THEN
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME1,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME1,ERR,ERROR,*999)
            ENDIF
            !Initialise the matrices and rhs vector
            CALL CONSTRAINT_MATRICES_VALUES_INITIALISE(CONSTRAINT_MATRICES,CONSTRAINT_MATRICES_LINEAR_ONLY,0.0_DP,ERR,ERROR,*999)
            !Assemble the elements
            !Allocate the element matrices 
            CALL CONSTRAINT_MATRICES_ELEMENT_INITIALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ELEMENTS_MAPPING=>LAGRANGE_FIELD%DECOMPOSITION%DOMAIN(LAGRANGE_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
              & MAPPINGS%ELEMENTS
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME2,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME2,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME2(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME2(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for constraint conditionup and initialisation = ", &
                & USER_ELAPSED,ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for constraint conditionup and initialisation = ", &
                & SYSTEM_ELAPSED,ERR,ERROR,*999)
              ELEMENT_USER_ELAPSED=0.0_SP
              ELEMENT_SYSTEM_ELAPSED=0.0_SP
            ENDIF
            NUMBER_OF_TIMES=0
            !Loop over the internal elements
            DO element_idx=ELEMENTS_MAPPING%INTERNAL_START,ELEMENTS_MAPPING%INTERNAL_FINISH
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDDO !element_idx
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME3,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME3,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME3(1)-USER_TIME2(1)
              SYSTEM_ELAPSED=SYSTEM_TIME3(1)-SYSTEM_TIME2(1)
              ELEMENT_USER_ELAPSED=USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=SYSTEM_ELAPSED
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for internal constraint equations assembly = ", &
                & USER_ELAPSED,ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for internal constraint equations assembly = ", &
                & SYSTEM_ELAPSED,ERR,ERROR,*999)
             ENDIF
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME4,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME4,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME4(1)-USER_TIME3(1)
              SYSTEM_ELAPSED=SYSTEM_TIME4(1)-SYSTEM_TIME3(1)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for parameter transfer completion = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for parameter transfer completion = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
            !Loop over the boundary and ghost elements
            DO element_idx=ELEMENTS_MAPPING%BOUNDARY_START,ELEMENTS_MAPPING%GHOST_FINISH
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDDO !element_idx
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME5,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME5,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME5(1)-USER_TIME4(1)
              SYSTEM_ELAPSED=SYSTEM_TIME5(1)-SYSTEM_TIME4(1)
              ELEMENT_USER_ELAPSED=ELEMENT_USER_ELAPSED+USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=ELEMENT_SYSTEM_ELAPSED+USER_ELAPSED
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for boundary+ghost constraint equations assembly = ", &
                & USER_ELAPSED,ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for boundary+ghost constraint equations assembly = ", &
                & SYSTEM_ELAPSED,ERR,ERROR,*999)
              IF(NUMBER_OF_TIMES>0) THEN
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element user time for constraint equations assembly = ", &
                  & ELEMENT_USER_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element system time for constraint equations assembly = ", &
                  & ELEMENT_SYSTEM_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
              ENDIF
            ENDIF
            !Finalise the element matrices
            CALL CONSTRAINT_MATRICES_ELEMENT_FINALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            !Output equations matrices and RHS vector if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_MATRIX_OUTPUT) THEN
              CALL CONSTRAINT_MATRICES_OUTPUT(GENERAL_OUTPUT_TYPE,CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDIF
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME6,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME6,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME6(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME6(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total user time for constraint equations assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total system time for constraint equations assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Constraint equations matrices is not associated",ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Constraint equations is not associated",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Lagrange field is not associated",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_ASSEMBLE_DYNAMIC_LINEAR_FEM")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_ASSEMBLE_DYNAMIC_LINEAR_FEM",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_ASSEMBLE_DYNAMIC_LINEAR_FEM")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_ASSEMBLE_DYNAMIC_LINEAR_FEM

  !
  !================================================================================================================================
  !
  
  !>Assembles the equations stiffness matrix and rhs for a linear static constraint condition using the finite element method.
  SUBROUTINE CONSTRAINT_CONDITION_ASSEMBLE_STATIC_LINEAR_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to assemble the equations for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: element_idx,ne,NUMBER_OF_TIMES
    REAL(SP) :: ELEMENT_USER_ELAPSED,ELEMENT_SYSTEM_ELAPSED,USER_ELAPSED,USER_TIME1(1),USER_TIME2(1),USER_TIME3(1),USER_TIME4(1), &
      & USER_TIME5(1),USER_TIME6(1),SYSTEM_ELAPSED,SYSTEM_TIME1(1),SYSTEM_TIME2(1),SYSTEM_TIME3(1),SYSTEM_TIME4(1), &
      & SYSTEM_TIME5(1),SYSTEM_TIME6(1)
    TYPE(DOMAIN_MAPPING_TYPE), POINTER :: ELEMENTS_MAPPING
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(CONSTRAINT_MATRICES_TYPE), POINTER :: CONSTRAINT_MATRICES
    TYPE(FIELD_TYPE), POINTER :: LAGRANGE_FIELD
    
!#ifdef TAUPROF
!    CHARACTER(28) :: CVAR
!    INTEGER :: PHASE(2)= (/ 0, 0 /)
!    SAVE PHASE
!#endif

    CALL ENTERS("CONSTRAINT_CONDITION_ASSEMBLE_STATIC_LINEAR_FEM",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      LAGRANGE_FIELD=>CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD
      IF(ASSOCIATED(LAGRANGE_FIELD)) THEN
        CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
        IF(ASSOCIATED(EQUATIONS)) THEN
          CONSTRAINT_MATRICES=>CONSTRAINT_EQUATIONS%CONSTRAINT_MATRICES
          IF(ASSOCIATED(CONSTRAINT_MATRICES)) THEN
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME1,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME1,ERR,ERROR,*999)
            ENDIF
            !Initialise the matrices and rhs vector
#ifdef TAUPROF
            CALL TAU_STATIC_PHASE_START("CONSTRAINT_MATRICES_VALUES_INITIALISE()")
#endif
            CALL CONSTRAINT_MATRICES_VALUES_INITIALISE(CONSTRAINT_MATRICES,CONSTRAINT_MATRICES_LINEAR_ONLY,0.0_DP,ERR,ERROR,*999)
#ifdef TAUPROF
            CALL TAU_STATIC_PHASE_STOP("CONSTRAINT_MATRICES_VALUES_INITIALISE()")
#endif
            !Assemble the elements
            !Allocate the element matrices 
#ifdef TAUPROF
            CALL TAU_STATIC_PHASE_START("CONSTRAINT_MATRICES_ELEMENT_INITIALISE()")
#endif
            CALL CONSTRAINT_MATRICES_ELEMENT_INITIALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ELEMENTS_MAPPING=>LAGRANGE_FIELD%DECOMPOSITION%DOMAIN(LAGRANGE_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
              & MAPPINGS%ELEMENTS
#ifdef TAUPROF
            CALL TAU_STATIC_PHASE_STOP("CONSTRAINT_MATRICES_ELEMENT_INITIALISE()")
#endif
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME2,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME2,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME2(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME2(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for constraint condition setup and initialisation = ", &
                & USER_ELAPSED,ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for constraint condition setup and initialisation = ", &
                & SYSTEM_ELAPSED,ERR,ERROR,*999)
              ELEMENT_USER_ELAPSED=0.0_SP
              ELEMENT_SYSTEM_ELAPSED=0.0_SP
            ENDIF
            NUMBER_OF_TIMES=0
            !Loop over the internal elements

#ifdef TAUPROF
            CALL TAU_STATIC_PHASE_START("Internal Elements Loop")
#endif
            DO element_idx=ELEMENTS_MAPPING%INTERNAL_START,ELEMENTS_MAPPING%INTERNAL_FINISH
!#ifdef TAUPROF
!              WRITE (CVAR,'(a23,i3)') 'Internal Elements Loop ',element_idx
!              CALL TAU_PHASE_CREATE_DYNAMIC(PHASE,CVAR)
!              CALL TAU_PHASE_START(PHASE)
!#endif
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
!#ifdef TAUPROF
!              CALL TAU_PHASE_STOP(PHASE)
!#endif
            ENDDO !element_idx
#ifdef TAUPROF
            CALL TAU_STATIC_PHASE_STOP("Internal Elements Loop")
#endif

            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME3,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME3,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME3(1)-USER_TIME2(1)
              SYSTEM_ELAPSED=SYSTEM_TIME3(1)-SYSTEM_TIME2(1)
              ELEMENT_USER_ELAPSED=USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=SYSTEM_ELAPSED
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for internal constraint equations assembly = ", &
                & USER_ELAPSED,ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for internal constraint equations assembly = ", &
                & SYSTEM_ELAPSED,ERR,ERROR,*999)
             ENDIF
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME4,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME4,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME4(1)-USER_TIME3(1)
              SYSTEM_ELAPSED=SYSTEM_TIME4(1)-SYSTEM_TIME3(1)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for parameter transfer completion = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for parameter transfer completion = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
            !Loop over the boundary and ghost elements
#ifdef TAUPROF
            CALL TAU_STATIC_PHASE_START("Boundary and Ghost Elements Loop")
#endif
            DO element_idx=ELEMENTS_MAPPING%BOUNDARY_START,ELEMENTS_MAPPING%GHOST_FINISH
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDDO !element_idx
#ifdef TAUPROF
            CALL TAU_STATIC_PHASE_STOP("Boundary and Ghost Elements Loop")
#endif
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME5,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME5,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME5(1)-USER_TIME4(1)
              SYSTEM_ELAPSED=SYSTEM_TIME5(1)-SYSTEM_TIME4(1)
              ELEMENT_USER_ELAPSED=ELEMENT_USER_ELAPSED+USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=ELEMENT_SYSTEM_ELAPSED+USER_ELAPSED
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for boundary+ghost constraint equations assembly = ", &
                & USER_ELAPSED,ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for boundary+ghost constraint equations assembly = ", &
                & SYSTEM_ELAPSED,ERR,ERROR,*999)
              IF(NUMBER_OF_TIMES>0) THEN
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element user time for constraint equations assembly = ", &
                  & ELEMENT_USER_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element system time for constraint equations assembly = ", &
                  & ELEMENT_SYSTEM_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
              ENDIF
            ENDIF
            !Finalise the element matrices
#ifdef TAUPROF
            CALL TAU_STATIC_PHASE_START("CONSTRAINT_MATRICES_ELEMENT_FINALISE()")
#endif
            CALL CONSTRAINT_MATRICES_ELEMENT_FINALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
#ifdef TAUPROF
            CALL TAU_STATIC_PHASE_STOP("CONSTRAINT_MATRICES_ELEMENT_FINALISE()")
#endif
            !Output equations matrices and vector if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_MATRIX_OUTPUT) THEN
              CALL CONSTRAINT_MATRICES_OUTPUT(GENERAL_OUTPUT_TYPE,CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDIF
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME6,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME6,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME6(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME6(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total user time for constraint equations assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total system time for constraint equations assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Constraint equations matrices is not associated",ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Constraint equations is not associated",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Lagrange field is not associated",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_ASSEMBLE_STATIC_LINEAR_FEM")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_ASSEMBLE_STATIC_LINEAR_FEM",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_ASSEMBLE_STATIC_LINEAR_FEM")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_ASSEMBLE_STATIC_LINEAR_FEM

  !
  !================================================================================================================================
  !
  
  !>Assembles the equations stiffness matrix, residuals and rhs for a nonlinear static constraint condition using the finite element method.
  SUBROUTINE CONSTRAINT_CONDITION_ASSEMBLE_STATIC_NONLINEAR_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to assemble the equations for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: element_idx,ne,NUMBER_OF_TIMES
    REAL(SP) :: ELEMENT_USER_ELAPSED,ELEMENT_SYSTEM_ELAPSED,USER_ELAPSED,USER_TIME1(1),USER_TIME2(1),USER_TIME3(1),USER_TIME4(1), &
      & USER_TIME5(1),USER_TIME6(1),SYSTEM_ELAPSED,SYSTEM_TIME1(1),SYSTEM_TIME2(1),SYSTEM_TIME3(1),SYSTEM_TIME4(1), &
      & SYSTEM_TIME5(1),SYSTEM_TIME6(1)
    TYPE(DOMAIN_MAPPING_TYPE), POINTER :: ELEMENTS_MAPPING
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(CONSTRAINT_MATRICES_TYPE), POINTER :: CONSTRAINT_MATRICES
    TYPE(FIELD_TYPE), POINTER :: LAGRANGE_FIELD
    
    CALL ENTERS("CONSTRAINT_CONDITION_ASSEMBLE_STATIC_NONLINEAR_FEM",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      LAGRANGE_FIELD=>CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD
      IF(ASSOCIATED(LAGRANGE_FIELD)) THEN
        CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
        IF(ASSOCIATED(EQUATIONS)) THEN
          CONSTRAINT_MATRICES=>CONSTRAINT_EQUATIONS%CONSTRAINT_MATRICES
          IF(ASSOCIATED(CONSTRAINT_MATRICES)) THEN
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME1,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME1,ERR,ERROR,*999)
            ENDIF
             !Initialise the matrices and rhs vector
            CALL CONSTRAINT_MATRICES_VALUES_INITIALISE(CONSTRAINT_MATRICES,CONSTRAINT_MATRICES_NONLINEAR_ONLY,0.0_DP,ERR,ERROR,*999)
            !Assemble the elements
            !Allocate the element matrices 
            CALL CONSTRAINT_MATRICES_ELEMENT_INITIALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ELEMENTS_MAPPING=>LAGRANGE_FIELD%DECOMPOSITION%DOMAIN(LAGRANGE_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
              & MAPPINGS%ELEMENTS
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME2,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME2,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME2(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME2(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for constraint conditionup and initialisation = ", &
                & USER_ELAPSED,ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for constraint conditionup and initialisation = ", &
                & SYSTEM_ELAPSED,ERR,ERROR,*999)
              ELEMENT_USER_ELAPSED=0.0_SP
              ELEMENT_SYSTEM_ELAPSED=0.0_SP
            ENDIF
            NUMBER_OF_TIMES=0
            !Loop over the internal elements
            DO element_idx=ELEMENTS_MAPPING%INTERNAL_START,ELEMENTS_MAPPING%INTERNAL_FINISH
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_RESIDUAL_EVALUATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDDO !element_idx
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME3,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME3,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME3(1)-USER_TIME2(1)
              SYSTEM_ELAPSED=SYSTEM_TIME3(1)-SYSTEM_TIME2(1)
              ELEMENT_USER_ELAPSED=USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=SYSTEM_ELAPSED
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for internal constraint equations assembly = ", &
                & USER_ELAPSED,ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for internal constraint equations assembly = ", &
                & SYSTEM_ELAPSED,ERR,ERROR,*999)
            ENDIF
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME4,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME4,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME4(1)-USER_TIME3(1)
              SYSTEM_ELAPSED=SYSTEM_TIME4(1)-SYSTEM_TIME3(1)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for parameter transfer completion = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for parameter transfer completion = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
            !Loop over the boundary and ghost elements
            DO element_idx=ELEMENTS_MAPPING%BOUNDARY_START,ELEMENTS_MAPPING%GHOST_FINISH
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_RESIDUAL_EVALUATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDDO !element_idx
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME5,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME5,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME5(1)-USER_TIME4(1)
              SYSTEM_ELAPSED=SYSTEM_TIME5(1)-SYSTEM_TIME4(1)
              ELEMENT_USER_ELAPSED=ELEMENT_USER_ELAPSED+USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=ELEMENT_SYSTEM_ELAPSED+USER_ELAPSED
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for boundary+ghost constraint equations assembly = ", &
                & USER_ELAPSED,ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for boundary+ghost constraint equations assembly = ", &
                & SYSTEM_ELAPSED,ERR,ERROR,*999)
              IF(NUMBER_OF_TIMES>0) THEN
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element user time for constraint equations assembly = ", &
                  & ELEMENT_USER_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element system time for constraint equations assembly = ", &
                  & ELEMENT_SYSTEM_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
              ENDIF
            ENDIF
            !Finalise the element matrices
            CALL CONSTRAINT_MATRICES_ELEMENT_FINALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            !Output equations matrices and RHS vector if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_MATRIX_OUTPUT) THEN
              CALL CONSTRAINT_MATRICES_OUTPUT(GENERAL_OUTPUT_TYPE,CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDIF
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME6,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME6,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME6(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME6(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total user time for constraint equations assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total system time for constraint equations assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Constraint equations matrices is not associated",ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Constraint equations is not associated",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Lagrange field is not associated",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_ASSEMBLE_STATIC_NONLINEAR_FEM")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_ASSEMBLE_STATIC_NONLINEAR_FEM",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_ASSEMBLE_STATIC_NONLINEAR_FEM")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_ASSEMBLE_STATIC_NONLINEAR_FEM
  
  !
  !==================================================================================================================================
  !

  !>Finishes the process of creating an constraint condition. \see OPENCMISS::CMISSConstraintConditionCreateStart
  SUBROUTINE CONSTRAINT_CONDITION_CREATE_FINISH(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to finish creating
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(CONSTRAINT_DEPENDENT_TYPE), POINTER :: CONSTRAINT_DEPENDENT
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("CONSTRAINT_CONDITION_CREATE_FINISH",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(CONSTRAINT_CONDITION%CONSTRAINT_CONDITION_FINISHED) THEN
        CALL FLAG_ERROR("Constraint condition has already been finished.",ERR,ERROR,*999)
      ELSE
        !Test various inputs have been set up.
        SELECT CASE(CONSTRAINT_CONDITION%METHOD)
        CASE(CONSTRAINT_CONDITION_LAGRANGE_MULTIPLIERS_METHOD,CONSTRAINT_CONDITION_PENALTY_METHOD)
          CONSTRAINT_DEPENDENT=>CONSTRAINT_CONDITION%DEPENDENT
          IF(ASSOCIATED(CONSTRAINT_DEPENDENT)) THEN
            !Do nothing?
          ELSE
            CALL FLAG_ERROR("Constraint condition dependent is not associated.",ERR,ERROR,*999)
          ENDIF
        CASE(CONSTRAINT_CONDITION_AUGMENTED_LAGRANGE_METHOD)
          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
        CASE(CONSTRAINT_CONDITION_POINT_TO_POINT_METHOD)
          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
        CASE DEFAULT
          LOCAL_ERROR="The constraint condition method of "//TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%METHOD,"*",ERR,ERROR))// &
            & " is invalid."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
        !Finish the constraint condition creation
        CONSTRAINT_CONDITION%CONSTRAINT_CONDITION_FINISHED=.TRUE.
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_CREATE_FINISH")
    RETURN 
999 CALL ERRORS("CONSTRAINT_CONDITION_CREATE_FINISH",ERR,ERROR)    
    CALL EXITS("CONSTRAINT_CONDITION_CREATE_FINISH")
    RETURN 1
   
  END SUBROUTINE CONSTRAINT_CONDITION_CREATE_FINISH
        
  !
  !================================================================================================================================
  !

  !>Starts the process of creating an constraint condition on an constraint. \see OPENCMISS::CMISSConstraintConditionCreateStart
  SUBROUTINE CONSTRAINT_CONDITION_CREATE_START(USER_NUMBER,REGION,GEOMETRIC_FIELD,CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The user number of the constraint condition
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region to create the constraint condition on
    TYPE(FIELD_TYPE), POINTER :: GEOMETRIC_FIELD !<A pointer to the geometric field for the constraint condition.
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<On return, a pointer to the constraint condition. Must not be associated on entry.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: DUMMY_ERR,constraint_conditions_idx
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: NEW_CONSTRAINT_CONDITION
    TYPE(CONSTRAINT_CONDITION_PTR_TYPE), POINTER :: NEW_CONSTRAINT_CONDITIONS(:)
    TYPE(REGION_TYPE), POINTER :: GEOMETRIC_FIELD_REGION
    TYPE(VARYING_STRING) :: DUMMY_ERROR,LOCAL_ERROR
 
    NULLIFY(NEW_CONSTRAINT_CONDITION)
    NULLIFY(NEW_CONSTRAINT_CONDITIONS)
    NULLIFY(GEOMETRIC_FIELD_REGION)

    CALL ENTERS("CONSTRAINT_CONDITION_CREATE_START",ERR,ERROR,*997)

    IF(ASSOCIATED(REGION)) THEN
      IF(ASSOCIATED(REGION%CONSTRAINT_CONDITIONS)) THEN
        CALL CONSTRAINT_CONDITION_USER_NUMBER_FIND(USER_NUMBER,REGION,NEW_CONSTRAINT_CONDITION,ERR,ERROR,*997)
        IF(ASSOCIATED(NEW_CONSTRAINT_CONDITION)) THEN
          LOCAL_ERROR="Constraint condition user number "//TRIM(NUMBER_TO_VSTRING(USER_NUMBER,"*",ERR,ERROR))// &
            & " has already been created on region number "//TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))//"."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*997)
        ELSE
          IF(ASSOCIATED(GEOMETRIC_FIELD)) THEN
            IF(GEOMETRIC_FIELD%FIELD_FINISHED) THEN
              IF(GEOMETRIC_FIELD%TYPE==FIELD_GEOMETRIC_TYPE) THEN
                GEOMETRIC_FIELD_REGION=>GEOMETRIC_FIELD%REGION
                IF(ASSOCIATED(GEOMETRIC_FIELD_REGION)) THEN
                  IF(GEOMETRIC_FIELD_REGION%USER_NUMBER==REGION%USER_NUMBER) THEN
                    NULLIFY(NEW_CONSTRAINT_CONDITION)
                    !Initalise constraint condition
                    CALL CONSTRAINT_CONDITION_INITIALISE(NEW_CONSTRAINT_CONDITION,ERR,ERROR,*999)
                    !Set default constraint condition values
                    NEW_CONSTRAINT_CONDITION%USER_NUMBER=USER_NUMBER
                    NEW_CONSTRAINT_CONDITION%GLOBAL_NUMBER=REGION%CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS+1
                    NEW_CONSTRAINT_CONDITION%CONSTRAINT_CONDITIONS=>REGION%CONSTRAINT_CONDITIONS
                    NEW_CONSTRAINT_CONDITION%REGION=>REGION
                    !Default attributes
                    NEW_CONSTRAINT_CONDITION%GEOMETRY%GEOMETRIC_FIELD=>GEOMETRIC_FIELD
                    NEW_CONSTRAINT_CONDITION%METHOD=CONSTRAINT_CONDITION_LAGRANGE_MULTIPLIERS_METHOD
                    NEW_CONSTRAINT_CONDITION%OPERATOR=CONSTRAINT_CONDITION_FE_INCOMPRESSIBILITY_OPERATOR
                    CALL CONSTRAINT_CONDITION_DEPENDENT_INITIALISE(NEW_CONSTRAINT_CONDITION,ERR,ERROR,*999)
                    !Add new constraint condition into list of constraint conditions in the constraint
                    ALLOCATE(NEW_CONSTRAINT_CONDITIONS(REGION%CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS+1),STAT=ERR)
                    IF(ERR/=0) CALL FLAG_ERROR("Could not allocate new constraint conditions.",ERR,ERROR,*999)
                    DO constraint_conditions_idx=1,REGION%CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS
                      NEW_CONSTRAINT_CONDITIONS(constraint_conditions_idx)%PTR=>REGION%CONSTRAINT_CONDITIONS% &
                        & CONSTRAINT_CONDITIONS(constraint_conditions_idx)%PTR
                    ENDDO !constraint_conditions_idx
                    NEW_CONSTRAINT_CONDITIONS(REGION%CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS+1)%PTR=> &
                      & NEW_CONSTRAINT_CONDITION
                    IF(ASSOCIATED(REGION%CONSTRAINT_CONDITIONS%CONSTRAINT_CONDITIONS)) DEALLOCATE(REGION%CONSTRAINT_CONDITIONS% &
                      & CONSTRAINT_CONDITIONS)
                    REGION%CONSTRAINT_CONDITIONS%CONSTRAINT_CONDITIONS=>NEW_CONSTRAINT_CONDITIONS
                    REGION%CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS=REGION%CONSTRAINT_CONDITIONS% &
                      NUMBER_OF_CONSTRAINT_CONDITIONS+1
                    !Return the pointer
                    CONSTRAINT_CONDITION=>NEW_CONSTRAINT_CONDITION
                  ELSE
                    LOCAL_ERROR="The geometric field region and the specified region do not match. "// &
                      & "The geometric field was created on region number "// &
                      & TRIM(NUMBER_TO_VSTRING(GEOMETRIC_FIELD_REGION%USER_NUMBER,"*",ERR,ERROR))// &
                      & " and the specified region number is "// &
                      & TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))//"."
                    CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*997)
                  ENDIF
                ELSE
                  CALL FLAG_ERROR("The specified geometric field region is not associated.",ERR,ERROR,*997)
                ENDIF
              ELSE
                CALL FLAG_ERROR("The specified geometric field is not a geometric field.",ERR,ERROR,*997)
              ENDIF
            ELSE
              CALL FLAG_ERROR("The specified geometric field is not finished.",ERR,ERROR,*997)
            ENDIF
          ELSE
            CALL FLAG_ERROR("The specified geometric field is not associated.",ERR,ERROR,*997)
          ENDIF
        ENDIF
      ELSE
        LOCAL_ERROR="The constraint conditions on region number "//TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))// &
          & " are not associated."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*997)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Region is not associated.",ERR,ERROR,*997)
    ENDIF
    
    CALL EXITS("CONSTRAINT_CONDITION_CREATE_START")
    RETURN
999 IF(ASSOCIATED(NEW_CONSTRAINT_CONDITION))CALL CONSTRAINT_CONDITION_FINALISE(NEW_CONSTRAINT_CONDITION,DUMMY_ERR,DUMMY_ERROR,*998)
998 IF(ASSOCIATED(NEW_CONSTRAINT_CONDITIONS)) DEALLOCATE(NEW_CONSTRAINT_CONDITIONS)
997 CALL ERRORS("CONSTRAINT_CONDITION_CREATE_START",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_CREATE_START")
    RETURN 1   
  END SUBROUTINE CONSTRAINT_CONDITION_CREATE_START
  
  !
  !================================================================================================================================
  !

  !>Finalise the constraint condition dependent field information and deallocate all memory.
  SUBROUTINE CONSTRAINT_CONDITION_DEPENDENT_FINALISE(CONSTRAINT_DEPENDENT,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_DEPENDENT_TYPE), POINTER :: CONSTRAINT_DEPENDENT !<A pointer to the constraint condition dependent field information to finalise.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("CONSTRAINT_CONDITION_DEPENDENT_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_DEPENDENT)) THEN
      IF(ASSOCIATED(CONSTRAINT_DEPENDENT%CONSTRAINT_CONDITION)) DEALLOCATE(CONSTRAINT_DEPENDENT%CONSTRAINT_CONDITION)
      DEALLOCATE(CONSTRAINT_DEPENDENT)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_DEPENDENT_FINALISE")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_DEPENDENT_FINALISE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_DEPENDENT_FINALISE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_DEPENDENT_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises an constraint condition dependent field information.
  SUBROUTINE CONSTRAINT_CONDITION_DEPENDENT_INITIALISE(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<The pointer to the constraint condition to initialise to initialise the dependent field information for.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: DUMMY_ERR
    TYPE(VARYING_STRING) :: DUMMY_ERROR
 
    CALL ENTERS("CONSTRAINT_CONDITION_DEPENDENT_INITIALISE",ERR,ERROR,*998)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(ASSOCIATED(CONSTRAINT_CONDITION%DEPENDENT)) THEN
        CALL FLAG_ERROR("Constraint condition dependent is already associated.",ERR,ERROR,*999)
      ELSE
        ALLOCATE(CONSTRAINT_CONDITION%DEPENDENT,STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate constraint condition dependent.",ERR,ERROR,*999)
        CONSTRAINT_CONDITION%DEPENDENT%CONSTRAINT_CONDITION=>CONSTRAINT_CONDITION
        NULLIFY(CONSTRAINT_CONDITION%DEPENDENT%CONSTRAINT_CONDITION)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_DEPENDENT_INITIALISE")
    RETURN
999 CALL CONSTRAINT_CONDITION_DEPENDENT_FINALISE(CONSTRAINT_CONDITION%DEPENDENT,DUMMY_ERR,DUMMY_ERROR,*998)
998 CALL ERRORS("CONSTRAINT_CONDITION_DEPENDENT_INITIALISE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_DEPENDENT_INITIALISE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_DEPENDENT_INITIALISE
  
  !
  !================================================================================================================================
  !

  !>Destroys an constraint condition. \see OPENCMISS::CMISSConstraintConditionDestroy
  SUBROUTINE CONSTRAINT_CONDITION_DESTROY(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to destroy
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: constraint_condition_idx,constraint_condition_position
    TYPE(CONSTRAINT_CONDITION_PTR_TYPE), POINTER :: NEW_CONSTRAINT_CONDITIONS(:)
    TYPE(CONSTRAINT_CONDITIONS_TYPE), POINTER :: CONSTRAINT_CONDITIONS

    NULLIFY(NEW_CONSTRAINT_CONDITIONS)

    CALL ENTERS("CONSTRAINT_CONDITION_DESTROY",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      CONSTRAINT_CONDITIONS=>CONSTRAINT_CONDITION%CONSTRAINT_CONDITIONS
      IF(ASSOCIATED(CONSTRAINT_CONDITIONS)) THEN
        constraint_condition_position=CONSTRAINT_CONDITION%GLOBAL_NUMBER

        !Destroy all the constraint condition components
        CALL CONSTRAINT_CONDITION_FINALISE(CONSTRAINT_CONDITION,ERR,ERROR,*999)
        
        !Remove the constraint condition from the list of constraint conditions
        IF(CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS>1) THEN
          ALLOCATE(NEW_CONSTRAINT_CONDITIONS(CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS-1),STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate new constraint conditions.",ERR,ERROR,*999)
          DO constraint_condition_idx=1,CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS
            IF(constraint_condition_idx<constraint_condition_position) THEN
              NEW_CONSTRAINT_CONDITIONS(constraint_condition_idx)%PTR=>CONSTRAINT_CONDITIONS% &
                & CONSTRAINT_CONDITIONS(constraint_condition_idx)%PTR
            ELSE IF(constraint_condition_idx>constraint_condition_position) THEN
              CONSTRAINT_CONDITIONS%CONSTRAINT_CONDITIONS(constraint_condition_idx)%PTR%GLOBAL_NUMBER=CONSTRAINT_CONDITIONS% &
                & CONSTRAINT_CONDITIONS(constraint_condition_idx)%PTR%GLOBAL_NUMBER-1
              NEW_CONSTRAINT_CONDITIONS(constraint_condition_idx-1)%PTR=>CONSTRAINT_CONDITIONS% &
                & CONSTRAINT_CONDITIONS(constraint_condition_idx)%PTR
            ENDIF
          ENDDO !constraint_conditions_idx
          IF(ASSOCIATED(CONSTRAINT_CONDITIONS%CONSTRAINT_CONDITIONS)) DEALLOCATE(CONSTRAINT_CONDITIONS%CONSTRAINT_CONDITIONS)
          CONSTRAINT_CONDITIONS%CONSTRAINT_CONDITIONS=>NEW_CONSTRAINT_CONDITIONS
          CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS=CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS-1
        ELSE
          DEALLOCATE(CONSTRAINT_CONDITIONS%CONSTRAINT_CONDITIONS)
          CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS=0
        ENDIF
        
      ELSE
        CALL FLAG_ERROR("Constraint conditions constraint conditions is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint conditions is not associated.",ERR,ERROR,*998)
    ENDIF    

    CALL EXITS("CONSTRAINT_CONDITIONS_DESTROY")
    RETURN
999 IF(ASSOCIATED(NEW_CONSTRAINT_CONDITIONS)) DEALLOCATE(NEW_CONSTRAINT_CONDITIONS)
998 CALL ERRORS("CONSTRAINT_CONDITION_DESTROY",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_DESTROY")
    RETURN 1   
  END SUBROUTINE CONSTRAINT_CONDITION_DESTROY
  
  !
  !================================================================================================================================
  !

  !>Finish the creation of constraint equations for the constraint condition. \see OPENCMISS::CMISSConstraintConditionEquationsCreateFinish
  SUBROUTINE CONSTRAINT_CONDITION_EQUATIONS_CREATE_FINISH(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to finish the creation of the constraint equations for.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG), ALLOCATABLE :: STORAGE_TYPE(:),STRUCTURE_TYPE(:)
    LOGICAL, ALLOCATABLE :: MATRICES_TRANSPOSE(:)
    INTEGER(INTG) :: number_of_dependent_variables
    TYPE(CONSTRAINT_DEPENDENT_TYPE), POINTER :: CONSTRAINT_DEPENDENT
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(CONSTRAINT_MAPPING_TYPE), POINTER :: CONSTRAINT_MAPPING
    TYPE(CONSTRAINT_MATRICES_TYPE), POINTER :: CONSTRAINT_MATRICES
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("CONSTRAINT_CONDITIONS_EQUATIONS_CREATE_FINISH",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      SELECT CASE(CONSTRAINT_CONDITION%METHOD)
      CASE(CONSTRAINT_CONDITION_LAGRANGE_MULTIPLIERS_METHOD,CONSTRAINT_CONDITION_PENALTY_METHOD)
        !Finish the constraint equations creation
        NULLIFY(CONSTRAINT_EQUATIONS)
        CALL CONSTRAINT_CONDITION_EQUATIONS_GET(CONSTRAINT_CONDITION,CONSTRAINT_EQUATIONS,ERR,ERROR,*999)
        IF(CONSTRAINT_EQUATIONS%CONSTRAINT_EQUATIONS_FINISHED) THEN
          CALL FLAG_ERROR("Constraint condition equations have already been finished.",ERR,ERROR,*999)
        ELSE
          CALL CONSTRAINT_EQUATIONS_CREATE_FINISH(CONSTRAINT_EQUATIONS,ERR,ERROR,*999)
          CONSTRAINT_DEPENDENT=>CONSTRAINT_CONDITION%DEPENDENT
          IF(ASSOCIATED(CONSTRAINT_DEPENDENT)) THEN
            !Create the constraint mapping.
            NULLIFY(CONSTRAINT_MAPPING)
            CALL CONSTRAINT_MAPPING_CREATE_START(CONSTRAINT_EQUATIONS,CONSTRAINT_MAPPING,ERR,ERROR,*999)
            CALL CONSTRAINT_MAPPING_LAGRANGE_VARIABLE_TYPE_SET(CONSTRAINT_MAPPING,FIELD_U_VARIABLE_TYPE,ERR,ERROR,*999)
            SELECT CASE(CONSTRAINT_CONDITION%METHOD)
            CASE(CONSTRAINT_CONDITION_LAGRANGE_MULTIPLIERS_METHOD)
              number_of_dependent_variables=1
            CASE(CONSTRAINT_CONDITION_PENALTY_METHOD)
              number_of_dependent_variables=2
            ENDSELECT
            CALL CONSTRAINT_MAPPING_MATRICES_NUMBER_SET(CONSTRAINT_MAPPING,number_of_dependent_variables,ERR,ERROR,*999)
            ALLOCATE(MATRICES_TRANSPOSE(number_of_dependent_variables),STAT=ERR)
            IF(ERR/=0) CALL FLAG_ERROR("Could not allocate matrices transpose.",ERR,ERROR,*999)
            MATRICES_TRANSPOSE=.TRUE.
            SELECT CASE(CONSTRAINT_CONDITION%METHOD)
            CASE(CONSTRAINT_CONDITION_PENALTY_METHOD)
              !Set the last constraint matrix to have no transpose
              MATRICES_TRANSPOSE(number_of_dependent_variables)=.FALSE.
            ENDSELECT
            CALL CONSTRAINT_MAPPING_MATRICES_TRANSPOSE_SET(CONSTRAINT_MAPPING,MATRICES_TRANSPOSE,ERR,ERROR,*999)
            IF(ALLOCATED(MATRICES_TRANSPOSE)) DEALLOCATE(MATRICES_TRANSPOSE)
            CALL CONSTRAINT_MAPPING_RHS_VARIABLE_TYPE_SET(CONSTRAINT_MAPPING,FIELD_DELUDELN_VARIABLE_TYPE,ERR,ERROR,*999)
            CALL CONSTRAINT_MAPPING_CREATE_FINISH(CONSTRAINT_MAPPING,ERR,ERROR,*999)
            !Create the constraint matrices
            NULLIFY(CONSTRAINT_MATRICES)
            CALL CONSTRAINT_MATRICES_CREATE_START(CONSTRAINT_EQUATIONS,CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ALLOCATE(STORAGE_TYPE(CONSTRAINT_MATRICES%NUMBER_OF_CONSTRAINT_MATRICES),STAT=ERR)
            IF(ERR/=0) CALL FLAG_ERROR("Could not allocate storage type.",ERR,ERROR,*999)
            SELECT CASE(CONSTRAINT_EQUATIONS%SPARSITY_TYPE)
            CASE(CONSTRAINT_MATRICES_FULL_MATRICES) 
              STORAGE_TYPE=MATRIX_BLOCK_STORAGE_TYPE
              CALL CONSTRAINT_MATRICES_STORAGE_TYPE_SET(CONSTRAINT_MATRICES,STORAGE_TYPE,ERR,ERROR,*999)
            CASE(CONSTRAINT_MATRICES_SPARSE_MATRICES) 
              ALLOCATE(STRUCTURE_TYPE(CONSTRAINT_MATRICES%NUMBER_OF_CONSTRAINT_MATRICES),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate structure type.",ERR,ERROR,*999)
              STORAGE_TYPE=MATRIX_COMPRESSED_ROW_STORAGE_TYPE
              STRUCTURE_TYPE=CONSTRAINT_MATRIX_FEM_STRUCTURE
              CALL CONSTRAINT_MATRICES_STORAGE_TYPE_SET(CONSTRAINT_MATRICES,STORAGE_TYPE,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_STRUCTURE_TYPE_SET(CONSTRAINT_MATRICES,STRUCTURE_TYPE,ERR,ERROR,*999)
              IF(ALLOCATED(STRUCTURE_TYPE)) DEALLOCATE(STRUCTURE_TYPE)
            CASE DEFAULT
              LOCAL_ERROR="The constraint equations sparsity type of "// &
                & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_EQUATIONS%SPARSITY_TYPE,"*",ERR,ERROR))//" is invalid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            END SELECT
            IF(ALLOCATED(STORAGE_TYPE)) DEALLOCATE(STORAGE_TYPE)
            CALL CONSTRAINT_MATRICES_CREATE_FINISH(CONSTRAINT_MATRICES,ERR,ERROR,*999)
          ELSE
            CALL FLAG_ERROR("Constraint condition dependent is not associated.",ERR,ERROR,*999)
          ENDIF
        ENDIF
      CASE(CONSTRAINT_CONDITION_AUGMENTED_LAGRANGE_METHOD)
        CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
      CASE(CONSTRAINT_CONDITION_POINT_TO_POINT_METHOD)
        CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="The constraint condition method of "//TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%METHOD,"*",ERR,ERROR))// &
          & " is invalid."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Constraint conditions is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_EQUATIONS_CREATE_FINISH")
    RETURN
999 IF(ALLOCATED(MATRICES_TRANSPOSE)) DEALLOCATE(MATRICES_TRANSPOSE)
    IF(ALLOCATED(STORAGE_TYPE)) DEALLOCATE(STORAGE_TYPE)
    IF(ALLOCATED(STRUCTURE_TYPE)) DEALLOCATE(STRUCTURE_TYPE)
    CALL ERRORS("CONSTRAINT_CONDITION_EQUATIONS_CREATE_FINISH",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_EQUATIONS_CREATE_FINISH")
    RETURN 1
    
  END SUBROUTINE CONSTRAINT_CONDITION_EQUATIONS_CREATE_FINISH

  !
  !================================================================================================================================
  !

  !>Start the creation of constraint equations for the constraint condition. \see CMISSConstraintConditionEquationsCreateStart
  !>Default values set for the CONSTRAINT_EQUATIONS's attributes are:
  !>- OUTPUT_TYPE: 0 (CONSTRAINT_EQUATIONS_NO_OUTPUT)
  !>- SPARSITY_TYPE: 1 (CONSTRAINT_EQUATIONS_SPARSE_MATRICES)
  SUBROUTINE CONSTRAINT_CONDITION_EQUATIONS_CREATE_START(CONSTRAINT_CONDITION,CONSTRAINT_EQUATIONS,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to create the constraint equations for
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS !<On exit, a pointer to the created constraint equations. Must not be associated on entry.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: variable_idx
    TYPE(CONSTRAINT_DEPENDENT_TYPE), POINTER :: CONSTRAINT_DEPENDENT
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("CONSTRAINT_CONDITION_EQUATIONS_CREATE_START",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(ASSOCIATED(CONSTRAINT_EQUATIONS)) THEN
        CALL FLAG_ERROR("Constraint equations is already associated.",ERR,ERROR,*999)
      ELSE
        NULLIFY(CONSTRAINT_EQUATIONS)
        SELECT CASE(CONSTRAINT_CONDITION%METHOD)
        CASE(CONSTRAINT_CONDITION_LAGRANGE_MULTIPLIERS_METHOD,CONSTRAINT_CONDITION_PENALTY_METHOD)
          IF(ASSOCIATED(CONSTRAINT_CONDITION%LAGRANGE)) THEN
            IF(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FINISHED) THEN
              CONSTRAINT_DEPENDENT=>CONSTRAINT_CONDITION%DEPENDENT
              IF(ASSOCIATED(CONSTRAINT_DEPENDENT)) THEN
                !Initialise the setup
                CALL CONSTRAINT_EQUATIONS_CREATE_START(CONSTRAINT_CONDITION,CONSTRAINT_EQUATIONS,ERR,ERROR,*999)
                !Set the number of interpolation sets
                CALL CONSTRAINT_EQUATIONS_CONSTRAINT_INTERP_SETS_NUMBER_SET(CONSTRAINT_EQUATIONS,1,1,1,ERR,ERROR,*999)
                DO variable_idx=1,CONSTRAINT_DEPENDENT%NUMBER_OF_DEPENDENT_VARIABLES
                  CALL CONSTRAINT_EQUATIONS_VARIABLE_INTERP_SETS_NUMBER_SET(CONSTRAINT_EQUATIONS,variable_idx,1,1,0, &
                    & ERR,ERROR,*999)
                ENDDO !variable_idx
              ELSE
                CALL FLAG_ERROR("Constraint condition dependent is not associated.",ERR,ERROR,*999)
              ENDIF
              !Return the pointer
              CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
            ELSE
              CALL FLAG_ERROR("Constraint condition Lagrange field has not been finished.",ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Constraint condition Lagrange is not associated.",ERR,ERROR,*999)
          ENDIF
        CASE(CONSTRAINT_CONDITION_AUGMENTED_LAGRANGE_METHOD)
          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
        CASE(CONSTRAINT_CONDITION_POINT_TO_POINT_METHOD)
          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
        CASE DEFAULT
          LOCAL_ERROR="The constraint condition method of "//TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%METHOD,"*",ERR,ERROR))// &
            & " is invalid."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_EQUATIONS_CREATE_START")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_EQUATIONS_CREATE_START",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_EQUATIONS_CREATE_START")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_EQUATIONS_CREATE_START

  !
  !================================================================================================================================
  !

  !>Destroy the constraint equations for an constraint condition. \see OPENCMISS::CMISSConstraintConditionEquationsDestroy
  SUBROUTINE CONSTRAINT_CONDITION_EQUATIONS_DESTROY(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint conditions to destroy the constraint equations for.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("CONSTRAINT_CONDITION_EQUATIONS_DESTROY",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(ASSOCIATED(CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS)) THEN
        CALL CONSTRAINT_EQUATIONS_DESTROY(CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS,ERR,ERROR,*999)
      ELSE
        CALL FLAG_ERROR("Constraint condition constraint equations is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_EQUATIONS_DESTROY")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_EQUATIONS_DESTROY",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_EQUATIONS_DESTROY")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_EQUATIONS_DESTROY

  !
  !================================================================================================================================
  !

  !>Finalise the constraint condition and deallocate all memory.
  SUBROUTINE CONSTRAINT_CONDITION_FINALISE(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to finalise.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("CONSTRAINT_CONDITION_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      CALL CONSTRAINT_CONDITION_GEOMETRY_FINALISE(CONSTRAINT_CONDITION%GEOMETRY,ERR,ERROR,*999)
      CALL CONSTRAINT_CONDITION_LAGRANGE_FINALISE(CONSTRAINT_CONDITION%LAGRANGE,ERR,ERROR,*999)
      CALL CONSTRAINT_CONDITION_PENALTY_FINALISE(CONSTRAINT_CONDITION%PENALTY,ERR,ERROR,*999)
      CALL CONSTRAINT_CONDITION_DEPENDENT_FINALISE(CONSTRAINT_CONDITION%DEPENDENT,ERR,ERROR,*999)
      IF(ASSOCIATED(CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS)) &
        & CALL CONSTRAINT_EQUATIONS_DESTROY(CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS,ERR,ERROR,*999)
      DEALLOCATE(CONSTRAINT_CONDITION)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_FINALISE")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_FINALISE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_FINALISE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_FINALISE

  !
  !================================================================================================================================
  !

  !>Evaluates the Jacobian for a nonlinear constraint condition.
  SUBROUTINE CONSTRAINT_CONDITION_JACOBIAN_EVALUATE(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to evaluate the Jacobian for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(VARYING_STRING) :: LOCAL_ERROR
 
    CALL ENTERS("CONSTRAINT_CONDITION_JACOBIAN_EVALUATE",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
      IF(ASSOCIATED(CONSTRAINT_EQUATIONS)) THEN
        IF(CONSTRAINT_EQUATIONS%CONSTRAINT_EQUATIONS_FINISHED) THEN
          SELECT CASE(CONSTRAINT_EQUATIONS%LINEARITY)
          CASE(CONSTRAINT_CONDITION_LINEAR)
            SELECT CASE(CONSTRAINT_EQUATIONS%TIME_DEPENDENCE)
            CASE(CONSTRAINT_CONDITION_STATIC)
              SELECT CASE(CONSTRAINT_CONDITION%SOLUTION_METHOD)
              CASE(CONSTRAINT_CONDITION_FEM_SOLUTION_METHOD)
                CALL CONSTRAINT_CONDITION_ASSEMBLE_STATIC_LINEAR_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_BEM_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_FD_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_FV_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_GFEM_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_GFV_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="The constraint condition solution method of "// &
                  & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%SOLUTION_METHOD,"*",ERR,ERROR))// &
                  & " is invalid."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(CONSTRAINT_CONDITION_FIRST_ORDER_DYNAMIC,CONSTRAINT_CONDITION_SECOND_ORDER_DYNAMIC)
              SELECT CASE(CONSTRAINT_CONDITION%SOLUTION_METHOD)
              CASE(CONSTRAINT_CONDITION_FEM_SOLUTION_METHOD)
                CALL CONSTRAINT_CONDITION_ASSEMBLE_DYNAMIC_LINEAR_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_BEM_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_FD_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_FV_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_GFEM_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_GFV_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="The constraint condition solution method of "// &
                  & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%SOLUTION_METHOD,"*",ERR,ERROR))// &
                  & " is invalid."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE DEFAULT
              LOCAL_ERROR="The constraint time dependence type of "// &
                & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_EQUATIONS%TIME_DEPENDENCE,"*",ERR,ERROR))//" is invalid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            END SELECT
          CASE(CONSTRAINT_CONDITION_NONLINEAR)
            SELECT CASE(CONSTRAINT_EQUATIONS%TIME_DEPENDENCE)
            CASE(CONSTRAINT_CONDITION_STATIC)
              SELECT CASE(CONSTRAINT_CONDITION%SOLUTION_METHOD)
              CASE(CONSTRAINT_CONDITION_FEM_SOLUTION_METHOD)
                CALL CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_STATIC_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_BEM_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_FD_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_FV_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_GFEM_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_GFV_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="The constraint condition solution method  of "// &
                  & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%SOLUTION_METHOD,"*",ERR,ERROR))// &
                  & " is invalid."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(CONSTRAINT_CONDITION_FIRST_ORDER_DYNAMIC,CONSTRAINT_CONDITION_SECOND_ORDER_DYNAMIC)
              SELECT CASE(CONSTRAINT_CONDITION%SOLUTION_METHOD)
              CASE(CONSTRAINT_CONDITION_FEM_SOLUTION_METHOD)
                CALL CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_DYNAMIC_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_BEM_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_FD_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_FV_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_GFEM_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_GFV_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="The constraint condition solution method  of "// &
                  & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%SOLUTION_METHOD,"*",ERR,ERROR))// &
                  & " is invalid."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(CONSTRAINT_CONDITION_TIME_STEPPING)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE DEFAULT
              LOCAL_ERROR="The constraint condition time dependence type of "// &
                & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_EQUATIONS%TIME_DEPENDENCE,"*",ERR,ERROR))//" is invalid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            END SELECT
          CASE(CONSTRAINT_CONDITION_NONLINEAR_BCS)
            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
          CASE DEFAULT
            LOCAL_ERROR="The constraint linearity of "// &
              & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_EQUATIONS%LINEARITY,"*",ERR,ERROR))//" is invalid."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Constraint have not been finished.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Constraint condition constraint is not associated.",ERR,ERROR,*999)
      ENDIF      
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_JACOBIAN_EVALUATE")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_JACOBIAN_EVALUATE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_JACOBIAN_EVALUATE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_JACOBIAN_EVALUATE

  !
  !================================================================================================================================
  !

  !>Evaluates the Jacobian for an static constraint condition using the finite element method
  SUBROUTINE CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_STATIC_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to evaluate the Jacobian for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: element_idx,ne,NUMBER_OF_TIMES
    REAL(SP) :: ELEMENT_USER_ELAPSED,ELEMENT_SYSTEM_ELAPSED,USER_ELAPSED,USER_TIME1(1),USER_TIME2(1),USER_TIME3(1),USER_TIME4(1), &
      & USER_TIME5(1),USER_TIME6(1),SYSTEM_ELAPSED,SYSTEM_TIME1(1),SYSTEM_TIME2(1),SYSTEM_TIME3(1),SYSTEM_TIME4(1), &
      & SYSTEM_TIME5(1),SYSTEM_TIME6(1)
    TYPE(DOMAIN_MAPPING_TYPE), POINTER :: ELEMENTS_MAPPING
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(CONSTRAINT_MATRICES_TYPE), POINTER :: CONSTRAINT_MATRICES
    TYPE(FIELD_TYPE), POINTER :: LAGRANGE_FIELD
  
    CALL ENTERS("CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_STATIC_FEM",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      LAGRANGE_FIELD=>CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD
      IF(ASSOCIATED(LAGRANGE_FIELD)) THEN
        CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT
        IF(ASSOCIATED(CONSTRAINT)) THEN
          CONSTRAINT_MATRICES=>CONSTRAINT_EQUATIONS%CONSTRAINT_MATRICES
          IF(ASSOCIATED(CONSTRAINT_MATRICES)) THEN
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME1,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME1,ERR,ERROR,*999)
            ENDIF
!!Do we need to transfer parameter sets???
            !Initialise the matrices and rhs vector
            CALL CONSTRAINT_MATRICES_VALUES_INITIALISE(CONSTRAINT_MATRICES,CONSTRAINT_MATRICES_JACOBIAN_ONLY,0.0_DP,ERR,ERROR,*999)
            !Assemble the elements
            !Allocate the element matrices 
            CALL CONSTRAINT_MATRICES_ELEMENT_INITIALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ELEMENTS_MAPPING=>LAGRANGE_FIELD%DECOMPOSITION%DOMAIN(LAGRANGE_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
              & MAPPINGS%ELEMENTS
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME2,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME2,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME2(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME2(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for constraint conditionup and initialisation = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for constraint conditionup and initialisation = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
              ELEMENT_USER_ELAPSED=0.0_SP
              ELEMENT_SYSTEM_ELAPSED=0.0_SP
            ENDIF
            NUMBER_OF_TIMES=0
            !Loop over the internal elements
            DO element_idx=ELEMENTS_MAPPING%INTERNAL_START,ELEMENTS_MAPPING%INTERNAL_FINISH
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_JACOBIAN_EVALUATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_JACOBIAN_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDDO !element_idx                  
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME3,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME3,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME3(1)-USER_TIME2(1)
              SYSTEM_ELAPSED=SYSTEM_TIME3(1)-SYSTEM_TIME2(1)
              ELEMENT_USER_ELAPSED=USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=SYSTEM_ELAPSED
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for internal constraint assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for internal constraint assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME4,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME4,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME4(1)-USER_TIME3(1)
              SYSTEM_ELAPSED=SYSTEM_TIME4(1)-SYSTEM_TIME3(1)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for parameter transfer completion = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for parameter transfer completion = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
            !Loop over the boundary and ghost elements
            DO element_idx=ELEMENTS_MAPPING%BOUNDARY_START,ELEMENTS_MAPPING%GHOST_FINISH
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_JACOBIAN_EVALUATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_JACOBIAN_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDDO !element_idx
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME5,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME5,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME5(1)-USER_TIME4(1)
              SYSTEM_ELAPSED=SYSTEM_TIME5(1)-SYSTEM_TIME4(1)
              ELEMENT_USER_ELAPSED=ELEMENT_USER_ELAPSED+USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=ELEMENT_SYSTEM_ELAPSED+USER_ELAPSED
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for boundary+ghost constraint assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for boundary+ghost constraint assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
              IF(NUMBER_OF_TIMES>0) THEN
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element user time for constraint assembly = ", &
                  & ELEMENT_USER_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element system time for constraint assembly = ", &
                  & ELEMENT_SYSTEM_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
              ENDIF
            ENDIF
            !Finalise the element matrices
            CALL CONSTRAINT_MATRICES_ELEMENT_FINALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            !Output constraint matrices and RHS vector if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_MATRIX_OUTPUT) THEN
              CALL CONSTRAINT_MATRICES_JACOBIAN_OUTPUT(GENERAL_OUTPUT_TYPE,CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDIF
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME6,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME6,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME6(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME6(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total user time for constraint assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total system time for constraint assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Constraint matrices is not associated",ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Constraint is not associated",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Lagrange field is not associated",ERR,ERROR,*999)
      ENDIF            
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_STATIC_FEM")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_STATIC_FEM",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_STATIC_FEM")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_STATIC_FEM

  !
  !================================================================================================================================
  !

  !>Evaluates the Jacobian for an dynamic constraint condition using the finite element method
  SUBROUTINE CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_DYNAMIC_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to evaluate the Jacobian for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: element_idx,ne,NUMBER_OF_TIMES
    REAL(SP) :: ELEMENT_USER_ELAPSED,ELEMENT_SYSTEM_ELAPSED,USER_ELAPSED,USER_TIME1(1),USER_TIME2(1),USER_TIME3(1),USER_TIME4(1), &
      & USER_TIME5(1),USER_TIME6(1),SYSTEM_ELAPSED,SYSTEM_TIME1(1),SYSTEM_TIME2(1),SYSTEM_TIME3(1),SYSTEM_TIME4(1), &
      & SYSTEM_TIME5(1),SYSTEM_TIME6(1)
    TYPE(DOMAIN_MAPPING_TYPE), POINTER :: ELEMENTS_MAPPING
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(CONSTRAINT_MATRICES_TYPE), POINTER :: CONSTRAINT_MATRICES
    TYPE(FIELD_TYPE), POINTER :: LAGRANGE_FIELD
  
    CALL ENTERS("CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_DYNAMIC_FEM",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      LAGRANGE_FIELD=>CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD
      IF(ASSOCIATED(LAGRANGE_FIELD)) THEN
        CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
        IF(ASSOCIATED(CONSTRAINT)) THEN
          CONSTRAINT_MATRICES=>CONSTRAINT_EQUATIONS%CONSTRAINT_MATRICES
          IF(ASSOCIATED(CONSTRAINT_MATRICES)) THEN
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME1,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME1,ERR,ERROR,*999)
            ENDIF
!!Do we need to transfer parameter sets???
            !Initialise the matrices and rhs vector
            CALL CONSTRAINT_MATRICES_VALUES_INITIALISE(CONSTRAINT_MATRICES,CONSTRAINT_MATRICES_JACOBIAN_ONLY,0.0_DP,ERR,ERROR,*999)
            !Assemble the elements
            !Allocate the element matrices 
            CALL CONSTRAINT_MATRICES_ELEMENT_INITIALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ELEMENTS_MAPPING=>LAGRANGE_FIELD%DECOMPOSITION%DOMAIN(LAGRANGE_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
              & MAPPINGS%ELEMENTS
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME2,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME2,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME2(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME2(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for constraint conditionup and initialisation = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for constraint conditionup and initialisation = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
              ELEMENT_USER_ELAPSED=0.0_SP
              ELEMENT_SYSTEM_ELAPSED=0.0_SP
            ENDIF
            NUMBER_OF_TIMES=0
            !Loop over the internal elements
            DO element_idx=ELEMENTS_MAPPING%INTERNAL_START,ELEMENTS_MAPPING%INTERNAL_FINISH
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_JACOBIAN_EVALUATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_JACOBIAN_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDDO !element_idx
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME3,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME3,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME3(1)-USER_TIME2(1)
              SYSTEM_ELAPSED=SYSTEM_TIME3(1)-SYSTEM_TIME2(1)
              ELEMENT_USER_ELAPSED=USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=SYSTEM_ELAPSED
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for internal constraint assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for internal constraint assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME4,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME4,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME4(1)-USER_TIME3(1)
              SYSTEM_ELAPSED=SYSTEM_TIME4(1)-SYSTEM_TIME3(1)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for parameter transfer completion = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for parameter transfer completion = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
            !Loop over the boundary and ghost elements
            DO element_idx=ELEMENTS_MAPPING%BOUNDARY_START,ELEMENTS_MAPPING%GHOST_FINISH
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_JACOBIAN_EVALUATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_JACOBIAN_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDDO !element_idx
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME5,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME5,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME5(1)-USER_TIME4(1)
              SYSTEM_ELAPSED=SYSTEM_TIME5(1)-SYSTEM_TIME4(1)
              ELEMENT_USER_ELAPSED=ELEMENT_USER_ELAPSED+USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=ELEMENT_SYSTEM_ELAPSED+USER_ELAPSED
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for boundary+ghost constraint assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for boundary+ghost constraint assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
              IF(NUMBER_OF_TIMES>0) THEN
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element user time for constraint assembly = ", &
                  & ELEMENT_USER_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element system time for constraint assembly = ", &
                  & ELEMENT_SYSTEM_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
              ENDIF
            ENDIF
            !Finalise the element matrices
            CALL CONSTRAINT_MATRICES_ELEMENT_FINALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
             !Output constraint matrices and RHS vector if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_MATRIX_OUTPUT) THEN
              CALL CONSTRAINT_MATRICES_JACOBIAN_OUTPUT(GENERAL_OUTPUT_TYPE,CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDIF
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME6,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME6,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME6(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME6(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total user time for constraint assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total system time for constraint assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Constraint matrices is not associated",ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Constraint is not associated",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Lagrange field is not associated",ERR,ERROR,*999)
      ENDIF            
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_DYNAMIC_FEM")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_DYNAMIC_FEM",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_DYNAMIC_FEM")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_JACOBIAN_EVALUATE_DYNAMIC_FEM

  !
  !================================================================================================================================
  !

  !>Evaluates the residual for an constraint condition.
  SUBROUTINE CONSTRAINT_CONDITION_RESIDUAL_EVALUATE(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to evaluate the residual for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: residual_variable_idx
    TYPE(CONSTRAINT_TYPE), POINTER :: CONSTRAINT
    TYPE(CONSTRAINT_MATRICES_TYPE), POINTER :: CONSTRAINT_MATRICES
    TYPE(CONSTRAINT_MATRICES_NONLINEAR_TYPE), POINTER :: NONLINEAR_MATRICES
    TYPE(CONSTRAINT_MAPPING_TYPE), POINTER :: CONSTRAINT_MAPPING
    TYPE(CONSTRAINT_MAPPING_NONLINEAR_TYPE), POINTER :: NONLINEAR_MAPPING
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: RESIDUAL_PARAMETER_SET
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: RESIDUAL_VARIABLE
    TYPE(VARYING_STRING) :: LOCAL_ERROR
 
    CALL ENTERS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
      IF(ASSOCIATED(CONSTRAINT)) THEN
        IF(CONSTRAINT_EQUATIONS%CONSTRAINT_FINISHED) THEN
          SELECT CASE(CONSTRAINT_EQUATIONS%LINEARITY)
          CASE(CONSTRAINT_CONDITION_LINEAR)
            CALL FLAG_ERROR("Can not evaluate a residual for linear constraint.",ERR,ERROR,*999)
          CASE(CONSTRAINT_CONDITION_NONLINEAR)
            SELECT CASE(CONSTRAINT_EQUATIONS%TIME_DEPENDENCE)
            CASE(CONSTRAINT_CONDITION_STATIC)
              SELECT CASE(CONSTRAINT_CONDITION%SOLUTION_METHOD)
              CASE(CONSTRAINT_CONDITION_FEM_SOLUTION_METHOD)
                CALL CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_STATIC_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_BEM_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_FD_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_FV_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_GFEM_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_GFV_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="The constraint condition solution method  of "// &
                  & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%SOLUTION_METHOD,"*",ERR,ERROR))// &
                  & " is invalid."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(CONSTRAINT_CONDITION_FIRST_ORDER_DYNAMIC,CONSTRAINT_CONDITION_SECOND_ORDER_DYNAMIC)
              SELECT CASE(CONSTRAINT_CONDITION%SOLUTION_METHOD)
              CASE(CONSTRAINT_CONDITION_FEM_SOLUTION_METHOD)
                CALL CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_DYNAMIC_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_BEM_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_FD_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_FV_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_GFEM_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE(CONSTRAINT_CONDITION_GFV_SOLUTION_METHOD)
                CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="The constraint condition solution method  of "// &
                  & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%SOLUTION_METHOD,"*",ERR,ERROR))// &
                  & " is invalid."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE DEFAULT
              LOCAL_ERROR="The constraint condition time dependence type of "// &
                & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_EQUATIONS%TIME_DEPENDENCE,"*",ERR,ERROR))//" is invalid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            END SELECT
          CASE(CONSTRAINT_CONDITION_NONLINEAR_BCS)
            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
          CASE DEFAULT
            LOCAL_ERROR="The constraint linearity of "// &
              & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_EQUATIONS%LINEARITY,"*",ERR,ERROR))//" is invalid."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
          !Update the residual parameter set if it exists
          CONSTRAINT_MAPPING=>CONSTRAINT_EQUATIONS%CONSTRAINT_MAPPING
          IF(ASSOCIATED(CONSTRAINT_MAPPING)) THEN
            NONLINEAR_MAPPING=>CONSTRAINT_MAPPING%NONLINEAR_MAPPING
            IF(ASSOCIATED(NONLINEAR_MAPPING)) THEN
              DO residual_variable_idx=1,NONLINEAR_MAPPING%NUMBER_OF_RESIDUAL_VARIABLES
                RESIDUAL_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLES(residual_variable_idx)%PTR
                IF(ASSOCIATED(RESIDUAL_VARIABLE)) THEN
                  RESIDUAL_PARAMETER_SET=>RESIDUAL_VARIABLE%PARAMETER_SETS%SET_TYPE(FIELD_RESIDUAL_SET_TYPE)%PTR
                  IF(ASSOCIATED(RESIDUAL_PARAMETER_SET)) THEN
                    !Residual parameter set exists
                    CONSTRAINT_MATRICES=>CONSTRAINT_EQUATIONS%CONSTRAINT_MATRICES
                    IF(ASSOCIATED(CONSTRAINT_MATRICES)) THEN
                      NONLINEAR_MATRICES=>CONSTRAINT_MATRICES%NONLINEAR_MATRICES
                      IF(ASSOCIATED(NONLINEAR_MATRICES)) THEN
                        !Copy the residual vector to the residuals parameter set.
                        CALL DISTRIBUTED_VECTOR_COPY(NONLINEAR_MATRICES%RESIDUAL,RESIDUAL_PARAMETER_SET%PARAMETERS,1.0_DP, &
                          & ERR,ERROR,*999)
                      ELSE
                        CALL FLAG_ERROR("Constraint matrices nonlinear matrices is not associated.",ERR,ERROR,*999)
                      ENDIF
                    ELSE
                      CALL FLAG_ERROR("Constraint constraint matrices is not associated.",ERR,ERROR,*999)
                    ENDIF
                  ENDIF
                ELSE
                  LOCAL_ERROR="Nonlinear mapping residual variable for residual variable index "// &
                    & TRIM(NUMBER_TO_VSTRING(residual_variable_idx,"*",ERR,ERROR))//" is not associated."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                ENDIF
              ENDDO !residual_variable_idx
            ELSE
              CALL FLAG_ERROR("Constraint mapping nonlinear mapping is not associated.",ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Constraint constraint mapping is not associated.",ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Constraint have not been finished.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Constraint condition constraint is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE")
    RETURN 1
    
  END SUBROUTINE CONSTRAINT_CONDITION_RESIDUAL_EVALUATE

  !
  !================================================================================================================================
  !

  !>Evaluates the residual for an dynamic constraint condition using the finite element method
  SUBROUTINE CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_DYNAMIC_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to evaluate the residual for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: element_idx,ne,NUMBER_OF_TIMES
    REAL(SP) :: ELEMENT_USER_ELAPSED,ELEMENT_SYSTEM_ELAPSED,USER_ELAPSED,USER_TIME1(1),USER_TIME2(1),USER_TIME3(1),USER_TIME4(1), &
      & USER_TIME5(1),USER_TIME6(1),SYSTEM_ELAPSED,SYSTEM_TIME1(1),SYSTEM_TIME2(1),SYSTEM_TIME3(1),SYSTEM_TIME4(1), &
      & SYSTEM_TIME5(1),SYSTEM_TIME6(1)
    TYPE(DOMAIN_MAPPING_TYPE), POINTER :: ELEMENTS_MAPPING
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(CONSTRAINT_MATRICES_TYPE), POINTER :: CONSTRAINT_MATRICES
    TYPE(FIELD_TYPE), POINTER :: LAGRANGE_FIELD
 
    CALL ENTERS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_DYNAMIC_FEM",ERR,ERROR,*999)

    NULLIFY(ELEMENTS_MAPPING)
    NULLIFY(CONSTRAINT)
    NULLIFY(CONSTRAINT_MATRICES)
    NULLIFY(LAGRANGE_FIELD)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      LAGRANGE_FIELD=>CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD
      IF(ASSOCIATED(LAGRANGE_FIELD)) THEN
        CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
        IF(ASSOCIATED(CONSTRAINT)) THEN
          CONSTRAINT_MATRICES=>CONSTRAINT_EQUATIONS%CONSTRAINT_MATRICES
          IF(ASSOCIATED(CONSTRAINT_MATRICES)) THEN
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME1,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME1,ERR,ERROR,*999)
            ENDIF
            !!Do we need to transfer parameter sets???
            !Initialise the matrices and rhs vector
            CALL CONSTRAINT_MATRICES_VALUES_INITIALISE(CONSTRAINT_MATRICES,CONSTRAINT_MATRICES_NONLINEAR_ONLY,0.0_DP,ERR,ERROR,*999)
            !Assemble the elements
            !Allocate the element matrices 
            CALL CONSTRAINT_MATRICES_ELEMENT_INITIALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ELEMENTS_MAPPING=>LAGRANGE_FIELD%DECOMPOSITION%DOMAIN(LAGRANGE_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
              & MAPPINGS%ELEMENTS
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME2,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME2,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME2(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME2(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for constraint conditionup and initialisation = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for constraint conditionup and initialisation = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
              ELEMENT_USER_ELAPSED=0.0_SP
              ELEMENT_SYSTEM_ELAPSED=0.0_SP
            ENDIF
            NUMBER_OF_TIMES=0
            !Loop over the internal elements
            DO element_idx=ELEMENTS_MAPPING%INTERNAL_START,ELEMENTS_MAPPING%INTERNAL_FINISH
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_RESIDUAL_EVALUATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDDO !element_idx                  
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME3,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME3,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME3(1)-USER_TIME2(1)
              SYSTEM_ELAPSED=SYSTEM_TIME3(1)-SYSTEM_TIME2(1)
              ELEMENT_USER_ELAPSED=USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=SYSTEM_ELAPSED
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for internal constraint assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for internal constraint assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
             ENDIF
             !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME4,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME4,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME4(1)-USER_TIME3(1)
              SYSTEM_ELAPSED=SYSTEM_TIME4(1)-SYSTEM_TIME3(1)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for parameter transfer completion = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for parameter transfer completion = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
            !Loop over the boundary and ghost elements
            DO element_idx=ELEMENTS_MAPPING%BOUNDARY_START,ELEMENTS_MAPPING%GHOST_FINISH
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_RESIDUAL_EVALUATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDDO !element_idx
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME5,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME5,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME5(1)-USER_TIME4(1)
              SYSTEM_ELAPSED=SYSTEM_TIME5(1)-SYSTEM_TIME4(1)
              ELEMENT_USER_ELAPSED=ELEMENT_USER_ELAPSED+USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=ELEMENT_SYSTEM_ELAPSED+USER_ELAPSED
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for boundary+ghost constraint assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for boundary+ghost constraint assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
              IF(NUMBER_OF_TIMES>0) THEN
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element user time for constraint assembly = ", &
                  & ELEMENT_USER_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element system time for constraint assembly = ", &
                  & ELEMENT_SYSTEM_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
              ENDIF
            ENDIF
            !Finalise the element matrices
            CALL CONSTRAINT_MATRICES_ELEMENT_FINALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            !Output constraint matrices and RHS vector if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_MATRIX_OUTPUT) THEN
              CALL CONSTRAINT_MATRICES_OUTPUT(GENERAL_OUTPUT_TYPE,CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDIF
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME6,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME6,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME6(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME6(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total user time for constraint assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total system time for constraint assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Constraint matrices is not associated",ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Constraint is not associated",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Lagrange field is not associated",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_DYNAMIC_FEM")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_DYNAMIC_FEM",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_DYNAMIC_FEM")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_DYNAMIC_FEM

  !
  !================================================================================================================================
  !

  !>Evaluates the residual for an static constraint condition using the finite element method
  SUBROUTINE CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_STATIC_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to evaluate the residual for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: element_idx,ne,NUMBER_OF_TIMES
    REAL(SP) :: ELEMENT_USER_ELAPSED,ELEMENT_SYSTEM_ELAPSED,USER_ELAPSED,USER_TIME1(1),USER_TIME2(1),USER_TIME3(1),USER_TIME4(1), &
      & USER_TIME5(1),USER_TIME6(1),SYSTEM_ELAPSED,SYSTEM_TIME1(1),SYSTEM_TIME2(1),SYSTEM_TIME3(1),SYSTEM_TIME4(1), &
      & SYSTEM_TIME5(1),SYSTEM_TIME6(1)
    TYPE(DOMAIN_MAPPING_TYPE), POINTER :: ELEMENTS_MAPPING
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(CONSTRAINT_MATRICES_TYPE), POINTER :: CONSTRAINT_MATRICES
    TYPE(FIELD_TYPE), POINTER :: LAGRANGE_FIELD
 
    CALL ENTERS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_STATIC_FEM",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      LAGRANGE_FIELD=>CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD
      IF(ASSOCIATED(LAGRANGE_FIELD)) THEN
        CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
        IF(ASSOCIATED(CONSTRAINT)) THEN
          CONSTRAINT_MATRICES=>CONSTRAINT_EQUATIONS%CONSTRAINT_MATRICES
          IF(ASSOCIATED(CONSTRAINT_MATRICES)) THEN
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME1,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME1,ERR,ERROR,*999)
            ENDIF
            !!Do we need to transfer parameter sets???
            !Initialise the matrices and rhs vector
            CALL CONSTRAINT_MATRICES_VALUES_INITIALISE(CONSTRAINT_MATRICES,CONSTRAINT_MATRICES_NONLINEAR_ONLY,0.0_DP,ERR,ERROR,*999)
            !Assemble the elements
            !Allocate the element matrices 
            CALL CONSTRAINT_MATRICES_ELEMENT_INITIALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ELEMENTS_MAPPING=>LAGRANGE_FIELD%DECOMPOSITION%DOMAIN(LAGRANGE_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
              & MAPPINGS%ELEMENTS
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME2,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME2,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME2(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME2(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for constraint condition setup and initialisation = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for constraint condition setup and initialisation = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
              ELEMENT_USER_ELAPSED=0.0_SP
              ELEMENT_SYSTEM_ELAPSED=0.0_SP
            ENDIF
            NUMBER_OF_TIMES=0
            !Loop over the internal elements
            DO element_idx=ELEMENTS_MAPPING%INTERNAL_START,ELEMENTS_MAPPING%INTERNAL_FINISH
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_RESIDUAL_EVALUATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDDO !element_idx
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME3,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME3,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME3(1)-USER_TIME2(1)
              SYSTEM_ELAPSED=SYSTEM_TIME3(1)-SYSTEM_TIME2(1)
              ELEMENT_USER_ELAPSED=USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=SYSTEM_ELAPSED
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for internal constraint assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for internal constraint assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME4,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME4,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME4(1)-USER_TIME3(1)
              SYSTEM_ELAPSED=SYSTEM_TIME4(1)-SYSTEM_TIME3(1)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for parameter transfer completion = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for parameter transfer completion = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
            !Loop over the boundary and ghost elements
            DO element_idx=ELEMENTS_MAPPING%BOUNDARY_START,ELEMENTS_MAPPING%GHOST_FINISH
              ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
              NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
              CALL CONSTRAINT_MATRICES_ELEMENT_CALCULATE(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_RESIDUAL_EVALUATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
              CALL CONSTRAINT_MATRICES_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDDO !element_idx
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME5,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME5,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME5(1)-USER_TIME4(1)
              SYSTEM_ELAPSED=SYSTEM_TIME5(1)-SYSTEM_TIME4(1)
              ELEMENT_USER_ELAPSED=ELEMENT_USER_ELAPSED+USER_ELAPSED
              ELEMENT_SYSTEM_ELAPSED=ELEMENT_SYSTEM_ELAPSED+USER_ELAPSED
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for boundary+ghost constraint assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for boundary+ghost constraint assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
              IF(NUMBER_OF_TIMES>0) THEN
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element user time for constraint assembly = ", &
                  & ELEMENT_USER_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element system time for constraint assembly = ", &
                  & ELEMENT_SYSTEM_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
              ENDIF
            ENDIF
            !Finalise the element matrices
            CALL CONSTRAINT_MATRICES_ELEMENT_FINALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
            !Output constraint matrices and RHS vector if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_MATRIX_OUTPUT) THEN
              CALL CONSTRAINT_MATRICES_OUTPUT(GENERAL_OUTPUT_TYPE,CONSTRAINT_MATRICES,ERR,ERROR,*999)
            ENDIF
            !Output timing information if required
            IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
              CALL CPU_TIMER(USER_CPU,USER_TIME6,ERR,ERROR,*999)
              CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME6,ERR,ERROR,*999)
              USER_ELAPSED=USER_TIME6(1)-USER_TIME1(1)
              SYSTEM_ELAPSED=SYSTEM_TIME6(1)-SYSTEM_TIME1(1)
              CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"",ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total user time for constraint assembly = ",USER_ELAPSED, &
                & ERR,ERROR,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total system time for constraint assembly = ",SYSTEM_ELAPSED, &
                & ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Constraint matrices is not associated",ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Constraint is not associated",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Lagrange field is not associated",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_STATIC_FEM")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_STATIC_FEM",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_STATIC_FEM")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_STATIC_FEM

  !
  !================================================================================================================================
  !

  !>Finalise the constraint condition geometry information and deallocate all memory.
  SUBROUTINE CONSTRAINT_CONDITION_GEOMETRY_FINALISE(CONSTRAINT_GEOMETRY,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_GEOMETRY_TYPE) :: CONSTRAINT_GEOMETRY !<The constraint condition geometry information to finalise.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("CONSTRAINT_CONDITION_GEOMETRY_FINALISE",ERR,ERROR,*999)

    NULLIFY(CONSTRAINT_GEOMETRY%CONSTRAINT_CONDITION)
    NULLIFY(CONSTRAINT_GEOMETRY%GEOMETRIC_FIELD)
       
    CALL EXITS("CONSTRAINT_CONDITION_GEOMETRY_FINALISE")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_GEOMETRY_FINALISE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_GEOMETRY_FINALISE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_GEOMETRY_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises an constraint condition geometry information.
  SUBROUTINE CONSTRAINT_CONDITION_GEOMETRY_INITIALISE(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<The pointer to the constraint condition to initialise to initialise the geometry information for.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: DUMMY_ERR
    TYPE(VARYING_STRING) :: DUMMY_ERROR
 
    CALL ENTERS("CONSTRAINT_CONDITION_GEOMETRY_INITIALISE",ERR,ERROR,*998)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      CONSTRAINT_CONDITION%GEOMETRY%CONSTRAINT_CONDITION=>CONSTRAINT_CONDITION
      NULLIFY(CONSTRAINT_CONDITION%GEOMETRY%GEOMETRIC_FIELD)
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_GEOMETRY_INITIALISE")
    RETURN
999 CALL CONSTRAINT_CONDITION_GEOMETRY_FINALISE(CONSTRAINT_CONDITION%GEOMETRY,DUMMY_ERR,DUMMY_ERROR,*998)
998 CALL ERRORS("CONSTRAINT_CONDITION_GEOMETRY_INITIALISE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_GEOMETRY_INITIALISE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_GEOMETRY_INITIALISE

  !
  !================================================================================================================================
  !

  !>Initialises an constraint condition.
  SUBROUTINE CONSTRAINT_CONDITION_INITIALISE(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<The pointer to the constraint condition to initialise. Must not be associated on entry.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: DUMMY_ERR
    TYPE(VARYING_STRING) :: DUMMY_ERROR
 
    CALL ENTERS("CONSTRAINT_CONDITION_INITIALISE",ERR,ERROR,*998)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      CALL FLAG_ERROR("Constraint condition is already associated.",ERR,ERROR,*998)
    ELSE
      ALLOCATE(CONSTRAINT_CONDITION,STAT=ERR)
      IF(ERR/=0) CALL FLAG_ERROR("Could not allocate constraint condition.",ERR,ERROR,*999)
      CONSTRAINT_CONDITION%USER_NUMBER=0
      CONSTRAINT_CONDITION%GLOBAL_NUMBER=0
      CONSTRAINT_CONDITION%CONSTRAINT_CONDITION_FINISHED=.FALSE.
      NULLIFY(CONSTRAINT_CONDITION%CONSTRAINT_CONDITIONS)
      NULLIFY(CONSTRAINT_CONDITION%CONSTRAINT)
      CONSTRAINT_CONDITION%METHOD=0
      CONSTRAINT_CONDITION%OPERATOR=0
      NULLIFY(CONSTRAINT_CONDITION%LAGRANGE)
      NULLIFY(CONSTRAINT_CONDITION%PENALTY)
      NULLIFY(CONSTRAINT_CONDITION%DEPENDENT)
      NULLIFY(CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS)
      CALL CONSTRAINT_CONDITION_GEOMETRY_INITIALISE(CONSTRAINT_CONDITION,ERR,ERROR,*999)
      NULLIFY(CONSTRAINT_CONDITION%BOUNDARY_CONDITIONS)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_INITIALISE")
    RETURN
999 CALL CONSTRAINT_CONDITION_FINALISE(CONSTRAINT_CONDITION,DUMMY_ERR,DUMMY_ERROR,*998)
998 CALL ERRORS("CONSTRAINT_CONDITION_INITIALISE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_INITIALISE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_INITIALISE

  !
  !================================================================================================================================
  !

  !>Finishes the process of creating an constraint condition's Lagrange multiplier field \see OPENCMISS::CMISSConstraintConditionLagrangeConditionCreateFinish
  SUBROUTINE CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_FINISH(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to finish creating the Lagrange field for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: LagrangeFieldUVariableNumberOfComponents,LagrangeFieldDelUDelNVariableNumberOfComponents
    
    CALL ENTERS("CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_FINISH",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(ASSOCIATED(CONSTRAINT_CONDITION%LAGRANGE)) THEN
        IF(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FINISHED) THEN
          CALL FLAG_ERROR("Constraint condition Lagrange field has already been finished.",ERR,ERROR,*999)
        ELSE
          !Finish the Lagrange field creation
          IF(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD_AUTO_CREATED) THEN
            CALL FIELD_CREATE_FINISH(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,ERR,ERROR,*999)
          ENDIF
          CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FINISHED=.TRUE.
          !\todo test following condition using some other method since FIELD_NUMBER_OF_COMPONENTS_GET requires the field to be finished which is what occurs above, but below condition needs to be checked before this.
          CALL FIELD_NUMBER_OF_COMPONENTS_GET(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,FIELD_U_VARIABLE_TYPE, &
            & LagrangeFieldUVariableNumberOfComponents,ERR,ERROR,*999)
          CALL FIELD_NUMBER_OF_COMPONENTS_GET(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,FIELD_DELUDELN_VARIABLE_TYPE, &
            & LagrangeFieldDelUDelNVariableNumberOfComponents,ERR,ERROR,*999)
          IF (LagrangeFieldUVariableNumberOfComponents /= LagrangeFieldDelUDelNVariableNumberOfComponents) THEN
            CALL FLAG_ERROR("Constraint Lagrange field U and DelUDelN variable components do not match.",ERR,ERROR,*999)
          ENDIF
        ENDIF
      ELSE
        CALL FLAG_ERROR("Constraint condition Lagrange is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_FINISH")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_FINISH",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_FINISH")
    RETURN 1
   
  END SUBROUTINE CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_FINISH
        
  !
  !================================================================================================================================
  !

  !>Starts the process of creating the Lagrange multiplyer field for constraint condition. \see OPENCMISS::CMISSConstraintConditionLagrangeFieldCreateStart
  SUBROUTINE CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_START(CONSTRAINT_CONDITION,LAGRANGE_FIELD_USER_NUMBER,LAGRANGE_FIELD, &
    & ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to create the Lagrange field on
    INTEGER(INTG), INTENT(IN) :: LAGRANGE_FIELD_USER_NUMBER !<The user specified Lagrange field number
    TYPE(FIELD_TYPE), POINTER :: LAGRANGE_FIELD !<If associated on entry, a pointer to the user created Lagrange field which has the same user number as the specified Lagrange field user number. If not associated on entry, on exit, a pointer to the created Lagrange field for the constraint condition.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx,interpolation_type,GEOMETRIC_SCALING_TYPE,dependent_variable_number
    TYPE(DECOMPOSITION_TYPE), POINTER :: GEOMETRIC_DECOMPOSITION
    TYPE(FIELD_TYPE), POINTER :: FIELD
    TYPE(REGION_TYPE), POINTER :: REGION
    TYPE(CONSTRAINT_DEPENDENT_TYPE), POINTER :: CONSTRAINT_DEPENDENT
    TYPE(REGION_TYPE), POINTER :: CONSTRAINT_REGION,LAGRANGE_FIELD_REGION
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_START",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(ASSOCIATED(CONSTRAINT_CONDITION%LAGRANGE)) THEN
        CALL FLAG_ERROR("Constraint condition Lagrange is already associated.",ERR,ERROR,*999)
      ELSE
        CONSTRAINT_DEPENDENT=>CONSTRAINT_CONDITION%DEPENDENT
        IF(ASSOCIATED(CONSTRAINT_DEPENDENT)) THEN
          REGION=>CONSTRAINT_CONDITION%REGION
          IF(ASSOCIATED(REGION)) THEN
            IF(ASSOCIATED(LAGRANGE_FIELD)) THEN
              !Check the Lagrange field has been finished
              IF(LAGRANGE_FIELD%FIELD_FINISHED) THEN
                !Check the user numbers match
                IF(LAGRANGE_FIELD_USER_NUMBER/=LAGRANGE_FIELD%USER_NUMBER) THEN
                  LOCAL_ERROR="The specified Lagrange field user number of "// &
                    & TRIM(NUMBER_TO_VSTRING(LAGRANGE_FIELD_USER_NUMBER,"*",ERR,ERROR))// &
                    & " does not match the user number of the specified Lagrange field of "// &
                    & TRIM(NUMBER_TO_VSTRING(LAGRANGE_FIELD%USER_NUMBER,"*",ERR,ERROR))//"."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                ENDIF
                LAGRANGE_FIELD_REGION=>LAGRANGE_FIELD%REGION
                IF(ASSOCIATED(LAGRANGE_FIELD_REGION)) THEN
                  !Check the field is defined on the same region as the constraint
                  IF(LAGRANGE_FIELD_REGION%USER_NUMBER/=REGION%USER_NUMBER) THEN
                    LOCAL_ERROR="Invalid region setup. The specified Lagrange field has been created on region number "// &
                      & TRIM(NUMBER_TO_VSTRING(LAGRANGE_FIELD_REGION%USER_NUMBER,"*",ERR,ERROR))// &
                      & " and the specified constraint condition has been created in region number "// &
                      & TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))//"."
                    CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  ENDIF
                ELSE
                  CALL FLAG_ERROR("The Lagrange field region is not associated.",ERR,ERROR,*999)
                ENDIF
              ELSE
                CALL FLAG_ERROR("The specified Lagrange field has not been finished.",ERR,ERROR,*999)
              ENDIF
            ELSE
              !Check the user number has not already been used for a field in this region.
              NULLIFY(FIELD)
              CALL FIELD_USER_NUMBER_FIND(LAGRANGE_FIELD_USER_NUMBER,REGION,FIELD,ERR,ERROR,*999)
              IF(ASSOCIATED(FIELD)) THEN
                LOCAL_ERROR="The specified Lagrange field user number of "// &
                  & TRIM(NUMBER_TO_VSTRING(LAGRANGE_FIELD_USER_NUMBER,"*",ERR,ERROR))// &
                  & " has already been used to create a field on region number "// &
                  & TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))//"."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              ENDIF
            ENDIF
            CALL CONSTRAINT_CONDITION_LAGRANGE_INITIALISE(CONSTRAINT_CONDITION,ERR,ERROR,*999)
            IF(.NOT.ASSOCIATED(LAGRANGE_FIELD)) THEN
              !Create the Lagrange field
              CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD_AUTO_CREATED=.TRUE.
              CALL FIELD_CREATE_START(LAGRANGE_FIELD_USER_NUMBER,CONSTRAINT_CONDITION%REGION,CONSTRAINT_CONDITION%LAGRANGE% &
                & LAGRANGE_FIELD,ERR,ERROR,*999)
              CALL FIELD_LABEL_SET(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,"Lagrange Multipliers Field",ERR,ERROR,*999)
              CALL FIELD_TYPE_SET_AND_LOCK(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,FIELD_GENERAL_TYPE,ERR,ERROR,*999)
              CALL FIELD_DEPENDENT_TYPE_SET_AND_LOCK(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,FIELD_DEPENDENT_TYPE, &
                & ERR,ERROR,*999)
              NULLIFY(GEOMETRIC_DECOMPOSITION)
              CALL FIELD_MESH_DECOMPOSITION_GET(CONSTRAINT_CONDITION%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_DECOMPOSITION, &
                & ERR,ERROR,*999)
              CALL FIELD_MESH_DECOMPOSITION_SET_AND_LOCK(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,GEOMETRIC_DECOMPOSITION, &
                & ERR,ERROR,*999)
              CALL FIELD_GEOMETRIC_FIELD_SET_AND_LOCK(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,CONSTRAINT_CONDITION%GEOMETRY% &
                & GEOMETRIC_FIELD,ERR,ERROR,*999)
              CALL FIELD_NUMBER_OF_VARIABLES_SET_AND_LOCK(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,2,ERR,ERROR,*999)
              CALL FIELD_VARIABLE_TYPES_SET_AND_LOCK(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,[FIELD_U_VARIABLE_TYPE, &
                & FIELD_DELUDELN_VARIABLE_TYPE],ERR,ERROR,*999)
              CALL FIELD_VARIABLE_LABEL_SET(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,FIELD_U_VARIABLE_TYPE,"Lambda", &
                & ERR,ERROR,*999)
              CALL FIELD_VARIABLE_LABEL_SET(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,FIELD_DELUDELN_VARIABLE_TYPE, &
                & "Lambda RHS",ERR,ERROR,*999)
              CALL FIELD_DIMENSION_SET_AND_LOCK(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,FIELD_U_VARIABLE_TYPE, &
                & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
              CALL FIELD_DIMENSION_SET_AND_LOCK(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,FIELD_DELUDELN_VARIABLE_TYPE, &
                & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
              CALL FIELD_DATA_TYPE_SET_AND_LOCK(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,FIELD_U_VARIABLE_TYPE, &
                & FIELD_DP_TYPE,ERR,ERROR,*999)
              CALL FIELD_DATA_TYPE_SET_AND_LOCK(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,FIELD_DELUDELN_VARIABLE_TYPE, &
                & FIELD_DP_TYPE,ERR,ERROR,*999)
              CONSTRAINT_CONDITION%LAGRANGE%NUMBER_OF_COMPONENTS=1
              CALL FIELD_NUMBER_OF_COMPONENTS_SET(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,FIELD_U_VARIABLE_TYPE, &
                & CONSTRAINT_CONDITION%LAGRANGE%NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
              CALL FIELD_NUMBER_OF_COMPONENTS_SET(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,FIELD_DELUDELN_VARIABLE_TYPE, &
                & CONSTRAINT_CONDITION%LAGRANGE%NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
              DO component_idx=1,CONSTRAINT_CONDITION%LAGRANGE%NUMBER_OF_COMPONENTS
              CALL FIELD_COMPONENT_INTERPOLATION_GET(CONSTRAINT_DEPENDENT%FIELD_VARIABLES(1)%PTR%FIELD,FIELD_U_VARIABLE_TYPE, &
                & component_idx,interpolation_type,ERR,ERROR,*999)
              CALL FIELD_COMPONENT_INTERPOLATION_SET(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD, &
                & FIELD_U_VARIABLE_TYPE,component_idx,interpolation_type,ERR,ERROR,*999)
              CALL FIELD_COMPONENT_INTERPOLATION_SET(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD, &
                & FIELD_DELUDELN_VARIABLE_TYPE,component_idx,interpolation_type,ERR,ERROR,*999)
              ENDDO !component_idx
              CALL FIELD_SCALING_TYPE_GET(CONSTRAINT_CONDITION%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_SCALING_TYPE, &
                & ERR,ERROR,*999)
              CALL FIELD_SCALING_TYPE_SET(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD,GEOMETRIC_SCALING_TYPE, &
                & ERR,ERROR,*999)
            ELSE
              !Check the Lagrange field
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            ENDIF
            !Set pointers
            IF(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD_AUTO_CREATED) THEN
              LAGRANGE_FIELD=>CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD
            ELSE
              CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD=>LAGRANGE_FIELD
            ENDIF
          ELSE
            CALL FLAG_ERROR("The constraint region is not associated.",ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Constraint condition dependent is not associated.",ERR,ERROR,*999)
        ENDIF
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint conditions is not associated.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_START")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_START",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_START")
    RETURN 1   
  END SUBROUTINE CONSTRAINT_CONDITION_LAGRANGE_FIELD_CREATE_START
  
  !
  !================================================================================================================================
  !

  !>Finalise the constraint condition Lagrange information and deallocate all memory.
  SUBROUTINE CONSTRAINT_CONDITION_LAGRANGE_FINALISE(CONSTRAINT_LAGRANGE,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_LAGRANGE_TYPE), POINTER :: CONSTRAINT_LAGRANGE !<A pointer to the constraint condition Lagrange information to finalise.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("CONSTRAINT_CONDITION_LAGRANGE_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_LAGRANGE)) THEN
      DEALLOCATE(CONSTRAINT_LAGRANGE)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_LAGRANGE_FINALISE")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_LAGRANGE_FINALISE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_LAGRANGE_FINALISE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_LAGRANGE_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises an constraint condition Lagrange information.
  SUBROUTINE CONSTRAINT_CONDITION_LAGRANGE_INITIALISE(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<The pointer to the constraint condition to initialise to initialise the Lagrange information for.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: DUMMY_ERR
    TYPE(VARYING_STRING) :: DUMMY_ERROR
 
    CALL ENTERS("CONSTRAINT_CONDITION_LAGRANGE_INITIALISE",ERR,ERROR,*998)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(ASSOCIATED(CONSTRAINT_CONDITION%LAGRANGE)) THEN
        CALL FLAG_ERROR("Constraint condition Lagrange is already associated.",ERR,ERROR,*999)
      ELSE
        ALLOCATE(CONSTRAINT_CONDITION%LAGRANGE,STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate constraint condition Lagrange.",ERR,ERROR,*999)
        CONSTRAINT_CONDITION%LAGRANGE%CONSTRAINT_CONDITION=>CONSTRAINT_CONDITION
        CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FINISHED=.FALSE.
        CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD_AUTO_CREATED=.FALSE.
        NULLIFY(CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD)
        CONSTRAINT_CONDITION%LAGRANGE%NUMBER_OF_COMPONENTS=0
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_LAGRANGE_INITIALISE")
    RETURN
999 CALL CONSTRAINT_CONDITION_LAGRANGE_FINALISE(CONSTRAINT_CONDITION%LAGRANGE,DUMMY_ERR,DUMMY_ERROR,*998)
998 CALL ERRORS("CONSTRAINT_CONDITION_LAGRANGE_INITIALISE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_LAGRANGE_INITIALISE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_LAGRANGE_INITIALISE

  !
  !================================================================================================================================
  !

  !>Finishes the process of creating an constraint condition's penalty field'. \see OPENCMISS::CMISSConstraintConditionPenaltyConditionCreateFinish
  SUBROUTINE CONSTRAINT_CONDITION_PENALTY_FIELD_CREATE_FINISH(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to finish creating the penalty field for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    
    CALL ENTERS("CONSTRAINT_CONDITION_PENALTY_FIELD_CREATE_FINISH",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(ASSOCIATED(CONSTRAINT_CONDITION%PENALTY)) THEN
        IF(CONSTRAINT_CONDITION%PENALTY%PENALTY_FINISHED) THEN
          CALL FLAG_ERROR("Constraint condition penalty field has already been finished.",ERR,ERROR,*999)
        ELSE
          !Finish the penalty field creation
          IF(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD_AUTO_CREATED) THEN
            CALL FIELD_CREATE_FINISH(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD,ERR,ERROR,*999)
          ENDIF
          CONSTRAINT_CONDITION%PENALTY%PENALTY_FINISHED=.TRUE.
        ENDIF
      ELSE
        CALL FLAG_ERROR("Constraint condition penalty is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_PENALTY_FIELD_CREATE_FINISH")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_PENALTY_FIELD_CREATE_FINISH",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_PENALTY_FIELD_CREATE_FINISH")
    RETURN 1
   
  END SUBROUTINE CONSTRAINT_CONDITION_PENALTY_FIELD_CREATE_FINISH

  !
  !================================================================================================================================
  !

  !>Starts the process of creating the penalty field for constraint condition. \see OPENCMISS::CMISSConstraintConditionPenaltyFieldCreateStart
  SUBROUTINE CONSTRAINT_CONDITION_PENALTY_FIELD_CREATE_START(CONSTRAINT_CONDITION,PENALTY_FIELD_USER_NUMBER,PENALTY_FIELD, &
    & ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to create the penalty field on
    INTEGER(INTG), INTENT(IN) :: PENALTY_FIELD_USER_NUMBER !<The user specified penalty field number
    TYPE(FIELD_TYPE), POINTER :: PENALTY_FIELD !<If associated on entry, a pointer to the user created penalty field which has the same user number as the specified penalty field user number. If not associated on entry, on exit, a pointer to the created penalty field for the constraint condition.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx,GEOMETRIC_SCALING_TYPE
    TYPE(DECOMPOSITION_TYPE), POINTER :: GEOMETRIC_DECOMPOSITION
    TYPE(FIELD_TYPE), POINTER :: FIELD
    TYPE(REGION_TYPE), POINTER :: REGION
    TYPE(CONSTRAINT_DEPENDENT_TYPE), POINTER :: CONSTRAINT_DEPENDENT
    TYPE(REGION_TYPE), POINTER :: PENALTY_FIELD_REGION
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("CONSTRAINT_CONDITION_PENALTY_FIELD_CREATE_START",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(ASSOCIATED(CONSTRAINT_CONDITION%PENALTY)) THEN
        CALL FLAG_ERROR("Constraint condition penalty is already associated.",ERR,ERROR,*999)
      ELSE
        CONSTRAINT_DEPENDENT=>CONSTRAINT_CONDITION%DEPENDENT
        IF(ASSOCIATED(CONSTRAINT_DEPENDENT)) THEN
          REGION=>CONSTRAINT_CONDITION%REGION
          IF(ASSOCIATED(PENALTY_FIELD)) THEN
            !Check the penalty field has been finished
            IF(PENALTY_FIELD%FIELD_FINISHED) THEN
              !Check the user numbers match
              IF(PENALTY_FIELD_USER_NUMBER/=PENALTY_FIELD%USER_NUMBER) THEN
                LOCAL_ERROR="The specified penalty field user number of "// &
                  & TRIM(NUMBER_TO_VSTRING(PENALTY_FIELD_USER_NUMBER,"*",ERR,ERROR))// &
                  & " does not match the user number of the specified penalty field of "// &
                  & TRIM(NUMBER_TO_VSTRING(PENALTY_FIELD%USER_NUMBER,"*",ERR,ERROR))//"."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              ENDIF
              PENALTY_FIELD_REGION=>PENALTY_FIELD%REGION
              IF(ASSOCIATED(PENALTY_FIELD_REGION)) THEN
                !Check the field is defined on the same region as the constraint
                IF(PENALTY_FIELD_REGION%USER_NUMBER/=REGION%USER_NUMBER) THEN
                  LOCAL_ERROR="Invalid region setup. The specified penalty field has been created on region number "// &
                    & TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))//"."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                ENDIF
              ELSE
                CALL FLAG_ERROR("The penalty field region is not associated.",ERR,ERROR,*999)
              ENDIF
            ELSE
              CALL FLAG_ERROR("The specified penalty field has not been finished.",ERR,ERROR,*999)
            ENDIF
          ELSE
            !Check the user number has not already been used for a field in this region.
            NULLIFY(FIELD)
            CALL FIELD_USER_NUMBER_FIND(PENALTY_FIELD_USER_NUMBER,REGION,FIELD,ERR,ERROR,*999)
            IF(ASSOCIATED(FIELD)) THEN
              LOCAL_ERROR="The specified penalty field user number of "// &
                & TRIM(NUMBER_TO_VSTRING(PENALTY_FIELD_USER_NUMBER,"*",ERR,ERROR))// &
                & " has already been used to create a field on region number "// &
                & TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))//"."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          ENDIF
          CALL CONSTRAINT_CONDITION_PENALTY_INITIALISE(CONSTRAINT_CONDITION,ERR,ERROR,*999)
          IF(.NOT.ASSOCIATED(PENALTY_FIELD)) THEN
            !Create the penalty field
            CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD_AUTO_CREATED=.TRUE.
            CALL FIELD_CREATE_START(PENALTY_FIELD_USER_NUMBER,CONSTRAINT_CONDITION%REGION,CONSTRAINT_CONDITION%PENALTY% &
              & PENALTY_FIELD,ERR,ERROR,*999)
            CALL FIELD_LABEL_SET(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD,"Penalty Field",ERR,ERROR,*999)
            CALL FIELD_TYPE_SET_AND_LOCK(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD,FIELD_GENERAL_TYPE,ERR,ERROR,*999)
            CALL FIELD_DEPENDENT_TYPE_SET_AND_LOCK(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD,FIELD_DEPENDENT_TYPE, &
              & ERR,ERROR,*999)
            NULLIFY(GEOMETRIC_DECOMPOSITION)
            CALL FIELD_MESH_DECOMPOSITION_GET(CONSTRAINT_CONDITION%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_DECOMPOSITION, &
              & ERR,ERROR,*999)
            CALL FIELD_MESH_DECOMPOSITION_SET_AND_LOCK(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD,GEOMETRIC_DECOMPOSITION, &
              & ERR,ERROR,*999)
            CALL FIELD_GEOMETRIC_FIELD_SET_AND_LOCK(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD,CONSTRAINT_CONDITION%GEOMETRY% &
              & GEOMETRIC_FIELD,ERR,ERROR,*999)
            CALL FIELD_NUMBER_OF_VARIABLES_SET_AND_LOCK(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD,1,ERR,ERROR,*999)
            CALL FIELD_VARIABLE_TYPES_SET_AND_LOCK(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD,[FIELD_U_VARIABLE_TYPE], &
              & ERR,ERROR,*999)
            CALL FIELD_VARIABLE_LABEL_SET(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD,FIELD_U_VARIABLE_TYPE,"Alpha", &
              & ERR,ERROR,*999)
            CALL FIELD_DIMENSION_SET_AND_LOCK(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD,FIELD_U_VARIABLE_TYPE, &
              & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
            CALL FIELD_DATA_TYPE_SET_AND_LOCK(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD,FIELD_U_VARIABLE_TYPE, &
              & FIELD_DP_TYPE,ERR,ERROR,*999)
            !Default the number of component to the first variable of the constraint dependent field's number of components, 
            CALL FIELD_NUMBER_OF_COMPONENTS_SET(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD,FIELD_U_VARIABLE_TYPE, &
              & CONSTRAINT_DEPENDENT%FIELD_VARIABLES(1)%PTR%NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
            DO component_idx=1,CONSTRAINT_DEPENDENT%FIELD_VARIABLES(1)%PTR%NUMBER_OF_COMPONENTS
            CALL FIELD_COMPONENT_INTERPOLATION_SET_AND_LOCK(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD, &
              & FIELD_U_VARIABLE_TYPE,component_idx,FIELD_CONSTANT_INTERPOLATION,ERR,ERROR,*999)
            ENDDO !component_idx
            CALL FIELD_SCALING_TYPE_GET(CONSTRAINT_CONDITION%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_SCALING_TYPE, &
              & ERR,ERROR,*999)
            CALL FIELD_SCALING_TYPE_SET(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD,GEOMETRIC_SCALING_TYPE, &
              & ERR,ERROR,*999)
          ELSE
            !Check the penalty field
            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
          ENDIF
          !Set pointers
          IF(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD_AUTO_CREATED) THEN
            PENALTY_FIELD=>CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD
          ELSE
            CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD=>PENALTY_FIELD
          ENDIF
        ELSE
          CALL FLAG_ERROR("Constraint condition dependent is not associated.",ERR,ERROR,*999)
        ENDIF
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint conditions is not associated.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("CONSTRAINT_CONDITION_PENALTY_FIELD_CREATE_START")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_PENALTY_FIELD_CREATE_START",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_PENALTY_FIELD_CREATE_START")
    RETURN 1   
  END SUBROUTINE CONSTRAINT_CONDITION_PENALTY_FIELD_CREATE_START
  
  !
  !================================================================================================================================
  !

  !>Finalise the constraint condition penalty information and deallocate all memory.
  SUBROUTINE CONSTRAINT_CONDITION_PENALTY_FINALISE(CONSTRAINT_PENALTY,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_PENALTY_TYPE), POINTER :: CONSTRAINT_PENALTY !<A pointer to the constraint condition penalty information to finalise.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("CONSTRAINT_CONDITION_PENALTY_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_PENALTY)) THEN
      DEALLOCATE(CONSTRAINT_PENALTY)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_PENALTY_FINALISE")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_PENALTY_FINALISE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_PENALTY_FINALISE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_PENALTY_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises an constraint condition penalty information.
  SUBROUTINE CONSTRAINT_CONDITION_PENALTY_INITIALISE(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<The pointer to the constraint condition to initialise to initialise the penalty information for.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: DUMMY_ERR
    TYPE(VARYING_STRING) :: DUMMY_ERROR
 
    CALL ENTERS("CONSTRAINT_CONDITION_PENALTY_INITIALISE",ERR,ERROR,*998)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(ASSOCIATED(CONSTRAINT_CONDITION%PENALTY)) THEN
        CALL FLAG_ERROR("Constraint condition penalty is already associated.",ERR,ERROR,*999)
      ELSE
        ALLOCATE(CONSTRAINT_CONDITION%PENALTY,STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate constraint condition penalty.",ERR,ERROR,*999)
        CONSTRAINT_CONDITION%PENALTY%CONSTRAINT_CONDITION=>CONSTRAINT_CONDITION
        CONSTRAINT_CONDITION%PENALTY%PENALTY_FINISHED=.FALSE.
        CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD_AUTO_CREATED=.FALSE.
        NULLIFY(CONSTRAINT_CONDITION%PENALTY%PENALTY_FIELD)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_PENALTY_INITIALISE")
    RETURN
999 CALL CONSTRAINT_CONDITION_PENALTY_FINALISE(CONSTRAINT_CONDITION%PENALTY,DUMMY_ERR,DUMMY_ERROR,*998)
998 CALL ERRORS("CONSTRAINT_CONDITION_PENALTY_INITIALISE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_PENALTY_INITIALISE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_PENALTY_INITIALISE

  !
  !================================================================================================================================
  !

  !>Returns the constraint condition method \see OPENCMISS::CMISSConstraintConditionMethodGet
  SUBROUTINE CONSTRAINT_CONDITION_METHOD_GET(CONSTRAINT_CONDITION,CONSTRAINT_CONDITION_METHOD,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to get the method for
    INTEGER(INTG), INTENT(OUT) :: CONSTRAINT_CONDITION_METHOD !<On return, the constraint condition method. \see CONSTRAINT_CONDITIONS_Methods,CONSTRAINT_CONDITIONS
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("CONSTRAINT_CONDITION_METHOD_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(CONSTRAINT_CONDITION%CONSTRAINT_CONDITION_FINISHED) THEN
        CONSTRAINT_CONDITION_METHOD=CONSTRAINT_CONDITION%METHOD
      ELSE
        CALL FLAG_ERROR("Constraint condition has not been finished.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("CONSTRAINT_CONDITION_METHOD_GET")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_METHOD_GET",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_METHOD_GET")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_METHOD_GET
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the constraint condition method \see OPENCMISS::CMISSConstraintConditionMethodSet
  SUBROUTINE CONSTRAINT_CONDITION_METHOD_SET(CONSTRAINT_CONDITION,CONSTRAINT_CONDITION_METHOD,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to set the method for
    INTEGER(INTG), INTENT(IN) :: CONSTRAINT_CONDITION_METHOD !<The constraint condition method to set. \see CONSTRAINT_CONDITIONS_Methods,CONSTRAINT_CONDITIONS
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("CONSTRAINT_CONDITION_METHOD_SET",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(CONSTRAINT_CONDITION%CONSTRAINT_CONDITION_FINISHED) THEN
        CALL FLAG_ERROR("Constraint condition has been finished.",ERR,ERROR,*999)
      ELSE
        SELECT CASE(CONSTRAINT_CONDITION_METHOD)
        CASE(CONSTRAINT_CONDITION_POINT_TO_POINT_METHOD)
          CONSTRAINT_CONDITION%METHOD=CONSTRAINT_CONDITION_POINT_TO_POINT_METHOD
        CASE(CONSTRAINT_CONDITION_LAGRANGE_MULTIPLIERS_METHOD)
          CONSTRAINT_CONDITION%METHOD=CONSTRAINT_CONDITION_LAGRANGE_MULTIPLIERS_METHOD
        CASE(CONSTRAINT_CONDITION_AUGMENTED_LAGRANGE_METHOD)
          CONSTRAINT_CONDITION%METHOD=CONSTRAINT_CONDITION_AUGMENTED_LAGRANGE_METHOD
         CASE(CONSTRAINT_CONDITION_PENALTY_METHOD)
          CONSTRAINT_CONDITION%METHOD=CONSTRAINT_CONDITION_PENALTY_METHOD
       CASE DEFAULT
          LOCAL_ERROR="The specified constraint condition method of "// &
            & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION_METHOD,"*",ERR,ERROR))//" is not valid."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("CONSTRAINT_CONDITION_METHOD_SET")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_METHOD_SET",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_METHOD_SET")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_METHOD_SET
  
  !
  !================================================================================================================================
  !

  !>Returns the constraint condition operator \see OPENCMISS::CMISSConstraintConditionOperatorGet
  SUBROUTINE CONSTRAINT_CONDITION_OPERATOR_GET(CONSTRAINT_CONDITION,CONSTRAINT_CONDITION_OPERATOR,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to get the operator for
    INTEGER(INTG), INTENT(OUT) :: CONSTRAINT_CONDITION_OPERATOR !<On return, the constraint condition operator. \see CONSTRAINT_CONDITIONS_Operators,CONSTRAINT_CONDITIONS 
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("CONSTRAINT_CONDITION_OPERATOR_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(CONSTRAINT_CONDITION%CONSTRAINT_CONDITION_FINISHED) THEN
        CONSTRAINT_CONDITION_OPERATOR=CONSTRAINT_CONDITION%OPERATOR
      ELSE
        CALL FLAG_ERROR("Constraint condition has not been finished.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("CONSTRAINT_CONDITION_OPERATOR_GET")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_OPERATOR_GET",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_OPERATOR_GET")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_OPERATOR_GET
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the constraint condition operator \see OPENCMISS::CMISSConstraintConditionOperatorSet
  SUBROUTINE CONSTRAINT_CONDITION_OPERATOR_SET(CONSTRAINT_CONDITION,CONSTRAINT_CONDITION_OPERATOR,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to set the operator for
    INTEGER(INTG), INTENT(IN) :: CONSTRAINT_CONDITION_OPERATOR !<The constraint condition operator to set. \see CONSTRAINT_CONDITIONS_Operators,CONSTRAINT_CONDITIONS 
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("CONSTRAINT_CONDITION_OPERATOR_SET",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      IF(CONSTRAINT_CONDITION%CONSTRAINT_CONDITION_FINISHED) THEN
        CALL FLAG_ERROR("Constraint condition has been finished.",ERR,ERROR,*999)
      ELSE
        SELECT CASE(CONSTRAINT_CONDITION_OPERATOR)
        CASE(CONSTRAINT_CONDITION_FE_INCOMPRESSIBILITY_OPERATOR)
          CONSTRAINT_CONDITION%OPERATOR=CONSTRAINT_CONDITION_FE_INCOMPRESSIBILITY_OPERATOR
        CASE DEFAULT
          LOCAL_ERROR="The specified constraint condition operator of "// &
            & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION_OPERATOR,"*",ERR,ERROR))//" is not valid."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("CONSTRAINT_CONDITION_OPERATOR_SET")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_OPERATOR_SET",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_OPERATOR_SET")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_OPERATOR_SET
  
  !
  !================================================================================================================================
  !

  !>Evaluates the residual for an constraint condition.
  SUBROUTINE CONSTRAINT_CONDITION_RESIDUAL_EVALUATE(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to evaluate the residual for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
      IF(ASSOCIATED(CONSTRAINT_EQUATIONS)) THEN
        IF(CONSTRAINT_EQUATIONS%CONSTRAINT_EQUATIONS_FINISHED) THEN
          SELECT CASE(CONSTRAINT_CONDITION%METHOD)
          CASE(CONSTRAINT_CONDITION_LAGRANGE_MULTIPLIERS_METHOD,CONSTRAINT_CONDITION_PENALTY_METHOD)
            CALL CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*999)
          CASE(CONSTRAINT_CONDITION_AUGMENTED_LAGRANGE_METHOD)
            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
          CASE(CONSTRAINT_CONDITION_POINT_TO_POINT_METHOD)
            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
          CASE DEFAULT
            LOCAL_ERROR="The constraint condition method of "// &
              & TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%METHOD,"*",ERR,ERROR))// &
              & " is invalid."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Constraint equations have not been finished.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Constraint condition equations is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE")
    RETURN 1
    
  END SUBROUTINE CONSTRAINT_CONDITION_RESIDUAL_EVALUATE

  !
  !================================================================================================================================
  !

  !>Evaluates the residual for an constraint condition using the finite element method
  SUBROUTINE CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_FEM(CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition to evaluate the residual for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: element_idx,ne,NUMBER_OF_TIMES
    REAL(SP) :: ELEMENT_USER_ELAPSED,ELEMENT_SYSTEM_ELAPSED,USER_ELAPSED,USER_TIME1(1),USER_TIME2(1),USER_TIME3(1),USER_TIME4(1), &
      & USER_TIME5(1),USER_TIME6(1),SYSTEM_ELAPSED,SYSTEM_TIME1(1),SYSTEM_TIME2(1),SYSTEM_TIME3(1),SYSTEM_TIME4(1), &
      & SYSTEM_TIME5(1),SYSTEM_TIME6(1)
    TYPE(DOMAIN_MAPPING_TYPE), POINTER :: ELEMENTS_MAPPING
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(CONSTRAINT_LAGRANGE_TYPE), POINTER :: LAGRANGE
    TYPE(CONSTRAINT_MATRICES_TYPE), POINTER :: CONSTRAINT_MATRICES
    TYPE(FIELD_TYPE), POINTER :: LAGRANGE_FIELD
 
    CALL ENTERS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_FEM",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      LAGRANGE=>CONSTRAINT_CONDITION%LAGRANGE
      IF(ASSOCIATED(LAGRANGE)) THEN
        LAGRANGE_FIELD=>CONSTRAINT_CONDITION%LAGRANGE%LAGRANGE_FIELD
        IF(ASSOCIATED(LAGRANGE_FIELD)) THEN
          CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
          IF(ASSOCIATED(CONSTRAINT_EQUATIONS)) THEN
            CONSTRAINT_MATRICES=>CONSTRAINT_EQUATIONS%CONSTRAINT_MATRICES
            IF(ASSOCIATED(CONSTRAINT_MATRICES)) THEN
              IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
                CALL CPU_TIMER(USER_CPU,USER_TIME1,ERR,ERROR,*999)
                CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME1,ERR,ERROR,*999)
              ENDIF
!!Do we need to transfer parameter sets???
              !Initialise the matrices and rhs vector
#ifdef TAUPROF
              CALL TAU_STATIC_PHASE_START("CONSTRAINT_MATRICES_VALUES_INITIALISE()")
#endif
              CALL CONSTRAINT_MATRICES_VALUES_INITIALISE(CONSTRAINT_MATRICES,0.0_DP,ERR,ERROR,*999)
#ifdef TAUPROF
              CALL TAU_STATIC_PHASE_STOP("CONSTRAINT_MATRICES_VALUES_INITIALISE()")
#endif
              !Assemble the elements
              !Allocate the element matrices 
#ifdef TAUPROF
              CALL TAU_STATIC_PHASE_START("ConstraintMatrices_ElementInitialise()")
#endif
              CALL ConstraintMatrices_ElementInitialise(CONSTRAINT_MATRICES,ERR,ERROR,*999)
              ELEMENTS_MAPPING=>LAGRANGE_FIELD%DECOMPOSITION%DOMAIN(LAGRANGE_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
                & MAPPINGS%ELEMENTS
#ifdef TAUPROF
              CALL TAU_STATIC_PHASE_STOP("ConstraintMatrices_ElementInitialise()")
#endif
              !Output timing information if required
              IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
                CALL CPU_TIMER(USER_CPU,USER_TIME2,ERR,ERROR,*999)
                CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME2,ERR,ERROR,*999)
                USER_ELAPSED=USER_TIME2(1)-USER_TIME1(1)
                SYSTEM_ELAPSED=SYSTEM_TIME2(1)-SYSTEM_TIME1(1)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for constraint setup and initialisation = ",USER_ELAPSED, &
                  & ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for constraint setup and initialisation = ", &
                  & SYSTEM_ELAPSED,ERR,ERROR,*999)
                ELEMENT_USER_ELAPSED=0.0_SP
                ELEMENT_SYSTEM_ELAPSED=0.0_SP
              ENDIF
              NUMBER_OF_TIMES=0
              !Loop over the internal elements
#ifdef TAUPROF
              CALL TAU_STATIC_PHASE_START("Internal Elements Loop")
#endif
              DO element_idx=ELEMENTS_MAPPING%INTERNAL_START,ELEMENTS_MAPPING%INTERNAL_FINISH
                ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
                NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
                CALL ConstraintMatrices_ElementCalculate(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
                CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
                CALL CONSTRAINT_MATRICES_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
              ENDDO !element_idx                  
#ifdef TAUPROF
              CALL TAU_STATIC_PHASE_STOP("Internal Elements Loop")
#endif
              !Output timing information if required
              IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
                CALL CPU_TIMER(USER_CPU,USER_TIME3,ERR,ERROR,*999)
                CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME3,ERR,ERROR,*999)
                USER_ELAPSED=USER_TIME3(1)-USER_TIME2(1)
                SYSTEM_ELAPSED=SYSTEM_TIME3(1)-SYSTEM_TIME2(1)
                ELEMENT_USER_ELAPSED=USER_ELAPSED
                ELEMENT_SYSTEM_ELAPSED=SYSTEM_ELAPSED
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for internal constraint assembly = ",USER_ELAPSED, &
                  & ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for internal constraint assembly = ",SYSTEM_ELAPSED, &
                  & ERR,ERROR,*999)
              ENDIF
              !Output timing information if required
              IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
                CALL CPU_TIMER(USER_CPU,USER_TIME4,ERR,ERROR,*999)
                CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME4,ERR,ERROR,*999)
                USER_ELAPSED=USER_TIME4(1)-USER_TIME3(1)
                SYSTEM_ELAPSED=SYSTEM_TIME4(1)-SYSTEM_TIME3(1)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for parameter transfer completion = ",USER_ELAPSED, &
                  & ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for parameter transfer completion = ",SYSTEM_ELAPSED, &
                  & ERR,ERROR,*999)              
              ENDIF
              !Loop over the boundary and ghost elements
#ifdef TAUPROF
              CALL TAU_STATIC_PHASE_START("Boundary and Ghost Elements Loop")
#endif
              DO element_idx=ELEMENTS_MAPPING%BOUNDARY_START,ELEMENTS_MAPPING%GHOST_FINISH
                ne=ELEMENTS_MAPPING%DOMAIN_LIST(element_idx)
                NUMBER_OF_TIMES=NUMBER_OF_TIMES+1
                CALL ConstraintMatrices_ElementCalculate(CONSTRAINT_MATRICES,ne,ERR,ERROR,*999)
                CALL CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE(CONSTRAINT_CONDITION,ne,ERR,ERROR,*999)
                CALL CONSTRAINT_MATRICES_ELEMENT_ADD(CONSTRAINT_MATRICES,ERR,ERROR,*999)
              ENDDO !element_idx
#ifdef TAUPROF
              CALL TAU_STATIC_PHASE_STOP("Boundary and Ghost Elements Loop")
#endif
              !Output timing information if required
              IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
                CALL CPU_TIMER(USER_CPU,USER_TIME5,ERR,ERROR,*999)
                CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME5,ERR,ERROR,*999)
                USER_ELAPSED=USER_TIME5(1)-USER_TIME4(1)
                SYSTEM_ELAPSED=SYSTEM_TIME5(1)-SYSTEM_TIME4(1)
                ELEMENT_USER_ELAPSED=ELEMENT_USER_ELAPSED+USER_ELAPSED
                ELEMENT_SYSTEM_ELAPSED=ELEMENT_SYSTEM_ELAPSED+USER_ELAPSED
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"User time for boundary+ghost constraint assembly = ",USER_ELAPSED, &
                  & ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"System time for boundary+ghost constraint assembly = ", &
                  & SYSTEM_ELAPSED,ERR,ERROR,*999)
                IF(NUMBER_OF_TIMES>0) THEN
                  CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element user time for constraint assembly = ", &
                    & ELEMENT_USER_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
                  CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Average element system time for constraint assembly = ", &
                    & ELEMENT_SYSTEM_ELAPSED/NUMBER_OF_TIMES,ERR,ERROR,*999)
                ENDIF
              ENDIF
              !Finalise the element matrices
#ifdef TAUPROF
              CALL TAU_STATIC_PHASE_START("CONSTRAINT_MATRICES_ELEMENT_FINALISE()")
#endif
              CALL CONSTRAINT_MATRICES_ELEMENT_FINALISE(CONSTRAINT_MATRICES,ERR,ERROR,*999)
#ifdef TAUPROF
              CALL TAU_STATIC_PHASE_STOP("CONSTRAINT_MATRICES_ELEMENT_FINALISE()")
#endif
              !Output equations matrices and RHS vector if required
              IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_MATRIX_OUTPUT) THEN
                CALL CONSTRAINT_MATRICES_OUTPUT(GENERAL_OUTPUT_TYPE,CONSTRAINT_MATRICES,ERR,ERROR,*999)
              ENDIF
              !Output timing information if required
              IF(CONSTRAINT_EQUATIONS%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_TIMING_OUTPUT) THEN
                CALL CPU_TIMER(USER_CPU,USER_TIME6,ERR,ERROR,*999)
                CALL CPU_TIMER(SYSTEM_CPU,SYSTEM_TIME6,ERR,ERROR,*999)
                USER_ELAPSED=USER_TIME6(1)-USER_TIME1(1)
                SYSTEM_ELAPSED=SYSTEM_TIME6(1)-SYSTEM_TIME1(1)
                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"***",ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total user time for constraint equations assembly = ",USER_ELAPSED, &
                  & ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Total system time for constraint equations assembly = ", &
                  & SYSTEM_ELAPSED,ERR,ERROR,*999)
                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"***",ERR,ERROR,*999)
              ENDIF
            ELSE
              CALL FLAG_ERROR("Constraint matrices is not associated.",ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Constraint equations is not associated.",ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Constraint condition Lagrange field is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Constraint condition Lagrange is not associated",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_FEM")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_FEM",err,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_FEM")
    RETURN 1
    
  END SUBROUTINE CONSTRAINT_CONDITION_RESIDUAL_EVALUATE_FEM
  
  !
  !================================================================================================================================
  !

  !>Calculates the element stiffness matries for the given element number for a finite element constraint equations.
  SUBROUTINE CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE(constraintCondition,constraintElementNumber,err,error,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: constraintCondition !<A pointer to the constraint condition
    INTEGER(INTG), INTENT(IN) :: constraintElementNumber !<The element number to calcualte
    INTEGER(INTG), INTENT(OUT) :: err !<The error code 
    TYPE(VARYING_STRING), INTENT(OUT) :: error !<The error string
    !Local Variables
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: constraintEquations !<A pointer to the constraint equations
    TYPE(CONSTRAINT_MATRICES_TYPE), POINTER :: constraintMatrices !<A pointer to the constraint matrices
    TYPE(ELEMENT_MATRIX_TYPE), POINTER :: elementMatrix !<A pointer to the constraint element matrix
    INTEGER(INTG) :: constraintMatrixIdx
    TYPE(VARYING_STRING) :: localError
    
#ifdef TAUPROF
    CALL TAU_STATIC_PHASE_START("CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE")
#endif

    CALL ENTERS("CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE",err,error,*999)
    
    IF(ASSOCIATED(constraintCondition)) THEN
      constraintEquations=>constraintCondition%CONSTRAINT_EQUATIONS
      IF(ASSOCIATED(constraintEquations)) THEN
        SELECT CASE(constraintCondition%OPERATOR)
        CASE(CONSTRAINT_CONDITION_FE_INCOMPRESSIBILITY_OPERATOR)
          CALL FLAG_ERROR("Not implemented!",ERR,ERROR,*999)
        CASE DEFAULT
          localError="The constraint condition operator of "//TRIM(NUMBER_TO_VSTRING(constraintCondition%OPERATOR,"*",err,error))// &
            & " is invalid."
          CALL FLAG_ERROR(localError,ERR,ERROR,*999)
        END SELECT
    
        IF(constraintEquations%OUTPUT_TYPE>=CONSTRAINT_EQUATIONS_ELEMENT_MATRIX_OUTPUT) THEN
          constraintMatrices=>constraintEquations%CONSTRAINT_MATRICES
          IF(ASSOCIATED(constraintMatrices)) THEN
            CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Finite element constraint matrices:",err,error,*999)          
            CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Element number = ",constraintElementNumber,err,error,*999)
            CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Number of element matrices = ",constraintMatrices% &
              & NUMBER_OF_CONSTRAINT_MATRICES,err,error,*999)
            DO constraintMatrixIdx=1,constraintMatrices%NUMBER_OF_CONSTRAINT_MATRICES
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"Element matrix : ",constraintMatrixIdx,err,error,*999)
              CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"  Update matrix = ",constraintMatrices%MATRICES(constraintMatrixIdx)%PTR% &
                & UPDATE_MATRIX,err,error,*999)
              IF(constraintMatrices%MATRICES(constraintMatrixIdx)%PTR%UPDATE_MATRIX) THEN
                elementMatrix=>constraintMatrices%MATRICES(constraintMatrixIdx)%PTR%ELEMENT_MATRIX
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"  Number of rows = ",elementMatrix%NUMBER_OF_ROWS,err,error,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"  Number of columns = ",elementMatrix%NUMBER_OF_COLUMNS, &
                  & ERR,error,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"  Maximum number of rows = ",elementMatrix%MAX_NUMBER_OF_ROWS, &
                  & ERR,error,*999)
                CALL WRITE_STRING_VALUE(GENERAL_OUTPUT_TYPE,"  Maximum number of columns = ",elementMatrix% &
                  & MAX_NUMBER_OF_COLUMNS,err,error,*999)
                CALL WRITE_STRING_VECTOR(GENERAL_OUTPUT_TYPE,1,1,elementMatrix%NUMBER_OF_ROWS,8,8,elementMatrix%ROW_DOFS, &
                  & '("  Row dofs     :",8(X,I13))','(16X,8(X,I13))',err,error,*999)
                CALL WRITE_STRING_VECTOR(GENERAL_OUTPUT_TYPE,1,1,elementMatrix%NUMBER_OF_COLUMNS,8,8,elementMatrix% &
                  & COLUMN_DOFS,'("  Column dofs  :",8(X,I13))','(16X,8(X,I13))',err,error,*999)
                CALL WRITE_STRING_MATRIX(GENERAL_OUTPUT_TYPE,1,1,elementMatrix%NUMBER_OF_ROWS,1,1,elementMatrix% &
                  & NUMBER_OF_COLUMNS,8,8,elementMatrix%MATRIX(1:elementMatrix%NUMBER_OF_ROWS,1:elementMatrix% &
                  & NUMBER_OF_COLUMNS),WRITE_STRING_MATRIX_NAME_AND_INDICES,'("  Matrix','(",I2,",:)',' :",8(X,E13.6))', &
                  & '(16X,8(X,E13.6))',err,error,*999)
              ENDIF
            ENDDO !constraintMatrixIdx
          ENDIF
        ENDIF
      ELSE
        CALL FLAG_ERROR("Constraint equations is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF

#ifdef TAUPROF
    CALL TAU_STATIC_PHASE_STOP("CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE")
#endif
       
    CALL EXITS("CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE",err,error)
    CALL EXITS("CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE")
    RETURN 1
    
  END SUBROUTINE CONSTRAINT_CONDITION_FINITE_ELEMENT_CALCULATE

  !
  !================================================================================================================================
  !

  !>Finds and returns in CONSTRAINT_CONDITION a pointer to the constraint condition identified by USER_NUMBER in the given CONSTRAINT. If no constraint condition with that USER_NUMBER exists CONSTRAINT_CONDITION is left nullified.
  SUBROUTINE CONSTRAINT_CONDITION_USER_NUMBER_FIND(USER_NUMBER,REGION,CONSTRAINT_CONDITION,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The user number to find.
    TYPE(REGION_TYPE), POINTER :: REGION !<The region to find the constraint condition in.
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<On return a pointer to the constraint condition with the given user number. If no constraint condition with that user number exists then the pointer is returned as NULL. Must not be associated on entry.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: constraint_condition_idx
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("CONSTRAINT_CONDITION_USER_NUMBER_FIND",ERR,ERROR,*999)

    IF(ASSOCIATED(REGION)) THEN
      IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
        CALL FLAG_ERROR("Constraint condition is already associated.",ERR,ERROR,*999)
      ELSE
        NULLIFY(CONSTRAINT_CONDITION)
        IF(ASSOCIATED(REGION%CONSTRAINT_CONDITIONS)) THEN
          constraint_condition_idx=1
          DO WHILE(constraint_condition_idx<=REGION%CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS.AND. &
            & .NOT.ASSOCIATED(CONSTRAINT_CONDITION))
            IF(REGION%CONSTRAINT_CONDITIONS%CONSTRAINT_CONDITIONS(constraint_condition_idx)%PTR%USER_NUMBER==USER_NUMBER) THEN
              CONSTRAINT_CONDITION=>REGION%CONSTRAINT_CONDITIONS%CONSTRAINT_CONDITIONS(constraint_condition_idx)%PTR
            ELSE
              constraint_condition_idx=constraint_condition_idx+1
            ENDIF
          ENDDO
        ELSE
          LOCAL_ERROR="The constraint conditions on region number "// &
            & TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))//" are not associated."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ENDIF
    ELSE
      CALL FLAG_ERROR("Region is not associated.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("CONSTRAINT_CONDITION_USER_NUMBER_FIND")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITION_USER_NUMBER_FIND",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITION_USER_NUMBER_FIND")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITION_USER_NUMBER_FIND

  !
  !================================================================================================================================
  !

  !>Finalises an constraint conditions and deallocates all memory.
  SUBROUTINE CONSTRAINT_CONDITIONS_FINALISE(CONSTRAINT_CONDITIONS,ERR,ERROR,*) 

    !Argument variables
    TYPE(CONSTRAINT_CONDITIONS_TYPE), POINTER :: CONSTRAINT_CONDITIONS !<A pointer to the constraint conditions to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION
    
    CALL ENTERS("CONSTRAINT_CONDITIONS_FINALISE",ERR,ERROR,*999)
    
    IF(ASSOCIATED(CONSTRAINT_CONDITIONS)) THEN
      DO WHILE(CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS>0)
        CONSTRAINT_CONDITION=>CONSTRAINT_CONDITIONS%CONSTRAINT_CONDITIONS(1)%PTR
        CALL CONSTRAINT_CONDITION_DESTROY(CONSTRAINT_CONDITION,ERR,ERROR,*999)
      ENDDO
      IF(ASSOCIATED(CONSTRAINT_CONDITIONS%CONSTRAINT_CONDITIONS)) DEALLOCATE(CONSTRAINT_CONDITIONS%CONSTRAINT_CONDITIONS)
      DEALLOCATE(CONSTRAINT_CONDITIONS)
    ENDIF
    
    CALL EXITS("CONSTRAINT_CONDITIONS_FINALISE")
    RETURN
999 CALL ERRORS("CONSTRAINT_CONDITIONS_FINALISE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITIONS_FINALISE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITIONS_FINALISE

  !
  !================================================================================================================================
  !
  
  !>Initialises an constraint conditions for an constraint.
  SUBROUTINE CONSTRAINT_CONDITIONS_INITIALISE(REGION,ERR,ERROR,*) 

    !Argument variables
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region to initialise the conditions for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: DUMMY_ERR
    TYPE(VARYING_STRING) :: DUMMY_ERROR,LOCAL_ERROR
     
    CALL ENTERS("CONSTRAINT_CONDITIONS_INITIALISE",ERR,ERROR,*998)

    IF(ASSOCIATED(REGION)) THEN
      IF(ASSOCIATED(REGION%CONSTRAINT_CONDITIONS)) THEN
        LOCAL_ERROR="Constraint conditions is already associated for region number "// &
          & TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))//"."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ELSE
        ALLOCATE(REGION%CONSTRAINT_CONDITIONS,STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate region constraint conditions.",ERR,ERROR,*999)
        REGION%CONSTRAINT_CONDITIONS%CONSTRAINT=>REGION
        REGION%CONSTRAINT_CONDITIONS%NUMBER_OF_CONSTRAINT_CONDITIONS=0
        NULLIFY(REGION%CONSTRAINT_CONDITIONS%CONSTRAINT_CONDITIONS)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Region is not associated.",ERR,ERROR,*998)
    ENDIF
    
    CALL EXITS("CONSTRAINT_CONDITIONS_INITIALISE")
    RETURN
999 CALL CONSTRAINT_CONDITIONS_FINALISE(REGION%CONSTRAINT_CONDITIONS,DUMMY_ERR,DUMMY_ERROR,*998)
998 CALL ERRORS("CONSTRAINT_CONDITIONS_INITIALISE",ERR,ERROR)
    CALL EXITS("CONSTRAINT_CONDITIONS_INITIALISE")
    RETURN 1
  END SUBROUTINE CONSTRAINT_CONDITIONS_INITIALISE

  !
  !================================================================================================================================
  !

END MODULE CONSTRAINT_CONDITIONS_ROUTINES
