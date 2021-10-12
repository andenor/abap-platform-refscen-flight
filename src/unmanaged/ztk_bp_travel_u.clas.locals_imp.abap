CLASS lhc_travel DEFINITION
   INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    TYPES tt_travel_failed    TYPE TABLE FOR FAILED   ZTK_i_travel_u.
    TYPES tt_travel_reported  TYPE TABLE FOR REPORTED ZTK_i_travel_u.
    TYPES tt_booking_failed   TYPE TABLE FOR FAILED   ZTK_i_booking_u.
    TYPES tt_booking_reported TYPE TABLE FOR REPORTED ZTK_i_booking_u.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE travel.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE travel.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE travel.

    METHODS read FOR READ
      IMPORTING keys FOR READ travel RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK travel.

    METHODS rba_Booking FOR READ
      IMPORTING keys_rba FOR READ travel\_Booking FULL result_requested RESULT result LINK association_links.

    METHODS cba_Booking FOR MODIFY
      IMPORTING entities_cba FOR CREATE travel\_Booking.

    METHODS set_status_booked FOR MODIFY
      IMPORTING keys FOR ACTION travel~set_status_booked RESULT result.

    METHODS map_messages
      IMPORTING
        cid          TYPE string         OPTIONAL
        travel_id    TYPE ZTK_travel_id OPTIONAL
        messages     TYPE ZTK_t_message
      EXPORTING
        failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_travel_failed
        reported     TYPE tt_travel_reported.

    METHODS map_messages_assoc_to_booking
      IMPORTING
        cid          TYPE string          OPTIONAL
        travel_id    TYPE ZTK_travel_id  OPTIONAL
        booking_id   TYPE ZTK_booking_id OPTIONAL
        is_dependend TYPE abap_bool       DEFAULT  abap_false
        messages     TYPE ZTK_t_message
      EXPORTING
        failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_booking_failed
        reported     TYPE tt_booking_reported.
ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

********************************************************************************
*
* Implements the dynamic action handling for travel instances
*
********************************************************************************
  METHOD get_instance_features.
    READ ENTITIES OF ZTK_I_Travel_U IN LOCAL MODE
      ENTITY Travel
        FIELDS ( TravelID Status )
        WITH CORRESPONDING #( keys )
    RESULT DATA(travel_read_results)
    FAILED failed.

    result = VALUE #(
      FOR travel_read_result IN travel_read_results (
        %tky                                = travel_read_result-%tky
        %features-%action-set_status_booked = COND #( WHEN travel_read_result-Status = 'B'
                                                      THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
        %assoc-_Booking                     = COND #( WHEN travel_read_result-Status = 'B' OR travel_read_result-Status = 'X'
                                                      THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
      ) ).
  ENDMETHOD.


********************************************************************************
*
* Implements global authorization check
*
********************************************************************************
  METHOD get_global_authorizations.
  ENDMETHOD.


**********************************************************************
*
* Create travel instances
*
**********************************************************************
  METHOD create.
    DATA: messages   TYPE ZTK_t_message,
          travel_in  TYPE ZTK_travel,
          travel_out TYPE ZTK_travel.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_create>).

      travel_in = CORRESPONDING #( <travel_create> MAPPING FROM ENTITY USING CONTROL ).

      CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_CREATE'
        EXPORTING
          is_travel   = CORRESPONDING ZTK_s_travel_in( travel_in )
        IMPORTING
          es_travel   = travel_out
          et_messages = messages.

      map_messages(
          EXPORTING
            cid       = <travel_create>-%cid
            messages  = messages
          IMPORTING
            failed_added = DATA(failed_added)
          CHANGING
            failed    = failed-travel
            reported  = reported-travel
        ).

      IF failed_added = abap_false.
        INSERT VALUE #(
            %cid     = <travel_create>-%cid
            travelid = travel_out-travel_id )
          INTO TABLE mapped-travel.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


