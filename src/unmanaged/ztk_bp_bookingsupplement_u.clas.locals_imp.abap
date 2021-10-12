CLASS lhc_bookingsupplement DEFINITION
  INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES tt_bookingsupplement_failed   TYPE TABLE FOR FAILED    ZTK_i_bookingsupplement_u.
    TYPES tt_bookingsupplement_reported TYPE TABLE FOR REPORTED  ZTK_i_bookingsupplement_u.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE bookingsupplement.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE bookingsupplement.

    METHODS read FOR READ
      IMPORTING keys FOR READ bookingsupplement RESULT result.

    METHODS rba_Booking FOR READ
      IMPORTING keys_rba FOR READ bookingsupplement\_Booking FULL result_requested RESULT result LINK association_links.

    METHODS rba_Travel FOR READ
      IMPORTING keys_rba FOR READ bookingsupplement\_Travel FULL result_requested RESULT result LINK association_links.

    METHODS map_messages
      IMPORTING
        cid                   TYPE string OPTIONAL
        travel_id             TYPE ZTK_travel_id OPTIONAL
        booking_id            TYPE ZTK_booking_id OPTIONAL
        booking_supplement_id TYPE ZTK_booking_supplement_id OPTIONAL
        messages              TYPE ZTK_t_message
      EXPORTING
        failed_added          TYPE abap_bool
      CHANGING
        failed                TYPE tt_bookingsupplement_failed
        reported              TYPE tt_bookingsupplement_reported.
ENDCLASS.

CLASS lhc_bookingsupplement IMPLEMENTATION.


