*&---------------------------------------------------------------------*
*& Report  Z_CRICK_2024
*&---------------------------------------------------------------------*
*& Author - HXS0615 
*&---------------------------------------------------------------------*
REPORT z_crick_2024.

INCLUDE: z_crick_data,
         z_crick_sel,
         z_crick_cls.

AT SELECTION-SCREEN.
  DATA(lo_ui) = NEW lcl_ui( ).
   lo_ui->val_range( i_range =  p_range ).
   lo_ui->val_wicket( i_wck = p_wick  ).
   lo_ui->do_toss(
     EXPORTING
       i_rge    = p_tinp
     IMPORTING
       e_val    = data(lv_bot_val)
       e_result = g_result
   ).
   lo_ui->toss_finalizer(
     EXPORTING
       i_result      = g_result
     IMPORTING
       e_user_choice = g_user_ch
       e_bot_choice  = g_bot_ch
   ).

START-OF-SELECTION.
CALL SCREEN 500.
