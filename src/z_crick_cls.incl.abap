*&---------------------------------------------------------------------*
*&  Include           Z_CRICK_CLS
*&---------------------------------------------------------------------*
CLASS lcl_ui DEFINITION.
  PUBLIC SECTION.
    METHODS:
      val_range    IMPORTING
                     i_range TYPE i,
      val_wicket    IMPORTING
                      i_wck TYPE i,
      random_generator IMPORTING
                         i_high TYPE i
                       EXPORTING
                         e_ret  TYPE i,
      do_toss        IMPORTING
                       i_rge    TYPE i
                     EXPORTING
                       e_val    TYPE i
                       e_result TYPE boole_d,
      toss_finalizer IMPORTING
                       i_result      TYPE boole_d
                     EXPORTING
                       e_user_choice TYPE char1
                       e_bot_choice  TYPE char1.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS lcl_ui IMPLEMENTATION.

  METHOD val_range.
    IF i_range = 6 OR i_range = 10.
      "do nothing
    ELSE.
      MESSAGE 'enter either 6 or 10' TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD val_wicket.
    IF i_wck > 10.
      MESSAGE 'there are only 10 wickets max in cricket !' TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD random_generator.
    cl_abap_random=>create(
        seed = CONV i( sy-uzeit )
    )->intinrange(
      EXPORTING
        low            = 1    " lower bound of interval
        high           = i_high    " upper bound of interval
      RECEIVING
        value          = e_ret    " random number's value
    ).
  ENDMETHOD.

  METHOD do_toss.               "e_result = abap_true means user has won , bot has lost.
    me->random_generator(
      EXPORTING
        i_high = i_rge
      IMPORTING
        e_ret  = e_val
    ).
    IF ( e_val + p_tinp ) MOD 2 = 0 AND
       p_rad1 = abap_true.
      e_result = abap_true.
    ELSEIF ( e_val + p_tinp ) MOD 2 <> 0 AND
      p_rad2 = abap_true.
      e_result = abap_true.
    ELSE.
      CLEAR e_result.
    ENDIF.
  ENDMETHOD.

  METHOD toss_finalizer.
    IF i_result <> abap_true.     " 1 is batting , 2 is bowling
      me->random_generator(
        EXPORTING
          i_high = 2
        IMPORTING
          e_ret  = DATA(lv_return)
      ).
      DATA(lv_str) = | You have lost, bot chose to { lv_return } |.
      REPLACE FIRST OCCURRENCE OF '1' IN lv_str WITH 'bat'.
      REPLACE FIRST OCCURRENCE OF '2' IN lv_str WITH 'bowl'.
      MESSAGE lv_str TYPE 'I'.
      e_bot_choice = CONV #( lv_return ).
    ELSE.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = text-005
          text_question  = text-004
          text_button_1  = text-006
          text_button_2  = text-007
        IMPORTING
          answer         = e_user_choice
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.

      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
