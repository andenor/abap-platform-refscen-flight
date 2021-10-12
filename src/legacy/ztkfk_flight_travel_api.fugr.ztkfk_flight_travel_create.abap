"! <h1>API for Creating a Travel</h1>
"!
"! <p>
"! Function module to create a single Travel instance with the possibility to create related Bookings and
"! Booking Supplements in the same call (so called deep-create).
"! </p>
"!
"! <p>
"! The <em>travel_id</em> will be provided be the API but the IDs of Booking <em>booking_id</em> as well
"! of Booking Supplements <em>booking_id</em> and <em>booking_supplement_id</em>.
"! </p>
"!
"!
"! @parameter is_travel             | Travel Data
"! @parameter it_booking            | Table of predefined Booking Key <em>booking_id</em> and Booking Data
"! @parameter it_booking_supplement | Table of predefined Booking Supplement Key <em>booking_id</em>, <em>booking_supplement_id</em> and Booking Supplement Data
"! @parameter es_travel             | Evaluated Travel Data like ZTKFK_TRAVEL
"! @parameter et_booking            | Table of evaluated Bookings like ZTKFK_BOOKING
"! @parameter et_booking_supplement | Table of evaluated Booking Supplements like ZTKFK_BOOK_SUPPL
"! @parameter et_messages           | Table of occurred messages
"!
FUNCTION ZTKFK_flight_travel_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_TRAVEL) TYPE  ZTKFK_S_TRAVEL_IN
*"     REFERENCE(IT_BOOKING) TYPE  ZTKFK_T_BOOKING_IN OPTIONAL
*"     REFERENCE(IT_BOOKING_SUPPLEMENT) TYPE
*"        ZTKFK_T_BOOKING_SUPPLEMENT_IN OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_TRAVEL) TYPE  ZTKFK_TRAVEL
*"     REFERENCE(ET_BOOKING) TYPE  ZTKFK_T_BOOKING
*"     REFERENCE(ET_BOOKING_SUPPLEMENT) TYPE  ZTKFK_T_BOOKING_SUPPLEMENT
*"     REFERENCE(ET_MESSAGES) TYPE  ZTKFK_T_MESSAGE
*"----------------------------------------------------------------------


  CLEAR es_travel.
  CLEAR et_booking.
  CLEAR et_booking_supplement.
  CLEAR et_messages.

  ZTKFK_cl_flight_legacy=>get_instance( )->create_travel( EXPORTING is_travel             = is_travel
                                                                   it_booking            = it_booking
                                                                   it_booking_supplement = it_booking_supplement
                                                         IMPORTING es_travel             = es_travel
                                                                   et_booking            = et_booking
                                                                   et_booking_supplement = et_booking_supplement
                                                                   et_messages           = DATA(lt_messages) ).

  ZTKFK_cl_flight_legacy=>get_instance( )->convert_messages( EXPORTING it_messages = lt_messages
                                                            IMPORTING et_messages = et_messages ).
ENDFUNCTION.
