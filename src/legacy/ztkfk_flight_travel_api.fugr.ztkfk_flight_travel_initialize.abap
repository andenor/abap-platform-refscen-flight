"! API for Initializing the Transactional Buffer of the Travel API
"!
FUNCTION ZTKFK_FLIGHT_TRAVEL_INITIALIZE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------
  ZTKFK_cl_flight_legacy=>get_instance( )->initialize( ).
ENDFUNCTION.
