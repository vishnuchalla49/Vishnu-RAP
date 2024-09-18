CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE _Booking\_Bookingsuppl.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.

    DATA max_booking_suppl_id TYPE /dmo/booking_supplement_id.

    ""Step 1: get all the travel requests and their booking data
    READ ENTITIES OF zvc_xx_travel IN LOCAL MODE
        ENTITY _booking BY \_BookingSuppl
        FROM CORRESPONDING #( entities )
        LINK DATA(booking_supplements).

    ""Loop at unique travel ids
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking_group>) GROUP BY <booking_group>-%tky.
      ""Step 2: get the highest booking supplement number which is already there
      LOOP AT booking_supplements INTO DATA(ls_booking) USING KEY entity
          WHERE source-TravelId = <booking_group>-TravelId AND
                source-BookingId = <booking_group>-BookingId.
        ""While comparing with ID we need Supplement ID comparision
        IF max_booking_suppl_id < ls_booking-target-BookingSupplementId.
          max_booking_suppl_id = ls_booking-target-BookingSupplementId.
        ENDIF.
      ENDLOOP.
      ""Step 3: get the asigned booking supplement numbers for incoming request
      LOOP AT entities INTO DATA(ls_entity) USING KEY entity
          WHERE TravelId = <booking_group>-TravelId AND
                BookingId = <booking_group>-BookingId.
        LOOP AT ls_entity-%target INTO DATA(ls_target).
          ""While comparing with ID we need Supplement ID comparision
          IF max_booking_suppl_id < ls_target-BookingSupplementId.
            max_booking_suppl_id = ls_target-BookingSupplementId.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      ""Step 4: loop over all the entities of travel with same travel id
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>)
          USING KEY entity WHERE TravelId = <booking_group>-TravelId AND
                                 BookingId = <booking_group>-BookingId..
        ""Step 5: assign new booking IDs to the booking entity inside each travel
        LOOP AT <booking>-%target ASSIGNING FIELD-SYMBOL(<bookingsuppl_wo_numbers>).
          APPEND CORRESPONDING #( <bookingsuppl_wo_numbers> ) TO mapped-_bookingsuppl
          ASSIGNING FIELD-SYMBOL(<mapped_bookingsuppl>).
          IF <mapped_bookingsuppl>-BookingSupplementId IS INITIAL.
            max_booking_suppl_id += 1.
            <mapped_bookingsuppl>-BookingSupplementId = max_booking_suppl_id.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
