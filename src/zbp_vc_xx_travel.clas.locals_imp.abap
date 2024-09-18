CLASS lhc_ZVC_XX_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _Travel  RESULT result.

    METHODS validatetotalprice FOR VALIDATE ON SAVE
      IMPORTING keys FOR _travel~validatetotalprice.

    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION _travel~recalctotalprice.

    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _travel~calculatetotalprice.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR _travel RESULT result.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE _travel\_booking.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION _travel~copytravel.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE _Travel.

ENDCLASS.

CLASS lhc_ZVC_XX_TRAVEL IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD validateTotalPrice.
    READ ENTITIES OF zvc_xx_travel IN LOCAL MODE
      ENTITY _Travel
      FIELDS ( TotalPrice ) WITH CORRESPONDING #(  keys )
      RESULT DATA(lt_Travels).

    LOOP AT lt_Travels INTO DATA(Travels).
      IF Travels-TotalPrice > 9000.
        APPEND VALUE #( %tky = Travels-%tky ) TO failed-_Travel.

        APPEND VALUE #( %tky = keys[  1  ]-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'Total price is not to be greater than 9000' ) ) TO reported-_travel.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD reCalcTotalPrice.
    TYPES: BEGIN OF ty_amount_per_currency,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_currency.

    DATA: amounts_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currency.

    READ ENTITIES OF zvc_xx_travel IN LOCAL MODE
         ENTITY _Travel
         FIELDS ( BookingFee CurrencyCode )
         WITH CORRESPONDING #(  keys )
         RESULT DATA(travels).

    READ ENTITIES OF zvc_xx_travel IN LOCAL MODE
         ENTITY _Travel BY \_Booking
         FIELDS ( FlightPrice CurrencyCode )
         WITH CORRESPONDING #(  travels )
         RESULT DATA(booking).

    READ ENTITIES OF zvc_xx_travel IN LOCAL MODE
         ENTITY _Booking BY \_BookingSuppl
         FIELDS ( Price CurrencyCode )
         WITH CORRESPONDING #(  booking )
         RESULT DATA(bookingsupplements).

    DELETE travels WHERE Currencycode IS INITIAL.
    DELETE Booking WHERE Currencycode IS INITIAL.
    DELETE bookingsupplements WHERE Currencycode IS INITIAL.

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travels>).
      amounts_per_currencycode = VALUE #( (  amount = <travels>-BookingFee
                                           currency_code = <travels>-CurrencyCode ) ).


      LOOP AT booking INTO DATA(bookings) WHERE TravelId = <travels>-TravelId.
        COLLECT VALUE ty_amount_per_currency(   amount = bookings-FlightPrice
                                              currency_code = bookings-CurrencyCode ) INTO amounts_per_currencycode.
      ENDLOOP.

      LOOP AT bookingsupplements INTO DATA(bookingsuppplementsi) WHERE TravelId = <travels>-TravelId.
        COLLECT VALUE ty_amount_per_currency( amount = bookingsuppplementsi-Price
                                              currency_code = bookings-Currencycode ) INTO amounts_per_currencycode.
      ENDLOOP.

      CLEAR <travels>-TotalPrice.
      LOOP AT amounts_per_currencycode INTO DATA(amounts_per_struc_currencycode).

        IF amounts_per_struc_currencycode-Currency_code = <travels>-CurrencyCode.
          <travels>-TotalPrice += amounts_per_struc_currencycode-amount.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount = amounts_per_struc_currencycode-amount
              iv_currency_code_source = amounts_per_struc_currencycode-currency_code
              iv_currency_code_target = <travels>-CurrencyCode
              iv_exchange_rate_date = cl_abap_context_info=>get_system_date(  )
            IMPORTING
              ev_amount = DATA(total_booking_amount)
              ).

          <travels>-TotalPrice = <travels>-TotalPrice + total_booking_amount.

        ENDIF.
      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zvc_xx_travel IN LOCAL MODE
    ENTITY _Travel
    UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( travels ).

  ENDMETHOD.
