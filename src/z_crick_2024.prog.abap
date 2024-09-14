*&---------------------------------------------------------------------*
*& Report  Z_CRICK_2024
*&---------------------------------------------------------------------*
*& Author - HXS0615
*&---------------------------------------------------------------------*
REPORT z_crick_2024.

INCLUDE: z_crick_data,        "data declaration
         z_crick_sel,         "selection screen
         z_crick_cls,         "classes
         z_crick_screen_flow. "screen flow and other classes

AT SELECTION-SCREEN.
  DATA(lo_ui) = NEW lcl_ui( ).
  lo_ui->val_range( i_range =  p_range ).   "6 or 10
  lo_ui->val_wicket( i_wck = p_wick  ).     " max 10 wickets
  lo_ui->do_toss(                           "toss
    EXPORTING
      i_rge    = p_range
    IMPORTING
      e_val    = DATA(lv_bot_val)
      e_result = g_result
  ).
  lo_ui->toss_finalizer(                   "decision making
    EXPORTING
      i_result      = g_result
    IMPORTING
      e_user_choice = g_user_ch
      e_bot_choice  = g_bot_ch
  ).



START-OF-SELECTION.
  IF g_user_ch IS NOT INITIAL.
    g_it_final = VALUE #( ( UNAME = p_name action = g_user_ch inning = 1 ) ).
  ELSE.
    g_it_final = VALUE #( ( UNAME = 'Bot' action = g_bot_ch inning = 1 ) ).
  ENDIF.
  CALL SCREEN 500.
