FUNCTION ZTK_flight_booksuppl_c.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VALUES) TYPE  ZTK_TT_BOOKSUPPL_M
*"----------------------------------------------------------------------
  INSERT ZTK_booksuppl_m FROM TABLE @values.

ENDFUNCTION. "#EC CI_VALPAR