**********************************************************************
*
* Implements the UPDATE operation for a set of booking supplements
*
**********************************************************************
  METHOD update.
    DATA: messages         TYPE ZTK_t_message,
          book_supplements TYPE ZTK_book_suppl.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<bookingsupplement>).
      book_supplements = CORRESPONDING   #( <bookingsupplement> MAPPING FROM ENTITY ).

      CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel              = VALUE ZTK_s_travel_in( travel_id = <bookingsupplement>-travelid )
          is_travelx             = VALUE ZTK_s_travel_inx( travel_id = <bookingsupplement>-travelid )
          it_booking_supplement  = VALUE ZTK_t_booking_supplement_in( ( CORRESPONDING #( book_supplements ) ) )
          it_booking_supplementx = VALUE ZTK_t_booking_supplement_inx( (
                                            booking_supplement_id = <bookingsupplement>-bookingsupplementid
                                            action_code           = ZTK_if_flight_legacy=>action_code-update
                                            booking_id            = <bookingsupplement>-bookingid
                                            _intx                 = CORRESPONDING #( <bookingsupplement> MAPPING FROM ENTITY )
                                          ) )
        IMPORTING
          et_messages            = messages.

      map_messages(
        EXPORTING
          cid                   = <bookingsupplement>-%cid_ref
          travel_id             = <bookingsupplement>-travelid
          booking_id            = <bookingsupplement>-bookingid
          booking_supplement_id = <bookingsupplement>-bookingsupplementid
          messages              = messages
        CHANGING
            failed              = failed-bookingsupplement
            reported            = reported-bookingsupplement ).

    ENDLOOP.
  ENDMETHOD.


**********************************************************************
*
* Implements the DELETE operation for a set of booking supplements
*
**********************************************************************
  METHOD delete.
    DATA: messages TYPE ZTK_t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<bookingsupplement>).

      CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel              = VALUE ZTK_s_travel_in( travel_id = <bookingsupplement>-travelid )
          is_travelx             = VALUE ZTK_s_travel_inx( travel_id = <bookingsupplement>-travelid )
          it_booking             = VALUE ZTK_t_booking_in( ( booking_id = <bookingsupplement>-bookingid ) )
          it_bookingx            = VALUE ZTK_t_booking_inx( ( booking_id = <bookingsupplement>-bookingid ) )
          it_booking_supplement  = VALUE ZTK_t_booking_supplement_in( (  booking_supplement_id = <bookingsupplement>-bookingSupplementid
                                                                          booking_id            = <bookingsupplement>-BookingID ) )
          it_booking_supplementx = VALUE ZTK_t_booking_supplement_inx( ( booking_supplement_id = <bookingsupplement>-bookingsupplementid
                                                                          booking_id            = <bookingsupplement>-bookingid
                                                                          action_code           = ZTK_if_flight_legacy=>action_code-delete ) )
        IMPORTING
          et_messages            = messages.

      map_messages(
       EXPORTING
         cid                   = <bookingsupplement>-%cid_ref
         travel_id             = <bookingsupplement>-travelid
         booking_id            = <bookingsupplement>-bookingid
         booking_supplement_id = <bookingsupplement>-bookingsupplementid
         messages              = messages
       CHANGING
         failed                = failed-bookingsupplement
         reported              = reported-bookingsupplement ).

    ENDLOOP.
  ENDMETHOD.


**********************************************************************
*
* Implements the READ operation for a set of booking supplements
*
**********************************************************************
  METHOD read.

    DATA: booksuppls_out TYPE ZTK_t_booking_supplement,
          messages       TYPE ZTK_t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<booksuppl_by_travel>)
                               GROUP BY <booksuppl_by_travel>-TravelID.

      CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id          = <booksuppl_by_travel>-travelid
        IMPORTING
          et_booking_supplement = booksuppls_out
          et_messages           = messages.


      map_messages(
       EXPORTING
         travel_id             = <booksuppl_by_travel>-travelid
         booking_id            = <booksuppl_by_travel>-bookingid
         booking_supplement_id = <booksuppl_by_travel>-bookingsupplementid
         messages              = messages
       IMPORTING
         failed_added          = DATA(failed_added)
       CHANGING
         failed                = failed-bookingsupplement
         reported              = reported-bookingsupplement ).

      IF failed_added = abap_false.

        LOOP AT GROUP <booksuppl_by_travel> ASSIGNING FIELD-SYMBOL(<bookingsupplement>)
                                       GROUP BY <bookingsupplement>-%tky.

          READ TABLE booksuppls_out INTO DATA(bookingsuppl) WITH KEY  travel_id             = <bookingsupplement>-%key-TravelID
                                                                      booking_id            = <bookingsupplement>-%key-BookingID
                                                                      booking_supplement_id = <bookingsupplement>-%key-BookingSupplementID.
          IF sy-subrc = 0 .
            "fill result parameter.  Ignoring the flags as the data is already available.
            INSERT CORRESPONDING #( bookingsuppl MAPPING TO ENTITY ) INTO TABLE result.

          ELSE.
            "BookingSupplementID not found
            INSERT
              VALUE #( travelid           = <bookingsupplement>-TravelID
                       bookingid          = <bookingsupplement>-BookingID
                       bookingsupplementid = <bookingsupplement>-BookingSupplementID
                       %fail-cause = if_abap_behv=>cause-not_found )
              INTO TABLE failed-bookingsupplement.
          ENDIF.
        ENDLOOP.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.