*
  METHOD calculateTotalPrice.
    MODIFY ENTITIES OF zvc_xx_travel IN LOCAL MODE
      ENTITY _Travel
      EXECUTE reCalcTotalPrice
      FROM CORRESPONDING #( keys ).
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zvc_xx_travel IN LOCAL MODE
        ENTITY _travel
            FIELDS ( travelid overallstatus )
            WITH     CORRESPONDING #( keys )
        RESULT DATA(travels)
        FAILED failed.

    "Step 2: return the result with booking creation possible or not
    READ TABLE travels INTO DATA(ls_travel) INDEX 1.

    IF ( ls_travel-OverallStatus = 'X' ).
      DATA(lv_allow) = if_abap_behv=>fc-o-disabled.
    ELSE.
      lv_allow = if_abap_behv=>fc-o-enabled.
    ENDIF.

    result = VALUE #( FOR travel IN travels
                        ( %tky = travel-%tky
                          %assoc-_Booking = lv_allow
                        )
                    ).

  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA: entity        TYPE STRUCTURE FOR CREATE zvc_xx_travel,
          travel_id_max TYPE /dmo/travel_id.

    ""Step 1: Ensure that Travel id is not set for the record which is coming
    LOOP AT entities INTO entity WHERE TravelId IS NOT INITIAL.
      APPEND CORRESPONDING #( entity ) TO mapped-_travel.
    ENDLOOP.

    DATA(entities_wo_travelid) = entities.
    DELETE entities_wo_travelid WHERE TravelId IS NOT INITIAL.

    ""Step 2: Get the seuquence numbers from the SNRO
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = CONV #( '/DMO/TRAVL' )
            quantity          =  CONV #( lines( entities_wo_travelid ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
