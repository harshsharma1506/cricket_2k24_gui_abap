*&---------------------------------------------------------------------*
*&  Include           Z_CRICK_DATA
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_final,
         uname            TYPE usr02-bname,
         input            TYPE i,
         action           TYPE string,
         inning           TYPE i,
         individual_score TYPE i,
         running_total    TYPE i,
         wickets_left     TYPE i,
         target           TYPE i,
       END OF ty_final.

DATA: g_result     TYPE boole_d,
      g_user_ch    TYPE char1,
      g_bot_ch     TYPE char1,
      go_alv       TYPE  REF TO cl_gui_alv_grid,
      go_cont      TYPE REF TO cl_gui_custom_container,
      g_it_catalog TYPE lvc_t_fcat,
      g_it_final   TYPE STANDARD TABLE OF ty_final,
      g_act        TYPE string.
