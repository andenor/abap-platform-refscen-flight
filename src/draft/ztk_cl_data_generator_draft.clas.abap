CLASS ZTK_cl_data_generator_draft DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES ZTK_if_data_generation_badi .
    INTERFACES if_badi_interface .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZTK_cl_data_generator_draft IMPLEMENTATION.


  METHOD ZTK_if_data_generation_badi~data_generation.
    " Travels
    out->write( ' --> ZTK_A_TRAVEL_D' ).

    DELETE FROM ZTK_d_travel_d.                        "#EC CI_NOWHERE
    DELETE FROM ZTK_a_travel_d.                        "#EC CI_NOWHERE

    INSERT ZTK_a_travel_d FROM (
      SELECT FROM ZTK_travel FIELDS
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
    out->write( ' --> ZTK_A_BOOKING_D' ).

    DELETE FROM ZTK_d_booking_d.                       "#EC CI_NOWHERE
    DELETE FROM ZTK_a_booking_d.                       "#EC CI_NOWHERE

    INSERT ZTK_a_booking_d FROM (
        SELECT
          FROM ZTK_booking
            JOIN ZTK_a_travel_d ON ZTK_booking~travel_id = ZTK_a_travel_d~travel_id
            JOIN ZTK_travel ON ZTK_travel~travel_id = ZTK_booking~travel_id
          FIELDS  "client,
                  uuid( ) AS booking_uuid,
                  ZTK_a_travel_d~travel_uuid AS parent_uuid,
                  ZTK_booking~booking_id,
                  ZTK_booking~booking_date,
                  ZTK_booking~customer_id,
                  ZTK_booking~carrier_id,
                  ZTK_booking~connection_id,
                  ZTK_booking~flight_date,
                  ZTK_booking~flight_price,
                  ZTK_booking~currency_code,
                  CASE ZTK_travel~status WHEN 'P' THEN 'N'
                                                   ELSE ZTK_travel~status END AS booking_status,
                  ZTK_a_travel_d~last_changed_at AS local_last_changed_at
    ).



    " Booking supplements
    out->write( ' --> ZTK_A_BKSUPPL_D' ).

    DELETE FROM ZTK_d_bksuppl_d.                       "#EC CI_NOWHERE
    DELETE FROM ZTK_a_bksuppl_d.                       "#EC CI_NOWHERE

    INSERT ZTK_a_bksuppl_d FROM (
      SELECT FROM ZTK_book_suppl    AS supp
               JOIN ZTK_a_travel_d  AS trvl ON trvl~travel_id = supp~travel_id
               JOIN ZTK_a_booking_d AS book ON book~parent_uuid = trvl~travel_uuid
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
