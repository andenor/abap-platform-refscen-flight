FUNCTION ZTKFK_flight_booksuppl_c.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VALUES) TYPE  ZTKFK_TT_BOOKSUPPL_M
*"----------------------------------------------------------------------
  INSERT ZTKFK_booksuppl_m FROM TABLE @values.

ENDFUNCTION. "#EC CI_VALPAR
