FUNCTION /TKFK/flight_booksuppl_u.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VALUES) TYPE  /TKFK/TT_BOOKSUPPL_M
*"----------------------------------------------------------------------
  UPDATE /TKFK/booksuppl_m FROM TABLE @values.

ENDFUNCTION.  "#EC CI_VALPAR