**********************************************************************
*
* Update data of existing travel instances
*
**********************************************************************
  METHOD update.
    DATA: messages TYPE ZTK_t_message,
          travel   TYPE ZTK_travel,
          travelx  TYPE ZTK_s_travel_inx. "refers to x structure (> BAPIs)

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_update>).

      travel = CORRESPONDING #( <travel_update> MAPPING FROM ENTITY ).

      travelx-travel_id = <travel_update>-TravelID.
      travelx-_intx     = CORRESPONDING #( <travel_update> MAPPING FROM ENTITY ).

      CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = CORRESPONDING ZTK_s_travel_in( travel )
          is_travelx  = travelx
        IMPORTING
          et_messages = messages.

      map_messages(
          EXPORTING
            cid       = <travel_update>-%cid_ref
            travel_id = <travel_update>-travelid
            messages  = messages
          CHANGING
            failed    = failed-travel
            reported  = reported-travel
        ).

    ENDLOOP.
  ENDMETHOD.


**********************************************************************
*
* Delete of travel instances
*
**********************************************************************
  METHOD delete.
    DATA: messages TYPE ZTK_t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<travel_delete>).

      CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_DELETE'
        EXPORTING
          iv_travel_id = <travel_delete>-travelid
        IMPORTING
          et_messages  = messages.

      map_messages(
          EXPORTING
            cid       = <travel_delete>-%cid_ref
            travel_id = <travel_delete>-travelid
            messages  = messages
          CHANGING
            failed    = failed-travel
            reported  = reported-travel
        ).

    ENDLOOP.
  ENDMETHOD.


**********************************************************************
*
* Read travel data from buffer
*
**********************************************************************
  METHOD read.
    DATA: travel_out TYPE ZTK_travel,
          messages   TYPE ZTK_t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<travel_to_read>) GROUP BY <travel_to_read>-%tky.

      CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <travel_to_read>-travelid
        IMPORTING
          es_travel    = travel_out
          et_messages  = messages.

      map_messages(
          EXPORTING
            travel_id        = <travel_to_read>-TravelID
            messages         = messages
          IMPORTING
            failed_added = DATA(failed_added)
          CHANGING
            failed           = failed-travel
            reported         = reported-travel
        ).

      IF failed_added = abap_false.
        INSERT CORRESPONDING #( travel_out MAPPING TO ENTITY ) INTO TABLE result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


**********************************************************************
*
* Implements the locking logic
*
**********************************************************************
  METHOD lock.
    TRY.
        "Instantiate lock object
        DATA(lock) = cl_abap_lock_object_factory=>get_instance( iv_name = 'ZTK_ETRAVEL' ).
      CATCH cx_abap_lock_failure INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<travel>).
      TRY.
          "enqueue travel instance
          lock->enqueue(
              it_parameter  = VALUE #( (  name = 'TRAVEL_ID' value = REF #( <travel>-travelid ) ) )
          ).
          "if foreign lock exists
        CATCH cx_abap_foreign_lock INTO DATA(foreign_lock).
          map_messages(
           EXPORTING
                travel_id = <travel>-TravelID
                messages  =  VALUE #( (
                                           msgid = 'ZTK_CM_FLIGHT_LEGAC'
                                           msgty = 'E'
                                           msgno = '032'
                                           msgv1 = <travel>-travelid
                                           msgv2 = foreign_lock->user_name )
                          )
              CHANGING
                failed    = failed-travel
                reported  = reported-travel
            ).

        CATCH cx_abap_lock_failure INTO exception.
          RAISE SHORTDUMP exception.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.


