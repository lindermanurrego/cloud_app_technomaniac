CLASS lhc_ZI_TRAVEL_TECH_M_L DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_travel_tech_m_l RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_travel_tech_m_l RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
       entities FOR CREATE zi_travel_tech_m_l.

ENDCLASS.

CLASS lhc_ZI_TRAVEL_TECH_M_L IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(lt_entities) = entities.

    DELETE lt_entities WHERE TravelId IS NOT INITIAL.
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr           =  '01'
            object                    = '/DMO/TRV_M'
            quantity                 = CONV #( lines(  lt_entities ) )
          IMPORTING
            number                 = DATA(lv_latest_num)
            returncode            =  DATA(lv_code)
            returned_quantity = DATA(lv_qty)
        ).

      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_error).
        LOOP AT lt_entities INTO DATA(ls_entities).
          APPEND VALUE  #(   %cid = ls_entities-%cid
                                             TravelId = ls_entities-%key
                                             ) TO failed-zi_travel_tech_m_l.
          APPEND VALUE  #(   %cid = ls_entities-%cid
                                             TravelId = ls_entities-%key
                                             %msg = lo_error
                                             ) TO reported-zi_travel_tech_m_l.
        ENDLOOP.
        EXIT.
    ENDTRY..

    ASSERT lv_qty =  lines(  lt_entities ) .

    DATA: lti_travel_tech_m_l TYPE TABLE FOR MAPPED EARLY  zi_travel_tech_m_l,
          ls_travel_tech_m_l  LIKE LINE OF lti_travel_tech_m_l.
    DATA(lv_current_number) = lv_latest_num - lv_qty .
    LOOP AT lt_entities INTO ls_entities.
      lv_current_number = lv_current_number + 1.
      ls_travel_tech_m_l = VALUE  #(   %cid = ls_entities-%cid
                                                           TravelId = lv_current_number  ).
      APPEND ls_travel_tech_m_l TO mapped-zi_travel_tech_m_l.
    ENDLOOP.



  ENDMETHOD.

ENDCLASS.
