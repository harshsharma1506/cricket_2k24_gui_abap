*----------------------------------------------------------------------*
***INCLUDE Z_CRICK_SCREEN_FLOW.
*----------------------------------------------------------------------*

CLASS lcl_crick_play DEFINITION.

  PUBLIC SECTION.
    DATA: lo_ui_stat TYPE REF TO lcl_ui.
    METHODS: call_container CHANGING
                              VALUE(c_val) TYPE REF TO cl_gui_custom_container,
      fill_catalog  ,
      call_alv_grid  IMPORTING
                       VALUE(i_grid) TYPE REF TO  cl_gui_alv_grid
                       i_parent_ob   TYPE REF TO cl_gui_custom_container
                     CHANGING
                       c_fieldcat    TYPE lvc_t_fcat
                       ct_tab        TYPE STANDARD TABLE,
      bot_bowls_user_bats,
      user_bowls_bot_bats.
  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA: lv_refresh           TYPE xfeld,
          lv_valid             TYPE xfeld,
          lo_grid              TYPE REF TO cl_gui_alv_grid,
          lv_inning            TYPE i,
          lv_inning_curse      TYPE char1,
          lv_inning_curse1     TYPE char1,
          lt_toolbar_excluding TYPE ui_functions.

ENDCLASS.

CLASS lcl_crick_play IMPLEMENTATION.

  METHOD call_container.
    c_val = NEW cl_gui_custom_container(
        container_name              = 'LV_CONT'
    ).
  ENDMETHOD.

  METHOD fill_catalog.
    g_it_catalog = VALUE #( ( fieldname = 'UNAME'  scrtext_m = 'User'  emphasize = 'C1')
                            ( fieldname = 'INPUT'  scrtext_m = 'Your Turn' edit = 'X' )
                            ( fieldname = 'ACTION'  scrtext_m = 'Action' emphasize = 'C3' )
                            ( fieldname = 'INNING'  scrtext_m = 'Innings' emphasize = 'C3'  )
                            ( fieldname = 'INDIVIDUAL_SCORE'  scrtext_m = 'Ind. score' emphasize = 'C3' )
