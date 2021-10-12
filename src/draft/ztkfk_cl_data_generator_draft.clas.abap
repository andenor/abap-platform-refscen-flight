CLASS ZTKFK_cl_data_generator_draft DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES ZTKFK_if_data_generation_badi .
    INTERFACES if_badi_interface .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZTKFK_cl_data_generator_draft IMPLEMENTATION.


  METHOD ZTKFK_if_data_generation_badi~data_generation.
    " Travels
    out->write( ' --> ZTKFK_A_TRAVEL_D' ).

    DELETE FROM ZTKFK_d_travel_d.                        "#EC CI_NOWHERE
    DELETE FROM ZTKFK_a_travel_d.                        "#EC CI_NOWHERE

    INSERT ZTKFK_a_travel_d FROM (
      SELECT FROM ZTKFK_travel FIELDS
        " client
        uuid( ) AS travel_uuid,
        travel_id,
        agency_id,
        customer_id,
        begin_date,
        end_date,
        booking_fee,
        total_price,
        currency_code,
        description,
        CASE status WHEN 'B' THEN 'A'
                    WHEN 'P' THEN 'O'
                    WHEN 'N' THEN 'O'
                    ELSE 'X' END AS overall_status,
        createdby AS local_created_by,
        createdat AS local_created_at,
        lastchangedby AS local_last_changed_by,
        lastchangedat AS local_last_changed_at,
        lastchangedat AS last_changed_at
    ).


    " bookings
    out->write( ' --> ZTKFK_A_BOOKING_D' ).

    DELETE FROM ZTKFK_d_booking_d.                       "#EC CI_NOWHERE
    DELETE FROM ZTKFK_a_booking_d.                       "#EC CI_NOWHERE

    INSERT ZTKFK_a_booking_d FROM (
        SELECT
          FROM ZTKFK_booking
            JOIN ZTKFK_a_travel_d ON ZTKFK_booking~travel_id = ZTKFK_a_travel_d~travel_id
            JOIN ZTKFK_travel ON ZTKFK_travel~travel_id = ZTKFK_booking~travel_id
          FIELDS  "client,
                  uuid( ) AS booking_uuid,
                  ZTKFK_a_travel_d~travel_uuid AS parent_uuid,
                  ZTKFK_booking~booking_id,
                  ZTKFK_booking~booking_date,
                  ZTKFK_booking~customer_id,
                  ZTKFK_booking~carrier_id,
                  ZTKFK_booking~connection_id,
                  ZTKFK_booking~flight_date,
                  ZTKFK_booking~flight_price,
                  ZTKFK_booking~currency_code,
                  CASE ZTKFK_travel~status WHEN 'P' THEN 'N'
                                                   ELSE ZTKFK_travel~status END AS booking_status,
                  ZTKFK_a_travel_d~last_changed_at AS local_last_changed_at
    ).



    " Booking supplements
    out->write( ' --> ZTKFK_A_BKSUPPL_D' ).

    DELETE FROM ZTKFK_d_bksuppl_d.                       "#EC CI_NOWHERE
    DELETE FROM ZTKFK_a_bksuppl_d.                       "#EC CI_NOWHERE

    INSERT ZTKFK_a_bksuppl_d FROM (
      SELECT FROM ZTKFK_book_suppl    AS supp
               JOIN ZTKFK_a_travel_d  AS trvl ON trvl~travel_id = supp~travel_id
               JOIN ZTKFK_a_booking_d AS book ON book~parent_uuid = trvl~travel_uuid
                                            AND book~booking_id = supp~booking_id

        FIELDS
          " client
          uuid( )                 AS booksuppl_uuid,
          trvl~travel_uuid        AS root_uuid,
          book~booking_uuid       AS parent_uuid,
          supp~booking_supplement_id,
          supp~supplement_id,
          supp~price,
          supp~currency_code,
          trvl~last_changed_at    AS local_last_changed_at
    ).

  ENDMETHOD.


ENDCLASS.
