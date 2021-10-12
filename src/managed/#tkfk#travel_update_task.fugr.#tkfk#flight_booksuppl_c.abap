FUNCTION /TKFK/flight_booksuppl_c.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VALUES) TYPE  /TKFK/TT_BOOKSUPPL_M
*"----------------------------------------------------------------------
  INSERT /TKFK/booksuppl_m FROM TABLE @values.

ENDFUNCTION. "#EC CI_VALPAR
