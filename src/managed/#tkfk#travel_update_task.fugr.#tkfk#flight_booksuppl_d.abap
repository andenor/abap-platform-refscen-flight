FUNCTION /TKFK/flight_booksuppl_d.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VALUES) TYPE  /TKFK/TT_BOOKSUPPL_M
*"----------------------------------------------------------------------
  DELETE /TKFK/booksuppl_m FROM TABLE @values.

ENDFUNCTION.  "#EC CI_VALPAR
