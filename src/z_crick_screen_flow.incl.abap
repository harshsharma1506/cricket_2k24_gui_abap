*----------------------------------------------------------------------*
***INCLUDE Z_CRICK_SCREEN_FLOW.
*----------------------------------------------------------------------*

CLASS lcl_crick_play DEFINITION.

  PUBLIC SECTION.
    METHODS: call_container CHANGING
                              VALUE(c_val) TYPE REF TO cl_gui_custom_container,
      fill_catalog  ,
      call_alv_grid  IMPORTING
                       VALUE(i_grid) TYPE REF TO  cl_gui_alv_grid
                       i_parent_ob   TYPE REF TO cl_gui_custom_container
                     CHANGING
                       c_fieldcat    TYPE lvc_t_fcat
                       ct_tab        TYPE STANDARD TABLE.
  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_crick_play IMPLEMENTATION.

  METHOD call_container.
    c_val = NEW cl_gui_custom_container(
        container_name              = 'LV_CONT'
    ).
  ENDMETHOD.

  METHOD fill_catalog.
    g_it_catalog = VALUE #( ( fieldname = 'UNAME'  scrtext_m = 'User' )
                            ( fieldname = 'INPUT'  scrtext_m = 'Your Turn' edit = 'X' )
                            ( fieldname = 'ACTION'  scrtext_m = 'Action' )
                            ( fieldname = 'INNING'  scrtext_m = 'Innings' )
                            ( fieldname = 'INDIVIDUAL_SCORE'  scrtext_m = 'Ind. score' )
                            ( fieldname = 'RUNNING_TOTAL'  scrtext_m = 'Running Total' )
                            ( fieldname = 'WICKETS_LEFT'  scrtext_m = 'Wickets Left' )
                            ( fieldname = 'TARGET'  scrtext_m = 'Target' ) ).
  ENDMETHOD.

  METHOD call_alv_grid.

    i_grid = NEW cl_gui_alv_grid(
        i_parent          = i_parent_ob
      ).

    i_grid->set_table_for_first_display(
      EXPORTING
        i_save                        = 'X'    " Save Layout
        i_default                     = 'X'    " Default Display Variant
      CHANGING
        it_outtab                     = ct_tab   " Output Table
        it_fieldcatalog               = c_fieldcat    " Field Catalog
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
  SET PF-STATUS 'Z_CRICKET'.
  SET TITLEBAR 'Cricket 2024 GUI'.
  DATA(lo_stat) = NEW lcl_crick_play( ).
  lo_stat->fill_catalog( ).

  lo_stat->call_container( CHANGING c_val = go_cont ).

  lo_stat->call_alv_grid(
    EXPORTING
      i_grid      = go_alv
      i_parent_ob = go_cont
    CHANGING
      c_fieldcat  = g_it_catalog
      ct_tab      = g_it_final
  ).
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0500 INPUT.
  CASE sy-ucomm.
    WHEN '&BACK'.
      LEAVE TO SCREEN 0.
    WHEN '&CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
