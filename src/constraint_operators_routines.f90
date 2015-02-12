!> \file
!> \author Chris Bradley
!> \brief This module contains all constraint conditions operators routines.
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
MODULE CONSTRAINT_OPERATORS_ROUTINES

  USE BASE_ROUTINES
  USE BASIS_ROUTINES
  USE CONSTANTS
  USE FIELD_ROUTINES
  USE INPUT_OUTPUT
  USE CONSTRAINT_CONDITIONS_CONSTANTS
  USE CONSTRAINT_EQUATIONS_ROUTINES
  USE CONSTRAINT_MAPPING_ROUTINES
  USE CONSTRAINT_MATRICES_ROUTINES
  USE ISO_VARYING_STRING
  USE KINDS
  USE MATRIX_VECTOR
  USE STRINGS
  USE TIMER
  USE TYPES

  IMPLICIT NONE

  !Module types

  !Module variables

  !Constraints

  PUBLIC FE_INCOMPRESSIBILITY_FINITE_ELEMENT_JACOBIAN_EVALUATE
  PUBLIC FE_INCOMPRESSIBILITY_FINITE_ELEMENT_RESIDUAL_EVALUATE
  
CONTAINS

  !
  !================================================================================================================================
  !

  !>Evaluates the element Jacobian matrix for the given element number for a finite elasticity incompressibility constraint condition.
  SUBROUTINE FE_INCOMPRESSIBILITY_FINITE_ELEMENT_JACOBIAN_EVALUATE(CONSTRAINT_CONDITION,ELEMENT_NUMBER,ERR,ERROR,*)
    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition
    INTEGER(INTG), INTENT(IN) :: ELEMENT_NUMBER !<The element number to evaluate the Jacobian for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    INTEGER(INTG) :: DEPENDENT_VARIABLE_TYPE,LAGRANGE_VARIABLE_TYPE
    INTEGER(INTG) :: ng,ns,nhs,mh,ms,mhs,mi
    INTEGER(INTG) :: MESH_COMPONENT_NUMBER,NUMBER_OF_COMPONENTS,NUMBER_OF_XI,NUMBER_OF_ELEMENT_PARAMETERS(3)
    REAL(DP) :: PHINS_JGW,DPHIDZ(64,3)
    REAL(DP) :: JGW,SUM
    TYPE(BASIS_TYPE), POINTER :: GEOMETRIC_BASIS,DEPENDENT_BASIS,LAGRANGE_BASIS
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(CONSTRAINT_MAPPING_TYPE), POINTER :: CONSTRAINT_MAPPING
    TYPE(CONSTRAINT_MATRICES_TYPE), POINTER :: CONSTRAINT_MATRICES
    TYPE(CONSTRAINT_MATRICES_NONLINEAR_TYPE), POINTER :: NONLINEAR_MATRICES
    TYPE(CONSTRAINT_JACOBIAN_TYPE), POINTER :: JACOBIAN_MATRIX
    TYPE(FIELD_INTERPOLATED_POINT_TYPE), POINTER :: GEOMETRIC_INTERPOLATED_POINT,DEPENDENT_INTERPOLATED_POINT
    TYPE(FIELD_INTERPOLATED_POINT_METRICS_TYPE), POINTER :: GEOMETRIC_INTERPOLATED_POINT_METRICS, &
      & DEPENDENT_INTERPOLATED_POINT_METRICS
    TYPE(FIELD_INTERPOLATION_PARAMETERS_TYPE), POINTER :: GEOMETRIC_INTERPOLATION_PARAMETERS, &
      & DEPENDENT_INTERPOLATION_PARAMETERS,LAGRANGE_INTERPOLATION_PARAMETERS
    TYPE(FIELD_TYPE), POINTER :: GEOMETRIC_FIELD,DEPENDENT_FIELD,LAGRANGE_FIELD
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: DEPENDENT_VARIABLE,LAGRANGE_VARIABLE
    TYPE(QUADRATURE_SCHEME_TYPE), POINTER :: LAGRANGE_QUADRATURE_SCHEME
    TYPE(QUADRATURE_SCHEME_PTR_TYPE) :: QUADRATURE_SCHEMES(3)

    CALL ENTERS("FE_INCOMPRESSIBILITY_FINITE_ELEMENT_JACOBIAN_EVALUATE",ERR,ERROR,*999)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
      IF(ASSOCIATED(CONSTRAINT_EQUATIONS)) THEN
        SELECT CASE(CONSTRAINT_CONDITION%METHOD)
        CASE(CONSTRAINT_CONDITION_LAGRANGE_MULTIPLIERS_METHOD)
          CONSTRAINT_MATRICES=>CONSTRAINT_EQUATIONS%CONSTRAINT_MATRICES
          NONLINEAR_MATRICES=>CONSTRAINT_MATRICES%NONLINEAR_MATRICES
          JACOBIAN_MATRIX=>NONLINEAR_MATRICES%JACOBIANS(1)%PTR
          IF(JACOBIAN_MATRIX%UPDATE_JACOBIAN) THEN
            CONSTRAINT_MAPPING=>CONSTRAINT_EQUATIONS%CONSTRAINT_MAPPING
            GEOMETRIC_FIELD=>CONSTRAINT_EQUATIONS%INTERPOLATION%GEOMETRIC_FIELD
            DEPENDENT_FIELD=>CONSTRAINT_EQUATIONS%INTERPOLATION%DEPENDENT_FIELD
            LAGRANGE_FIELD=>CONSTRAINT_EQUATIONS%INTERPOLATION%LAGRANGE_FIELD
            GEOMETRIC_BASIS=>GEOMETRIC_FIELD%DECOMPOSITION%DOMAIN(GEOMETRIC_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
              & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
            DEPENDENT_BASIS=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(DEPENDENT_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
              & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
            DEPENDENT_VARIABLE=>CONSTRAINT_MAPPING%NONLINEAR_MAPPING%VAR_TO_CONSTRAINT_JACOBIAN_MAP%VARIABLE
            DEPENDENT_VARIABLE_TYPE=DEPENDENT_VARIABLE%VARIABLE_TYPE
            LAGRANGE_VARIABLE=>CONSTRAINT_MAPPING%LAGRANGE_VARIABLE
            LAGRANGE_VARIABLE_TYPE=LAGRANGE_VARIABLE%VARIABLE_TYPE
            GEOMETRIC_INTERPOLATION_PARAMETERS=>CONSTRAINT_EQUATIONS%INTERPOLATION% &
              & GEOMETRIC_INTERP_PARAMETERS(FIELD_U_VARIABLE_TYPE)%PTR
            DEPENDENT_INTERPOLATION_PARAMETERS=>CONSTRAINT_EQUATIONS%INTERPOLATION% &
              & DEPENDENT_INTERP_PARAMETERS(DEPENDENT_VARIABLE_TYPE)%PTR
            LAGRANGE_INTERPOLATION_PARAMETERS=>CONSTRAINT_EQUATIONS%INTERPOLATION% &
              & DEPENDENT_INTERP_PARAMETERS(LAGRANGE_VARIABLE_TYPE)%PTR

            CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER, &
              & GEOMETRIC_INTERPOLATION_PARAMETERS,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER, &
              & DEPENDENT_INTERPOLATION_PARAMETERS,ERR,ERROR,*999)

            !Point interpolation pointer
            GEOMETRIC_INTERPOLATED_POINT=>CONSTRAINT_EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR
            GEOMETRIC_INTERPOLATED_POINT_METRICS=>CONSTRAINT_EQUATIONS%INTERPOLATION% &
              & GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR
            DEPENDENT_INTERPOLATED_POINT=>CONSTRAINT_EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(DEPENDENT_VARIABLE_TYPE)%PTR
            DEPENDENT_INTERPOLATED_POINT_METRICS=>CONSTRAINT_EQUATIONS%INTERPOLATION% &
              & DEPENDENT_INTERP_POINT_METRICS(DEPENDENT_VARIABLE_TYPE)%PTR

            NUMBER_OF_COMPONENTS=DEPENDENT_VARIABLE%NUMBER_OF_COMPONENTS
            NUMBER_OF_XI=DEPENDENT_BASIS%NUMBER_OF_XI
            !Loop over geometric dependent basis functions.
            DO mh=1,NUMBER_OF_COMPONENTS
              MESH_COMPONENT_NUMBER=DEPENDENT_VARIABLE%COMPONENTS(mh)%MESH_COMPONENT_NUMBER
              DEPENDENT_BASIS=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT_NUMBER)%PTR% &
                & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
              QUADRATURE_SCHEMES(mh)%PTR=>DEPENDENT_BASIS%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
            ENDDO !mh

            MESH_COMPONENT_NUMBER=LAGRANGE_VARIABLE%COMPONENTS(1)%MESH_COMPONENT_NUMBER
            LAGRANGE_BASIS=>LAGRANGE_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT_NUMBER)%PTR% &
              & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
            LAGRANGE_QUADRATURE_SCHEME=>LAGRANGE_BASIS%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR

            !Loop over all Gauss points 
            DO ng=1,LAGRANGE_QUADRATURE_SCHEME%NUMBER_OF_GAUSS
              CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng, &
                & GEOMETRIC_INTERPOLATED_POINT,ERR,ERROR,*999)
              CALL FIELD_INTERPOLATED_POINT_METRICS_CALCULATE(GEOMETRIC_BASIS%NUMBER_OF_XI,GEOMETRIC_INTERPOLATED_POINT_METRICS, &
                & ERR,ERROR,*999)
              CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng, &
                & DEPENDENT_INTERPOLATED_POINT,ERR,ERROR,*999)
              CALL FIELD_INTERPOLATED_POINT_METRICS_CALCULATE(DEPENDENT_BASIS%NUMBER_OF_XI,DEPENDENT_INTERPOLATED_POINT_METRICS, &
                & ERR,ERROR,*999)

              !Loop over geometric dependent basis functions.
              DO mh=1,NUMBER_OF_COMPONENTS
                DO ms=1,NUMBER_OF_ELEMENT_PARAMETERS(mh)
                  SUM=0.0_DP
                  DO mi=1,NUMBER_OF_XI
                    SUM=SUM+QUADRATURE_SCHEMES(mh)%PTR%GAUSS_BASIS_FNS(ms,PARTIAL_DERIVATIVE_FIRST_DERIVATIVE_MAP(mi),ng)* &
                      & DEPENDENT_INTERPOLATED_POINT_METRICS%DXI_DX(mi,mh)
                  ENDDO !mi
                  DPHIDZ(ms,mh)=SUM
                ENDDO !ms
              ENDDO !mh
              
              JGW=DEPENDENT_INTERPOLATED_POINT_METRICS%JACOBIAN*LAGRANGE_QUADRATURE_SCHEME%GAUSS_WEIGHTS(ng)

              !Put this if statement outside of gauss point loop?
              IF(LAGRANGE_VARIABLE%COMPONENTS(1)%INTERPOLATION_TYPE==FIELD_NODE_BASED_INTERPOLATION) THEN !node based
                nhs=0
                DO ns=1,LAGRANGE_BASIS%NUMBER_OF_ELEMENT_PARAMETERS
                  nhs=nhs+1
                  PHINS_JGW=LAGRANGE_QUADRATURE_SCHEME%GAUSS_BASIS_FNS(ns,NO_PART_DERIV,ng)*JGW
                  mhs=0
                  DO mh=1,NUMBER_OF_COMPONENTS
                    DO ms=1,NUMBER_OF_ELEMENT_PARAMETERS(mh)
                      JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX(mhs,nhs)=JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX(mhs,nhs)+ &
                        & DPHIDZ(ms,mh)*PHINS_JGW
                    ENDDO !ms
                  ENDDO !mh
                ENDDO !ns    
              ELSEIF(DEPENDENT_VARIABLE%COMPONENTS(1)%INTERPOLATION_TYPE==FIELD_ELEMENT_BASED_INTERPOLATION) THEN !element based
                nhs=1
                mhs=0
                DO mh=1,NUMBER_OF_COMPONENTS
                  DO ms=1,NUMBER_OF_ELEMENT_PARAMETERS(mh)
                    JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX(mhs,nhs)=JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX(mhs,nhs)+ &
                      & DPHIDZ(ms,mh)*JGW
                  ENDDO !ms
                ENDDO !mh
              ENDIF
            ENDDO !ng

            !Scale factor adjustment
            IF(LAGRANGE_FIELD%SCALINGS%SCALING_TYPE/=FIELD_NO_SCALING) THEN
              CALL FIELD_INTERPOLATION_PARAMETERS_SCALE_FACTORS_ELEM_GET(ELEMENT_NUMBER, &
                & DEPENDENT_INTERPOLATION_PARAMETERS,ERR,ERROR,*999) !Is this necessary?
              IF(DEPENDENT_VARIABLE%COMPONENTS(1)%INTERPOLATION_TYPE==FIELD_NODE_BASED_INTERPOLATION) THEN !node based
                CALL FIELD_INTERPOLATION_PARAMETERS_SCALE_FACTORS_ELEM_GET(ELEMENT_NUMBER, &
                  & LAGRANGE_INTERPOLATION_PARAMETERS,ERR,ERROR,*999) 
                nhs=0
                DO ns=1,LAGRANGE_BASIS%NUMBER_OF_ELEMENT_PARAMETERS
                  nhs=nhs+1
                  mhs=0
                  DO mh=1,NUMBER_OF_COMPONENTS
                    DO ms=1,NUMBER_OF_ELEMENT_PARAMETERS(mh)
                      mhs=mhs+1
                      JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX(mhs,nhs)=JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX(mhs,nhs)* &
                        & DEPENDENT_INTERPOLATION_PARAMETERS%SCALE_FACTORS(ms,mh)* &
                        & LAGRANGE_INTERPOLATION_PARAMETERS%SCALE_FACTORS(ns,1)
                    ENDDO !ms
                  ENDDO !mh
                ENDDO !ns    
              ELSEIF(DEPENDENT_VARIABLE%COMPONENTS(1)%INTERPOLATION_TYPE==FIELD_ELEMENT_BASED_INTERPOLATION) THEN !element based
                nhs=1
                mhs=0
                DO mh=1,NUMBER_OF_COMPONENTS
                  DO ms=1,NUMBER_OF_ELEMENT_PARAMETERS(mh)
                    mhs=mhs+1
                    JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX(mhs,nhs)=JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX(mhs,nhs)* &
                      & DEPENDENT_INTERPOLATION_PARAMETERS%SCALE_FACTORS(ms,mh)
                  ENDDO !ms
                ENDDO !mh
              ENDIF
            ENDIF
          ENDIF
        CASE DEFAULT
          LOCAL_ERROR="Constraint condition method "//TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%METHOD,"*",err,error))// &
            & " is not valid."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ELSE
        CALL FLAG_ERROR("Constraint condition equations is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("FE_INCOMPRESSIBILITY_FINITE_ELEMENT_JACOBIAN_EVALUATE")
    RETURN
999 CALL ERRORS("FE_INCOMPRESSIBILITY_FINITE_ELEMENT_JACOBIAN_EVALUATE",ERR,ERROR)
    CALL EXITS("FE_INCOMPRESSIBILITY_FINITE_ELEMENT_JACOBIAN_EVALUATE")
    RETURN 1
  END SUBROUTINE FE_INCOMPRESSIBILITY_FINITE_ELEMENT_JACOBIAN_EVALUATE

  !
  !================================================================================================================================
  !

  !>Evaluates the residual for a finite element finite elasticity incompressibility constraint condition.
  SUBROUTINE FE_INCOMPRESSIBILITY_FINITE_ELEMENT_RESIDUAL_EVALUATE(CONSTRAINT_CONDITION,ELEMENT_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONSTRAINT_CONDITION_TYPE), POINTER :: CONSTRAINT_CONDITION !<A pointer to the constraint condition
    INTEGER(INTG), INTENT(IN) :: ELEMENT_NUMBER !<The element number to calculate
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(BASIS_TYPE), POINTER :: GEOMETRIC_BASIS,DEPENDENT_BASIS,LAGRANGE_BASIS
    TYPE(CONSTRAINT_EQUATIONS_TYPE), POINTER :: CONSTRAINT_EQUATIONS
    TYPE(CONSTRAINT_MAPPING_TYPE), POINTER :: CONSTRAINT_MAPPING
    TYPE(CONSTRAINT_MATRICES_TYPE), POINTER :: CONSTRAINT_MATRICES
    TYPE(CONSTRAINT_MATRICES_NONLINEAR_TYPE), POINTER :: NONLINEAR_MATRICES
    TYPE(FIELD_TYPE), POINTER :: GEOMETRIC_FIELD,DEPENDENT_FIELD,LAGRANGE_FIELD
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: DEPENDENT_VARIABLE,LAGRANGE_VARIABLE
    TYPE(QUADRATURE_SCHEME_TYPE), POINTER :: LAGRANGE_QUADRATURE_SCHEME
    TYPE(FIELD_INTERPOLATION_PARAMETERS_TYPE), POINTER :: GEOMETRIC_INTERPOLATION_PARAMETERS,DEPENDENT_INTERPOLATION_PARAMETERS, &
      & LAGRANGE_INTERPOLATION_PARAMETERS
    TYPE(FIELD_INTERPOLATED_POINT_TYPE), POINTER :: GEOMETRIC_INTERPOLATED_POINT,DEPENDENT_INTERPOLATED_POINT, &
      & LAGRANGE_INTERPOLATED_POINT
    TYPE(FIELD_INTERPOLATED_POINT_METRICS_TYPE), POINTER :: GEOMETRIC_INTERPOLATED_POINT_METRICS, &
      & DEPENDENT_INTERPOLATED_POINT_METRICS
    TYPE(DECOMPOSITION_TYPE), POINTER :: DECOMPOSITION
    INTEGER(INTG) :: parameter_idx,gauss_idx,element_dof_idx
    INTEGER(INTG) :: DEPENDENT_VARIABLE_TYPE,LAGRANGE_VARIABLE_TYPE
    INTEGER(INTG) :: MESH_COMPONENT_NUMBER
    REAL(DP) :: RGW
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FE_INCOMPRESSIBILITY_FINITE_ELEMENT_RESIDUAL_EVALUATE",ERR,ERROR,*999)

    NULLIFY(LAGRANGE_BASIS)
    NULLIFY(CONSTRAINT_EQUATIONS,CONSTRAINT_MAPPING,CONSTRAINT_MATRICES,NONLINEAR_MATRICES)
    NULLIFY(DEPENDENT_FIELD,GEOMETRIC_FIELD,LAGRANGE_FIELD)
    NULLIFY(DEPENDENT_VARIABLE,LAGRANGE_VARIABLE)
    NULLIFY(LAGRANGE_QUADRATURE_SCHEME)
    NULLIFY(GEOMETRIC_INTERPOLATION_PARAMETERS,DEPENDENT_INTERPOLATION_PARAMETERS,LAGRANGE_INTERPOLATION_PARAMETERS)
    NULLIFY(GEOMETRIC_INTERPOLATED_POINT,DEPENDENT_INTERPOLATED_POINT,LAGRANGE_INTERPOLATED_POINT)
    NULLIFY(GEOMETRIC_INTERPOLATED_POINT_METRICS,DEPENDENT_INTERPOLATED_POINT_METRICS)
    NULLIFY(DECOMPOSITION)

    IF(ASSOCIATED(CONSTRAINT_CONDITION)) THEN
      CONSTRAINT_EQUATIONS=>CONSTRAINT_CONDITION%CONSTRAINT_EQUATIONS
      IF(ASSOCIATED(CONSTRAINT_EQUATIONS)) THEN
        SELECT CASE(CONSTRAINT_CONDITION%METHOD)
        CASE(CONSTRAINT_CONDITION_LAGRANGE_MULTIPLIERS_METHOD)
          CONSTRAINT_MATRICES=>CONSTRAINT_EQUATIONS%CONSTRAINT_MATRICES
          NONLINEAR_MATRICES=>CONSTRAINT_MATRICES%NONLINEAR_MATRICES
          CONSTRAINT_MAPPING=>CONSTRAINT_EQUATIONS%CONSTRAINT_MAPPING
          GEOMETRIC_FIELD=>CONSTRAINT_EQUATIONS%INTERPOLATION%GEOMETRIC_FIELD
          DEPENDENT_FIELD=>CONSTRAINT_EQUATIONS%INTERPOLATION%DEPENDENT_FIELD
          LAGRANGE_FIELD=>CONSTRAINT_EQUATIONS%INTERPOLATION%LAGRANGE_FIELD
          GEOMETRIC_BASIS=>GEOMETRIC_FIELD%DECOMPOSITION%DOMAIN(GEOMETRIC_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
            & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
          DEPENDENT_BASIS=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(DEPENDENT_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
            & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
          MESH_COMPONENT_NUMBER=LAGRANGE_VARIABLE%COMPONENTS(1)%MESH_COMPONENT_NUMBER
          LAGRANGE_BASIS=>LAGRANGE_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT_NUMBER)%PTR% &
            & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
          LAGRANGE_QUADRATURE_SCHEME=>LAGRANGE_BASIS%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
          DEPENDENT_VARIABLE=>CONSTRAINT_MAPPING%NONLINEAR_MAPPING%VAR_TO_CONSTRAINT_JACOBIAN_MAP%VARIABLE
          DEPENDENT_VARIABLE_TYPE=DEPENDENT_VARIABLE%VARIABLE_TYPE
          LAGRANGE_VARIABLE=>CONSTRAINT_EQUATIONS%CONSTRAINT_MAPPING%LAGRANGE_VARIABLE
          LAGRANGE_VARIABLE_TYPE=LAGRANGE_VARIABLE%VARIABLE_TYPE
          GEOMETRIC_INTERPOLATION_PARAMETERS=>CONSTRAINT_EQUATIONS%INTERPOLATION% &
            & GEOMETRIC_INTERP_PARAMETERS(FIELD_U_VARIABLE_TYPE)%PTR
          DEPENDENT_INTERPOLATION_PARAMETERS=>CONSTRAINT_EQUATIONS%INTERPOLATION% &
            & DEPENDENT_INTERP_PARAMETERS(DEPENDENT_VARIABLE_TYPE)%PTR
          LAGRANGE_INTERPOLATION_PARAMETERS=>CONSTRAINT_EQUATIONS%INTERPOLATION% &
            & DEPENDENT_INTERP_PARAMETERS(LAGRANGE_VARIABLE_TYPE)%PTR

          CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER, &
            & GEOMETRIC_INTERPOLATION_PARAMETERS,ERR,ERROR,*999)
          CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER, &
            & DEPENDENT_INTERPOLATION_PARAMETERS,ERR,ERROR,*999)

          !Point interpolation pointer
          GEOMETRIC_INTERPOLATED_POINT=>CONSTRAINT_EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR
          GEOMETRIC_INTERPOLATED_POINT_METRICS=>CONSTRAINT_EQUATIONS%INTERPOLATION% &
            & GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR
          DEPENDENT_INTERPOLATED_POINT=>CONSTRAINT_EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(DEPENDENT_VARIABLE_TYPE)%PTR
          DEPENDENT_INTERPOLATED_POINT_METRICS=>CONSTRAINT_EQUATIONS%INTERPOLATION% &
            & DEPENDENT_INTERP_POINT_METRICS(DEPENDENT_VARIABLE_TYPE)%PTR

          !Loop over gauss points and add residuals
          DO gauss_idx=1,LAGRANGE_QUADRATURE_SCHEME%NUMBER_OF_GAUSS
            CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,gauss_idx, &
              & GEOMETRIC_INTERPOLATED_POINT,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATED_POINT_METRICS_CALCULATE(GEOMETRIC_BASIS%NUMBER_OF_XI,GEOMETRIC_INTERPOLATED_POINT_METRICS, &
              & ERR,ERROR,*999)
            CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,gauss_idx, &
              & DEPENDENT_INTERPOLATED_POINT,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATED_POINT_METRICS_CALCULATE(DEPENDENT_BASIS%NUMBER_OF_XI,DEPENDENT_INTERPOLATED_POINT_METRICS, &
              & ERR,ERROR,*999)
            
            RGW=(DEPENDENT_INTERPOLATED_POINT_METRICS%JACOBIAN-GEOMETRIC_INTERPOLATED_POINT_METRICS%JACOBIAN)* &
              & LAGRANGE_QUADRATURE_SCHEME%GAUSS_WEIGHTS(gauss_idx)

            ! Put this if outside of Gauss loop?
            IF(LAGRANGE_VARIABLE%COMPONENTS(1)%INTERPOLATION_TYPE==FIELD_NODE_BASED_INTERPOLATION) THEN !node based
              element_dof_idx=0
              DO parameter_idx=1,LAGRANGE_BASIS%NUMBER_OF_ELEMENT_PARAMETERS
                element_dof_idx=element_dof_idx+1 
                NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR(element_dof_idx)= &
                  & NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR(element_dof_idx)+ &
                  & LAGRANGE_QUADRATURE_SCHEME%GAUSS_BASIS_FNS(parameter_idx,NO_PART_DERIV,gauss_idx)*RGW
              ENDDO
            ELSEIF(LAGRANGE_VARIABLE%COMPONENTS(1)%INTERPOLATION_TYPE==FIELD_ELEMENT_BASED_INTERPOLATION) THEN !element based
              element_dof_idx=1 
              NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR(element_dof_idx)= &
                & NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR(element_dof_idx)+RGW
            ENDIF
          ENDDO !gauss_idx

          !Scale factor adjustment
          IF(LAGRANGE_FIELD%SCALINGS%SCALING_TYPE/=FIELD_NO_SCALING) THEN
            CALL FIELD_INTERPOLATION_PARAMETERS_SCALE_FACTORS_ELEM_GET(ELEMENT_NUMBER, &
              & LAGRANGE_INTERPOLATION_PARAMETERS,ERR,ERROR,*999) 
            element_dof_idx=0          
            IF(LAGRANGE_VARIABLE%COMPONENTS(1)%INTERPOLATION_TYPE==FIELD_NODE_BASED_INTERPOLATION) THEN !node based
              DO parameter_idx=1,LAGRANGE_BASIS%NUMBER_OF_ELEMENT_PARAMETERS
                element_dof_idx=element_dof_idx+1 
                NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR(element_dof_idx)= &
                  & NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR(element_dof_idx)* &
                  & LAGRANGE_INTERPOLATION_PARAMETERS%SCALE_FACTORS(parameter_idx,1)
              ENDDO
            ENDIF
          ENDIF
        CASE DEFAULT
          LOCAL_ERROR="Constraint condition method "//TRIM(NUMBER_TO_VSTRING(CONSTRAINT_CONDITION%METHOD,"*",err,error))// &
            & " is not valid."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ELSE
        CALL FLAG_ERROR("Constraint condition equations is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Constraint condition is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("FE_INCOMPRESSIBILITY_FINITE_ELEMENT_RESIDUAL_EVALUATE")
    RETURN

999 CALL ERRORS("FE_INCOMPRESSIBILITY_FINITE_ELEMENT_RESIDUAL_EVALUATE",ERR,ERROR)
    CALL EXITS("FE_INCOMPRESSIBILITY_FINITE_ELEMENT_RESIDUAL_EVALUATE")
    RETURN 1
  END SUBROUTINE FE_INCOMPRESSIBILITY_FINITE_ELEMENT_RESIDUAL_EVALUATE

  !
  !================================================================================================================================
  !

END MODULE CONSTRAINT_OPERATORS_ROUTINES