*                            ( fieldname = 'RUNNING_TOTAL'  scrtext_m = 'Running Total' emphasize = 'C3' )
                            ( fieldname = 'WICKETS_LEFT'  scrtext_m = 'Wickets Left' emphasize = 'C3'  )
                            ( fieldname = 'TARGET'  scrtext_m = 'Target' emphasize = 'C3' ) ).
  ENDMETHOD.


  METHOD call_alv_grid.

    i_grid = NEW cl_gui_alv_grid(
        i_parent          = i_parent_ob
      ).
    lo_grid = i_grid.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    lt_toolbar_excluding = VALUE #( ( i_grid->mc_fc_loc_undo )
                                     ( i_grid->mc_fc_loc_append_row )
                                     ( i_grid->mc_fc_loc_append_row )
                                     ( i_grid->mc_fc_loc_copy_row )
                                     ( i_grid->mc_fc_loc_delete_row )
                                     ( i_grid->mc_fc_loc_insert_row )
                                     ( i_grid->mc_fc_loc_cut ) ).
    i_grid->set_table_for_first_display(
      EXPORTING
        i_save                        = 'X'    " Save Layout
        i_default                     = 'X'    " Default Display Variant
        it_toolbar_excluding          = lt_toolbar_excluding
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

  METHOD user_bowls_bot_bats.
    DATA lv_trg_chk TYPE i.
    IF lo_grid IS BOUND.
      lo_ui_stat = NEW lcl_ui( ).
      lo_ui_stat->random_generator(
        EXPORTING
          i_high = p_range
        IMPORTING
          e_ret  = DATA(lv_bat_bot) ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
      lo_grid->check_changed_data(
        IMPORTING
          e_valid   = lv_valid    " Entries are Consistent
        CHANGING
          c_refresh = lv_refresh    " Character Field of Length 1
      ).
      IF lv_valid IS NOT INITIAL.
        lo_grid->refresh_table_display(
          EXCEPTIONS
            finished       = 1
            OTHERS         = 2
        ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
      SORT g_it_final BY  inning ASCENDING wickets_left DESCENDING .
      IMPORT lv_inning_curse TO lv_inning_curse FROM MEMORY ID 'MAT'.
      IF lv_inning_curse IS NOT INITIAL.
        me->bot_bowls_user_bats( ).
        DATA(lv_stop) = 'X'.
      ENDIF.
      CHECK lv_stop <> 'X'.
      DATA(lv_lines_bowl) = lines( g_it_final ).
      DATA(ls_final_bowl) = g_it_final[ lv_lines_bowl ].
      IF ls_final_bowl-input <> lv_bat_bot.                     " wicket / out scenario
        IF ls_final_bowl-inning  = 1.
          ls_final_bowl-individual_score = ls_final_bowl-individual_score + lv_bat_bot.
          MODIFY g_it_final FROM ls_final_bowl INDEX lv_lines_bowl.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ELSE.
          ls_final_bowl-individual_score = ls_final_bowl-individual_score + lv_bat_bot.
          MODIFY g_it_final FROM ls_final_bowl INDEX lv_lines_bowl.
          TRY.
              DATA(ls_final_bo_pre) = g_it_final[ 1 ].
            CATCH cx_sy_itab_line_not_found.
          ENDTRY.
          IF ls_final_bo_pre-action <> 'Batting'.
            LOOP AT g_it_final INTO DATA(ls_final_chk) WHERE action = 'Batting'.
              IF ls_final_chk-uname = 'Bot'.
                lv_trg_chk = lv_trg_chk +  ls_final_chk-individual_score.
              ENDIF.
            ENDLOOP.
            IF lv_trg_chk > ls_final_chk-target.
              MESSAGE | { ls_final_bowl-uname } has won | TYPE 'I'.
              LEAVE TO SCREEN 0.
            ENDIF.
          ELSE.
            LOOP AT g_it_final INTO ls_final_chk WHERE action = 'Bowling'.
             lv_trg_chk = lv_trg_chk + ls_final_chk-individual_score.
            ENDLOOP.
            IF lv_trg_chk > ls_final_chk-target.
              MESSAGE | { ls_final_bowl-uname } has won | TYPE 'I'.
              LEAVE TO SCREEN 0.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        DATA(lv_lines_bo_wicket) = lines( g_it_final ).
        DATA(ls_final_bo_wick) =  g_it_final[ lv_lines_bo_wicket ].
        ls_final_bo_wick-wickets_left = ls_final_bo_wick-wickets_left - 1.
        IF ls_final_bo_wick-wickets_left = 0 AND ls_final_bo_wick-inning = 1.
          DATA(lv_target) = 0.
          LOOP AT g_it_final INTO ls_final_bo_wick.     " in 7.4 +, you can use select sum ( ) from itab
            lv_target = lv_target + ls_final_bo_wick-individual_score.
            ls_final_bo_wick-target = lv_target.
          ENDLOOP.
          MODIFY g_it_final FROM ls_final_bo_wick INDEX lv_lines_bo_wicket.
          IF  ls_final_bo_wick-action = 'Batting'.
            ls_final_bo_wick-action = 'Bowling'.
          ELSE.
            ls_final_bo_wick-action = 'Batting'.
          ENDIF.
*          CASE ls_final_bo_wick-uname.
*            WHEN p_name.
*              ls_final_bo_wick-uname = 'Bot'.
*            WHEN 'Bot'.
*              ls_final_bo_wick-uname = p_name.
*          ENDCASE.
          CLEAR:  ls_final_bo_wick-individual_score,
                 ls_final_bo_wick-inning,
                 ls_final_bo_wick-wickets_left,
                 ls_final_bo_wick-input.

          ls_final_bo_wick-inning = 2.
          ls_final_bo_wick-wickets_left = p_wick.
          APPEND ls_final_bo_wick TO g_it_final.
          lv_inning_curse = 'X'.
          EXPORT lv_inning_curse FROM lv_inning_curse TO MEMORY ID 'MAT'.
        ELSEIF ls_final_bo_wick-wickets_left = 0 AND ls_final_bo_wick-inning <> 1.
          ASSERT ls_final_bo_wick-target IS NOT INITIAL.
          DATA(lv_target_match) = 0.
          LOOP AT g_it_final INTO ls_final_bo_wick.     " in 7.4 +, you can use select sum ( ) from itab
            lv_target_match = lv_target_match + ls_final_bo_wick-individual_score.
          ENDLOOP.
          IF lv_target_match <= ls_final_bo_wick-target.
            MESSAGE | { ls_final_bo_wick-uname } has lost | TYPE 'I'.
            LEAVE TO SCREEN 0.
          ELSEIF lv_target_match > ls_final_bo_wick-target.
            MESSAGE | { ls_final_bo_wick-uname } has won | TYPE 'I'.
            LEAVE TO SCREEN 0.
          ENDIF.

        ELSE.
          CLEAR: ls_final_bo_wick-individual_score, lv_bat_bot.
          APPEND ls_final_bo_wick TO g_it_final.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD bot_bowls_user_bats.
    DATA lv_trg_chk TYPE i.
    IF lo_grid IS BOUND.
      lo_ui_stat = NEW lcl_ui( ).
      lo_ui_stat->random_generator(
        EXPORTING
          i_high = p_range
        IMPORTING
          e_ret  = DATA(lv_bowl_bot) ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
      lo_grid->check_changed_data(
        IMPORTING
          e_valid   = lv_valid    " Entries are Consistent
        CHANGING
          c_refresh = lv_refresh    " Character Field of Length 1
      ).
      IF lv_valid IS NOT INITIAL.
        lo_grid->refresh_table_display(
          EXCEPTIONS
            finished       = 1
            OTHERS         = 2
        ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
      IMPORT lv_inning_curse1 TO lv_inning_curse1 FROM MEMORY ID 'VKO'.
      IF lv_inning_curse1 IS NOT INITIAL.
        me->user_bowls_bot_bats( ).
        DATA(lv_stop) = 'X'.
      ENDIF.
      CHECK lv_stop <> 'X'.
      SORT g_it_final BY  inning ASCENDING wickets_left DESCENDING .
      DATA(lv_lines_bat) = lines( g_it_final ).
      DATA(ls_final_bat) = g_it_final[ lv_lines_bat ].
      IF ls_final_bat-input <> lv_bowl_bot.                     " wicket / out scenario
        IF ls_final_bat-inning  = 1.
          ls_final_bat-individual_score = ls_final_bat-individual_score + ls_final_bat-input.
          MODIFY g_it_final FROM ls_final_bat INDEX lv_lines_bat.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ELSE.
          ls_final_bat-individual_score = ls_final_bat-individual_score + ls_final_bat-input.
          MODIFY g_it_final FROM ls_final_bat INDEX lv_lines_bat.
          TRY.
              DATA(ls_final_ba_pre) = g_it_final[ 1 ].
            CATCH cx_sy_itab_line_not_found.
          ENDTRY.
          IF ls_final_ba_pre-action <> 'Batting'.
            LOOP AT g_it_final INTO DATA(ls_final_chk) WHERE action = 'Batting'.
              lv_trg_chk = lv_trg_chk + ls_final_chk-individual_score.   " in 7.5 + you can use '+= operator
            ENDLOOP.
            IF lv_trg_chk > ls_final_chk-target.
              MESSAGE | { ls_final_bat-uname } has won | TYPE 'I'.
              LEAVE TO SCREEN 0.
            ENDIF.
          ELSE.
            LOOP AT g_it_final INTO ls_final_chk WHERE action = 'Bowling'.
               lv_trg_chk = lv_trg_chk + ls_final_chk-individual_score.
            ENDLOOP.
            IF lv_trg_chk > ls_final_chk-target.
              MESSAGE | { ls_final_bat-uname } has lost | TYPE 'I'.
              LEAVE TO SCREEN 0.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        DATA(lv_lines_ba_wicket) = lines( g_it_final ).
        DATA(ls_final_ba_wick) =  g_it_final[ lv_lines_ba_wicket ].
        ls_final_ba_wick-wickets_left = ls_final_ba_wick-wickets_left - 1.
        IF ls_final_ba_wick-wickets_left = 0 AND ls_final_ba_wick-inning = 1.
          DATA(lv_target) = 0.
          LOOP AT g_it_final INTO ls_final_ba_wick.     " in 7.4 +, you can use select sum ( ) from itab
            lv_target = lv_target + ls_final_ba_wick-individual_score.
            ls_final_ba_wick-target = lv_target.
          ENDLOOP.
          MODIFY g_it_final FROM ls_final_ba_wick INDEX lv_lines_ba_wicket.
          IF  ls_final_ba_wick-action = 'Batting'.
            ls_final_ba_wick-action = 'Bowling'.
          ELSE.
            ls_final_ba_wick-action = 'Batting'.
          ENDIF.
*          CASE ls_final_ba_wick-uname.
*            WHEN p_name.
*              ls_final_ba_wick-uname = 'Bot'.
*            WHEN 'Bot'.
*              ls_final_ba_wick-uname = p_name.
*          ENDCASE.
          CLEAR: ls_final_ba_wick-individual_score,
                 ls_final_ba_wick-inning,
                 ls_final_ba_wick-wickets_left,
                 ls_final_ba_wick-input.
*          ls_final_ba_wick-action = 'Bowling'.
          ls_final_ba_wick-inning = 2.
          ls_final_ba_wick-wickets_left = p_wick.
          APPEND ls_final_ba_wick TO g_it_final.
          lv_inning_curse1 = 'X'.
          EXPORT lv_inning_curse1 FROM lv_inning_curse1 TO MEMORY ID 'VKO'.
        ELSEIF ls_final_ba_wick-wickets_left = 0 AND ls_final_ba_wick-inning <> 1.
          ASSERT ls_final_ba_wick-target IS NOT INITIAL.
          DATA(lv_target_match1) = 0.
          LOOP AT g_it_final INTO ls_final_ba_wick.     " in 7.4 +, you can use select sum ( ) from itab
            lv_target_match1 = lv_target_match1 + ls_final_ba_wick-individual_score.
          ENDLOOP.
          IF lv_target_match1 <= ls_final_ba_wick-target.
            MESSAGE | { ls_final_ba_wick-uname } has lost | TYPE 'I'.
            LEAVE TO SCREEN 0.
          ELSEIF lv_target_match1 > ls_final_ba_wick-target.
            MESSAGE | { ls_final_ba_wick-uname } has won | TYPE 'I'.
            LEAVE TO SCREEN 0.
          ENDIF.
        ELSE.
          CLEAR: ls_final_ba_wick-individual_score, lv_bowl_bot.
          APPEND ls_final_ba_wick TO g_it_final.
        ENDIF.
      ENDIF.
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
    WHEN '&SAVE'.
      IF ( g_user_ch IS NOT INITIAL AND g_act = 'Batting' ) OR
         ( g_bot_ch IS NOT INITIAL AND g_act = 'Bowling' ).
        lo_stat->bot_bowls_user_bats( ).
      ELSEIF ( g_user_ch IS NOT INITIAL AND g_act = 'Bowling' ) OR
        ( g_bot_ch IS NOT INITIAL AND g_act = 'Batting' ).
        lo_stat->user_bowls_bot_bats( ).
      ENDIF.
  ENDCASE.
ENDMODULE.
