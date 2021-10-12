FUNCTION ZTKFK_flight_booksuppl_d.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VALUES) TYPE  ZTKFK_TT_BOOKSUPPL_M
*"----------------------------------------------------------------------
  DELETE ZTKFK_booksuppl_m FROM TABLE @values.

ENDFUNCTION.  "#EC CI_VALPAR
