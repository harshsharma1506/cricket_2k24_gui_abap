*&---------------------------------------------------------------------*
*&  Include           Z_CRICK_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_name  TYPE usr02-bname OBLIGATORY,
            p_range TYPE i OBLIGATORY,
            p_wick  TYPE i OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS: p_rad1 RADIOBUTTON GROUP rad1,
            p_rad2 RADIOBUTTON GROUP rad1.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN: BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
PARAMETERS: p_tinp TYPE i OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b3.
