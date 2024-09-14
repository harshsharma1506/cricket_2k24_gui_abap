*----------------------------------------------------------------------*
***INCLUDE Z_CRICK_SCREEN_FLOW.
*----------------------------------------------------------------------*

CLASS lcl_crick_play DEFINITION.

  PUBLIC SECTION.
    METHODS: call_container RETURNING
                              VALUE(r_val) TYPE REF TO cl_gui_custom_container,
      fill_catalog   IMPORTING
                       i_table_name TYPE char30
                     EXPORTING
                       e_fieldcat   TYPE lvc_t_fcat,
      call_alv_grid  IMPORTING
                       i_parent_ob TYPE REF TO cl_gui_alv_grid.
  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_crick_play IMPLEMENTATION.

  METHOD call_container.
    r_val = NEW cl_gui_custom_container(
        container_name              = 'LV_CONT'
    ).
  ENDMETHOD.

  METHOD fill_catalog.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
   EXPORTING
     I_PROGRAM_NAME               = sy-repid
     I_INTERNAL_TABNAME           = i_table_name
    CHANGING
      ct_fieldcat                  = e_fieldcat
   EXCEPTIONS
     INCONSISTENT_INTERFACE       = 1
     PROGRAM_ERROR                = 2
     OTHERS                       = 3
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  ENDMETHOD.

  METHOD call_alv_grid.

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