**********************************************************************
*
* Read booking data by association from buffer
*
**********************************************************************
  METHOD rba_Booking.
    DATA: travel_out  TYPE ZTK_travel,
          booking_out TYPE ZTK_t_booking,
          booking     LIKE LINE OF result,
          messages    TYPE ZTK_t_message.


    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<travel_rba>) GROUP BY <travel_rba>-TravelID.

      CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <travel_rba>-travelid
        IMPORTING
          es_travel    = travel_out
          et_booking   = booking_out
          et_messages  = messages.

      map_messages(
          EXPORTING
            travel_id        = <travel_rba>-TravelID
            messages         = messages
            IMPORTING
            failed_added = DATA(failed_added)
          CHANGING
            failed           = failed-travel
            reported         = reported-travel
        ).

      IF failed_added = abap_false.
        LOOP AT booking_out ASSIGNING FIELD-SYMBOL(<booking>).
          "fill link table with key fields

          INSERT
            VALUE #(
              source-%tky = <travel_rba>-%tky
              target-%tky = VALUE #(
                                TravelID  = <booking>-travel_id
                                BookingID = <booking>-booking_id
              ) )
            INTO TABLE association_links.

          IF result_requested = abap_true.
            booking = CORRESPONDING #( <booking> MAPPING TO ENTITY ).
            INSERT booking INTO TABLE result.
          ENDIF.

        ENDLOOP.
      ENDIF.

    ENDLOOP.

    SORT association_links BY target ASCENDING.
    DELETE ADJACENT DUPLICATES FROM association_links COMPARING ALL FIELDS.

    SORT result BY %tky ASCENDING.
    DELETE ADJACENT DUPLICATES FROM result COMPARING ALL FIELDS.
  ENDMETHOD.


**********************************************************************
*
* Create associated booking instances
*
**********************************************************************
  METHOD cba_Booking.
    DATA: messages        TYPE ZTK_t_message,
          booking_old     TYPE ZTK_t_booking,
          booking         TYPE ZTK_booking,
          last_booking_id TYPE ZTK_booking_id VALUE '0'.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<travel>).

      DATA(travelid) = <travel>-travelid.

      CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = travelid
        IMPORTING
          et_booking   = booking_old
          et_messages  = messages.

      map_messages(
          EXPORTING
            cid       = <travel>-%cid_ref
            travel_id = <travel>-TravelID
            messages  = messages
          IMPORTING
            failed_added = DATA(failed_added)
          CHANGING
            failed           = failed-travel
            reported         = reported-travel
        ).

      IF failed_added = abap_true.
        LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking>).
          map_messages_assoc_to_booking(
            EXPORTING
              cid          = <booking>-%cid
              travel_id    = <travel>-TravelID
              booking_id   = <booking>-BookingID
              is_dependend = abap_true
              messages     = messages
            CHANGING
              failed       = failed-booking
              reported     = reported-booking
          ).
        ENDLOOP.

      ELSE.

        " Set the last_booking_id to the highest value of booking_old booking_id or initial value if none exist
        last_booking_id = VALUE #( booking_old[ lines( booking_old ) ]-booking_id OPTIONAL ).

        LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking_create>).

          booking = CORRESPONDING #( <booking_create> MAPPING FROM ENTITY USING CONTROL ) .

          last_booking_id += 1.
          booking-booking_id = last_booking_id.

          CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_UPDATE'
            EXPORTING
              is_travel   = VALUE ZTK_s_travel_in( travel_id = travelid )
              is_travelx  = VALUE ZTK_s_travel_inx( travel_id = travelid )
              it_booking  = VALUE ZTK_t_booking_in( ( CORRESPONDING #( booking ) ) )
              it_bookingx = VALUE ZTK_t_booking_inx(
                (
                  booking_id  = booking-booking_id
                  action_code = ZTK_if_flight_legacy=>action_code-create
                )
              )
            IMPORTING
              et_messages = messages.

          map_messages_assoc_to_booking(
              EXPORTING
                travel_id        = TravelID
                booking_id       = booking-booking_ID
                messages         = messages
                IMPORTING
                failed_added = failed_added
              CHANGING
                failed           = failed-booking
                reported         = reported-booking
            ).

          IF failed_added = abap_false.
            INSERT
              VALUE #(
                %cid      = <booking_create>-%cid
                travelid  = travelid
                bookingid = booking-booking_id
              ) INTO TABLE mapped-booking.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


**********************************************************************
*
* Implement travel action(s) (in our case: for setting travel status)
*
**********************************************************************
  METHOD set_status_booked.
    DATA: messages                 TYPE ZTK_t_message,
          travel_out               TYPE ZTK_travel,
          travel_set_status_booked LIKE LINE OF result.

    CLEAR result.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<travel_set_status_booked>).

      DATA(travelid) = <travel_set_status_booked>-travelid.

      CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_SET_BOOKING'
        EXPORTING
          iv_travel_id = travelid
        IMPORTING
          et_messages  = messages.

      map_messages(
          EXPORTING
            travel_id        = <travel_set_status_booked>-TravelID
            messages         = messages
          IMPORTING
            failed_added = DATA(failed_added)
          CHANGING
            failed           = failed-travel
            reported         = reported-travel
        ).

      IF failed_added = abap_false.
        CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_READ'
          EXPORTING
            iv_travel_id = travelid
          IMPORTING
            es_travel    = travel_out.

        travel_set_status_booked-travelid        = travelid.
        travel_set_status_booked-%param          = CORRESPONDING #( travel_out MAPPING TO ENTITY ).
        travel_set_status_booked-%param-travelid = travelid.
        APPEND travel_set_status_booked TO result.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