*        CATCH cx_nr_object_not_found.
*        CATCH cx_number_ranges.

      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        ""Step 3: If there is an exception, we will throw the error
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key %msg = lx_number_ranges )
              TO reported-_travel.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key ) TO failed-_travel.
        ENDLOOP.
        EXIT.
    ENDTRY.

    CASE number_range_return_code.
      WHEN '1'.
        ""Step 4: Handle especial cases where the number range exceed critical %
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key
                          %msg = NEW /dmo/cm_flight_messages(
                                      textid = /dmo/cm_flight_messages=>number_range_depleted
                                      severity = if_abap_behv_message=>severity-warning
                          ) )
              TO reported-_travel.
        ENDLOOP.
      WHEN '2' OR '3'.
        ""Step 5: The number range return last number, or number exhaused
        APPEND VALUE #( %cid = entity-%cid %key = entity-%key
                            %msg = NEW /dmo/cm_flight_messages(
                                        textid = /dmo/cm_flight_messages=>not_sufficient_numbers
                                        severity = if_abap_behv_message=>severity-warning
                            ) )
                TO reported-_travel.
        APPEND VALUE #( %cid = entity-%cid
                        %key = entity-%key
                        %fail-cause = if_abap_behv=>cause-conflict
                         ) TO failed-_travel.
    ENDCASE.

    ""Step 6: Final check for all numbers
    ASSERT number_range_returned_quantity = lines( entities_wo_travelid ).

    ""Step 7: Loop over the incoming travel data and asign the numbers from number range and
    ""        return MAPPED data which will then go to RAP framework
    travel_id_max = number_range_key - number_range_returned_quantity.

    LOOP AT entities_wo_travelid INTO entity.

      travel_id_max += 1.
      entity-TravelId = travel_id_max.

      APPEND VALUE #( %cid = entity-%cid
                      %key = entity-%key
                      %is_draft = entity-%is_draft ) TO mapped-_travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.
    DATA max_booking_id TYPE /dmo/booking_id.

    ""Step 1: get all the travel requests and their booking data
    READ ENTITIES OF zvc_xx_travel IN LOCAL MODE
        ENTITY _travel BY \_Booking
        FROM CORRESPONDING #( entities )
        LINK DATA(bookings).

    ""Loop at unique travel ids
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_group>) GROUP BY <travel_group>-TravelId.
      ""Step 2: get the highest booking number which is already there
      LOOP AT bookings INTO DATA(ls_booking)
          WHERE source-TravelId = <travel_group>-TravelId.
        IF max_booking_id < ls_booking-target-BookingId.
          max_booking_id = ls_booking-target-BookingId.
        ENDIF.
      ENDLOOP.
      ""Step 3: get the asigned booking numbers for incoming request
      LOOP AT entities INTO DATA(ls_entity)
          WHERE TravelId = <travel_group>-TravelId.
        LOOP AT ls_entity-%target INTO DATA(ls_target).
          IF max_booking_id < ls_target-BookingId.
            max_booking_id = ls_target-BookingId.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      ""Step 4: loop over all the entities of travel with same travel id
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel>)
          WHERE TravelId = <travel_group>-TravelId.
        ""Step 5: assign new booking IDs to the booking entity inside each travel
        LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking_wo_numbers>).
          APPEND CORRESPONDING #( <booking_wo_numbers> ) TO mapped-_booking
          ASSIGNING FIELD-SYMBOL(<mapped_booking>).
          IF <mapped_booking>-BookingId IS INITIAL.
            max_booking_id += 10.
            <mapped_booking>-%is_draft = <booking_wo_numbers>-%is_draft.
            <mapped_booking>-BookingId = max_booking_id.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD copyTravel.
    DATA: travels       TYPE TABLE FOR CREATE zvc_xx_travel\\_Travel,
          bookings_cba  TYPE TABLE FOR CREATE zvc_xx_travel\\_Travel\_Booking,
          booksuppl_cba TYPE TABLE FOR CREATE zvc_xx_travel\\_Booking\_BookingSuppl.

    "Step 1: Remove the travel instances with initial %cid
    READ TABLE keys WITH KEY %cid = '' INTO DATA(key_with_initial_cid).
    ASSERT key_with_initial_cid IS INITIAL.

    "Step 2: Read all travel, booking and booking supplement using EML
    READ ENTITIES OF zvc_xx_travel IN LOCAL MODE
    ENTITY _Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(travel_read_result)
        FAILED failed.

    READ ENTITIES OF zvc_xx_travel IN LOCAL MODE
    ENTITY _Travel BY \_Booking
        ALL FIELDS WITH CORRESPONDING #( travel_read_result )
        RESULT DATA(book_read_result)
        FAILED failed.

    READ ENTITIES OF zvc_xx_travel IN LOCAL MODE
  ENTITY _booking BY \_BookingSuppl
      ALL FIELDS WITH CORRESPONDING #( book_read_result )
      RESULT DATA(booksuppl_read_result)
      FAILED failed.
    LOOP AT travel_read_result ASSIGNING FIELD-SYMBOL(<travel>).

      "Travel data prepration
      APPEND VALUE #( %cid = keys[ %tky = <travel>-%tky ]-%cid
                     %data = CORRESPONDING #( <travel> EXCEPT travelId )
      ) TO travels ASSIGNING FIELD-SYMBOL(<new_travel>).

      <new_travel>-BeginDate = cl_abap_context_info=>get_system_date( ).
      <new_travel>-EndDate = cl_abap_context_info=>get_system_date( ) + 30.
      <new_travel>-OverallStatus = 'O'.

      "Step 3: Fill booking internal table for booking data creation - %cid_ref - abc123
      APPEND VALUE #( %cid_ref = keys[ %tky = <travel>-%tky ]-%cid )
        TO bookings_cba ASSIGNING FIELD-SYMBOL(<bookings_cba>).

      LOOP AT  book_read_result ASSIGNING FIELD-SYMBOL(<booking>) WHERE TravelId = <travel>-TravelId.

        APPEND VALUE #( %cid = keys[ %tky = <travel>-%tky ]-%cid && <booking>-BookingId
                        %data = CORRESPONDING #( book_read_result[ %tky = <booking>-%tky ] EXCEPT travelid )
        )
            TO <bookings_cba>-%target ASSIGNING FIELD-SYMBOL(<new_booking>).

        <new_booking>-BookingStatus = 'N'.

        "Step 4: Fill booking supplement internal table for booking suppl data creation
        APPEND VALUE #( %cid_ref = keys[ %tky = <travel>-%tky ]-%cid && <booking>-BookingId )
                TO booksuppl_cba ASSIGNING FIELD-SYMBOL(<booksuppl_cba>).

        LOOP AT booksuppl_read_result ASSIGNING FIELD-SYMBOL(<booksuppl>)
             WHERE TravelId = <travel>-TravelId AND
                                   BookingId = <booking>-BookingId.

          APPEND VALUE #( %cid = keys[  %tky = <travel>-%tky ]-%cid && <booking>-BookingId && <booksuppl>-BookingSupplementId
                      %data = CORRESPONDING #( <booksuppl> EXCEPT travelid bookingid )
          )
          TO <booksuppl_cba>-%target.

        ENDLOOP.
      ENDLOOP.


    ENDLOOP.

    MODIFY ENTITIES OF zvc_xx_travel IN LOCAL MODE
        ENTITY _travel
            CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus )
                WITH travels
                    CREATE BY \_Booking FIELDS ( Bookingid BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus )
                        WITH bookings_cba
                            ENTITY _Booking
                                CREATE BY \_BookingSuppl FIELDS ( bookingsupplementid supplementid price currencycode )
                                    WITH booksuppl_cba
        MAPPED DATA(mapped_create).

    mapped-_Travel = mapped_create-_travel.



  ENDMETHOD.

ENDCLASS.
