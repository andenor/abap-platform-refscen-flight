"! API for Saving the Transactional Buffer of the Travel API
"!
FUNCTION ZTKFK_FLIGHT_TRAVEL_SAVE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------
  ZTKFK_cl_flight_legacy=>get_instance( )->save( ).
ENDFUNCTION.
