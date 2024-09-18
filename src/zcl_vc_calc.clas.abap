CLASS zcl_vc_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_vc_calc IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    CHECK NOT it_original_data IS INITIAL.

    DATA : lt_calc_data TYPE STANDARD TABLE OF zvc_xx_travel_proj WITH DEFAULT KEY,
           lv_rate      TYPE p DECIMALS 2 VALUE '0.025'.

    lt_calc_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_calc_data ASSIGNING FIELD-SYMBOL(<fs_calc>).
      <fs_calc>-CO2Tax = <fs_calc>-TotalPrice * lv_rate.
      <fs_calc>-dayOfTheFlight = 'Sunday'.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_calc_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