**********************************************************************
*
* Map messages from legacy type to failed and reported
*
**********************************************************************
  METHOD map_messages.
    failed_added = abap_false.
    LOOP AT messages INTO DATA(message).
      IF message-msgty = 'E' OR message-msgty = 'A'.
        APPEND VALUE #( %cid        = cid
                        travelid    = travel_id
                        %fail-cause = ZTK_cl_travel_auxiliary=>get_cause_from_message(
                                        msgid = message-msgid
                                        msgno = message-msgno
                                      ) )
               TO failed.
        failed_added = abap_true.
      ENDIF.

      APPEND VALUE #( %msg          = new_message(
                                        id       = message-msgid
                                        number   = message-msgno
                                        severity = if_abap_behv_message=>severity-error
                                        v1       = message-msgv1
                                        v2       = message-msgv2
                                        v3       = message-msgv3
                                        v4       = message-msgv4 )
                      %cid          = cid
                      TravelID      = travel_id )
             TO reported.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_messages_assoc_to_booking.
    failed_added = abap_false.
    LOOP AT messages INTO DATA(message).
      IF message-msgty = 'E' OR message-msgty = 'A'.
        APPEND VALUE #( %cid        = cid
                        travelid    = travel_id
                        bookingid   = booking_id
                        %fail-cause = ZTK_cl_travel_auxiliary=>get_cause_from_message(
                                        msgid = message-msgid
                                        msgno = message-msgno
                                        is_dependend = is_dependend
                                      ) )
               TO failed.
        failed_added = abap_true.
      ENDIF.

      APPEND VALUE #( %msg          = new_message(
                                        id       = message-msgid
                                        number   = message-msgno
                                        severity = if_abap_behv_message=>severity-error
                                        v1       = message-msgv1
                                        v2       = message-msgv2
                                        v3       = message-msgv3
                                        v4       = message-msgv4 )
                      %cid          = cid
                      TravelID      = travel_id
                      bookingID     = booking_id )
             TO reported.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.



**********************************************************************
*
* Saver class implements the save sequence for data persistence
*
**********************************************************************
CLASS lsc_I_TRAVEL_U DEFINITION
  INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_I_TRAVEL_U IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_SAVE'.
  ENDMETHOD.

  METHOD cleanup.
    CALL FUNCTION 'ZTK_FLIGHT_TRAVEL_INITIALIZE'.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
