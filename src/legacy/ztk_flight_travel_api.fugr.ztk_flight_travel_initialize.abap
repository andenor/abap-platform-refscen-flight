"! API for Initializing the Transactional Buffer of the Travel API
"!
FUNCTION ZTK_FLIGHT_TRAVEL_INITIALIZE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------
  ZTK_cl_flight_legacy=>get_instance( )->initialize( ).
ENDFUNCTION.