**********************************************************************
*
* Read Booking by association
*
**********************************************************************
  METHOD rba_Booking.
    DATA: booking_out TYPE ZTK_t_booking,
          travel      LIKE LINE OF result,
          messages    TYPE ZTK_t_message.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<booksuppl_by_travel>)
                                   GROUP BY <booksuppl_by_travel>-TravelID.

      CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <booksuppl_by_travel>-%key-TravelID
        IMPORTING
          et_booking   = booking_out
          et_messages  = messages.

      map_messages(
        EXPORTING
          travel_id             = <booksuppl_by_travel>-travelid
          booking_id            = <booksuppl_by_travel>-bookingid
          booking_supplement_id = <booksuppl_by_travel>-bookingsupplementid
          messages              = messages
        IMPORTING
          failed_added      = DATA(failed_added)
        CHANGING
          failed                = failed-bookingsupplement
          reported              = reported-bookingsupplement
      ).

      IF failed_added = abap_false.

        LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<booking>) USING KEY entity WHERE TravelID = <booksuppl_by_travel>-TravelID.
          INSERT VALUE #( source-%tky = <booking>-%tky
                          target-%tky = CORRESPONDING #( <booking>-%tky ) )
            INTO TABLE association_links.

          IF result_requested = abap_true.
            DATA(booking) = booking_out[ travel_id = <booking>-TravelID  booking_id = <booking>-BookingID ].
            INSERT CORRESPONDING #( booking MAPPING TO ENTITY ) INTO TABLE result.
          ENDIF.
        ENDLOOP.

      ENDIF.

    ENDLOOP.


    SORT association_links BY source ASCENDING.
    DELETE ADJACENT DUPLICATES FROM association_links COMPARING ALL FIELDS.

    SORT result BY %tky ASCENDING.
    DELETE ADJACENT DUPLICATES FROM result COMPARING ALL FIELDS.
  ENDMETHOD.


**********************************************************************
*
* Read travel by association
*
**********************************************************************
  METHOD rba_travel.
    DATA: travel_out TYPE ZTK_travel,
          travel     LIKE LINE OF result,
          messages   TYPE ZTK_t_message.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<booksuppl_by_travel>)
                                   GROUP BY <booksuppl_by_travel>-TravelID.

      CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <booksuppl_by_travel>-%key-TravelID
        IMPORTING
          es_travel    = travel_out
          et_messages  = messages.

      map_messages(
        EXPORTING
          travel_id             = <booksuppl_by_travel>-travelid
          booking_id            = <booksuppl_by_travel>-bookingid
          booking_supplement_id = <booksuppl_by_travel>-bookingsupplementid
          messages              = messages
        IMPORTING
          failed_added      = DATA(failed_added)
        CHANGING
          failed                = failed-bookingsupplement
          reported              = reported-bookingsupplement
      ).

      IF failed_added = abap_false.

        LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<travel>) USING KEY entity WHERE TravelID = <booksuppl_by_travel>-TravelID.
          INSERT VALUE #( source-%tky     = <travel>-%tky
                          target-travelid = travel_out-travel_id )
          INTO TABLE association_links.

          IF result_requested = abap_true.
            INSERT CORRESPONDING #( travel_out MAPPING TO ENTITY ) INTO TABLE result.
          ENDIF.
        ENDLOOP.

      ENDIF.

    ENDLOOP.


    SORT association_links BY source ASCENDING.
    DELETE ADJACENT DUPLICATES FROM association_links COMPARING ALL FIELDS.

    SORT result BY %tky ASCENDING.
    DELETE ADJACENT DUPLICATES FROM result COMPARING ALL FIELDS.
  ENDMETHOD.


  METHOD map_messages.
    failed_added = abap_false.
    LOOP AT messages INTO DATA(message).
      IF message-msgty = 'E' OR message-msgty = 'A'.
        APPEND VALUE #( %cid                  = cid
                        travelid              = travel_id
                        bookingid             = booking_id
                        bookingsupplementid   = booking_supplement_id
                        %fail-cause           = ZTK_cl_travel_auxiliary=>get_cause_from_message(
                                                  msgid = message-msgid
                                                  msgno = message-msgno
                                                ) )
            TO failed.
        failed_added = abap_true.
      ENDIF.

      APPEND VALUE #( %msg                = new_message(
                                               id       = message-msgid
                                               number   = message-msgno
                                               severity = if_abap_behv_message=>severity-error
                                               v1       = message-msgv1
                                               v2       = message-msgv2
                                               v3       = message-msgv3
                                               v4       = message-msgv4 )
                      %key-TravelID       = travel_id
                      %cid                = cid
                      TravelID            = travel_id
                      BookingID           = booking_id
                      bookingsupplementid = booking_supplement_id )
        TO reported.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
