"! API for Saving the Transactional Buffer of the Travel API
"!
FUNCTION ZTK_FLIGHT_TRAVEL_SAVE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------
  ZTK_cl_flight_legacy=>get_instance( )->save( ).
ENDFUNCTION.
