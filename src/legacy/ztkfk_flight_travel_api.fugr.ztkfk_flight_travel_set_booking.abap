"! API for Setting a Travel to <em>booked</em>.
"!
"! @parameter iv_travel_id          | Travel ID
"! @parameter et_messages           | Table of occurred messages
"!
FUNCTION ZTKFK_flight_travel_set_booking.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_TRAVEL_ID) TYPE  ZTKFK_TRAVEL-TRAVEL_ID
*"  EXPORTING
*"     REFERENCE(ET_MESSAGES) TYPE  ZTKFK_T_MESSAGE
*"----------------------------------------------------------------------
  CLEAR et_messages.

  ZTKFK_cl_flight_legacy=>get_instance( )->set_status_to_booked( EXPORTING iv_travel_id = iv_travel_id
                                                                IMPORTING et_messages  = DATA(lt_messages) ).

  ZTKFK_cl_flight_legacy=>get_instance( )->convert_messages( EXPORTING it_messages  = lt_messages
                                                            IMPORTING et_messages  = et_messages ).
ENDFUNCTION.
