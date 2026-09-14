CLASS lhc_ZI_TRAVEL_TECH_M_L DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_travel_tech_m_l RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_travel_tech_m_l RESULT result.
    METHODS acceptravel FOR MODIFY
       keys FOR ACTION zi_travel_tech_m_l~acceptravel RESULT result.

    METHODS copytravel FOR MODIFY
       keys FOR ACTION zi_travel_tech_m_l~copytravel.

    METHODS recalctotproce FOR MODIFY
       keys FOR ACTION zi_travel_tech_m_l~recalctotproce.

    METHODS rejecttravel FOR MODIFY
       keys FOR ACTION zi_travel_tech_m_l~rejecttravel RESULT result.

    METHODS earlynumbering_create_bookings FOR NUMBERING
       entities FOR CREATE zi_travel_tech_m_l\_Booking.

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

  METHOD earlynumbering_create_bookings.
    DATA lv_max_booking TYPE /dmo/booking_id.
*..Lee de la tabla zi_travel_tech_m_l las entidades que llegaron al metodo
*trayendo la refencia del Booking
    READ ENTITIES OF zi_travel_tech_m_l IN LOCAL MODE
     ENTITY zi_travel_tech_m_l BY \_Booking
       FROM CORRESPONDING #(  entities )
       LINK DATA(lt_link_data).


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_group>)
                                                     GROUP BY <fs_group>-TravelId.
*..Se busca el maximo pero que se encuentra en la tabla
      lv_max_booking  = REDUCE #(  INIT  lv_max  = CONV  /dmo/booking_id(  '0'  )
                                                               FOR ls_link IN lt_link_data USING KEY entity
                                                               WHERE (  source-TravelId = <fs_group>-TravelId  )
                                                               NEXT lv_max = COND /dmo/booking_id(  WHEN  lv_max <  ls_link-target-BookingId
                                                                                                                                      THEN ls_link-target-BookingId
                                                                                                                                      ELSE  lv_max ) ).
*..Buscar el maximo pero en la entidades y se compara contra el maximo booking encontrado anteriormente
*..Al final  lv_max_booking tiene le maximo booking y se busco en la tabla z y en las entidades
      lv_max_booking  = REDUCE #(  INIT  lv_max  = lv_max_booking
                                                               FOR ls_entity  IN entities  USING KEY entity
                                                               WHERE (  TravelId = <fs_group>-TravelId  )
                                                               FOR ls_booking IN ls_entity-%target
                                                               NEXT lv_max = COND /dmo/booking_id(  WHEN  lv_max <  ls_booking-BookingId
                                                                                                                                      THEN ls_booking-BookingId
                                                                                                                                      ELSE  lv_max ) ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entities>)
                                                  USING KEY entity WHERE  TravelId = <fs_group>-TravelId.

        LOOP AT <ls_entities>-%target ASSIGNING FIELD-SYMBOL(<fs_booking>).
          IF <fs_booking>-BookingId IS INITIAL.
            lv_max_booking += 10.
            APPEND CORRESPONDING #( <fs_booking> ) TO  mapped-zi_booking_tec_m_l
                           ASSIGNING FIELD-SYMBOL(<ls_new_map_book>).
            <ls_new_map_book>-BookingId = lv_max_booking.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD accepTravel.
  ENDMETHOD.
*Este metodo realizara la copia de un viaje y todas las reservas y suplementos asociados
  METHOD copyTravel.

    DATA:it_travel        TYPE TABLE FOR CREATE zi_travel_tech_m_l,
         it_booking_cba   TYPE TABLE FOR CREATE zI_TRAVEL_TECH_M_L\_Booking,
         it_booksuppl_cba TYPE TABLE FOR CREATE zi_booking_tec_m_l\_Bookingsuppl.

*..Verificar que no hay cid vacios
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_with_out_cid>) WITH KEY %cid = ''.
    ASSERT <ls_with_out_cid> IS INITIAL.
*..Leer todos los viajes que llegaron en la tabla keys
*..Los datos quedan en la tabla lt_travel_r
    READ ENTITIES OF zi_travel_tech_m_l  IN LOCAL MODE
              ENTITY zi_travel_tech_m_l
              ALL FIELDS WITH  CORRESPONDING #(  keys )
              RESULT DATA(lt_travel_r)
              FAILED DATA(lt_failed).
*..Leer todas las reservas asocaidasa los viajes
*..Los datos quedan en la tabla lt_booking_r
    READ ENTITIES OF zi_travel_tech_m_l  IN LOCAL MODE
              ENTITY zi_travel_tech_m_l BY \_Booking
              ALL FIELDS WITH  CORRESPONDING #(  lt_travel_r )
              RESULT DATA(lt_booking_r).
*..Leer todos los suplementos asociados a las reservas
*..Los datos quedan en la tabla lt_booksupp_r)
    READ ENTITIES OF zi_travel_tech_m_l  IN LOCAL MODE
              ENTITY zi_booking_tec_m_l BY \_Bookingsuppl
              ALL FIELDS WITH  CORRESPONDING #(  lt_booking_r )
              RESULT DATA(lt_booksupp_r).


    LOOP AT lt_travel_r ASSIGNING FIELD-SYMBOL(<ls_travel_r>).
*..Asignacion del viaje con varias lineas de codigo
*         APPEND INITIAL LINE TO it_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
*        <ls_travel>-%cid = keys[ key entity  TravelId = <ls_travel_r>-TravelId  ]-%cid.
*        <ls_travel>-%data = CORRESPONDING #( <ls_travel_r> EXCEPT TravelId ).
*..Asignacion del viaje usando una sola linea
      APPEND VALUE #( %cid = keys[ KEY entity  TravelId = <ls_travel_r>-TravelId  ]-%cid
                                      %data = CORRESPONDING #( <ls_travel_r> EXCEPT TravelId )
           ) TO it_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
*Se actualizan algunos campos
      <ls_travel>-BeginDate = cl_abap_context_info=>get_system_date( ).
      <ls_travel>-EndDate = cl_abap_context_info=>get_system_date( ) + 30.
      <ls_travel>-OverallStatus = 'O'.

*Asignacion de las reservas
*Se asigna la referencia al travelid
      APPEND VALUE #(  %cid_ref =  <ls_travel>-%cid )
        TO it_booking_cba ASSIGNING FIELD-SYMBOL(<ls_booking>).
*Se crea el %cid y se copian los datos
      LOOP AT lt_booking_r ASSIGNING FIELD-SYMBOL(<ls_booking_r>)
                                            WHERE TravelId =  <ls_travel_r>-TravelId .

        APPEND VALUE #(  %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId
                                        %data = CORRESPONDING #( <ls_booking_r> EXCEPT   TravelID )
          )  TO  <ls_booking>-%target ASSIGNING FIELD-SYMBOL(<ls_booking_n>).
*El status se actualiza
        <ls_booking_n>-BookingStatus = 'N'.
*Se asigna la referencia al bookingId
        APPEND VALUE #(  %cid_ref =  <ls_booking_n>-%cid )
          TO it_booksuppl_cba ASSIGNING FIELD-SYMBOL(<ls_booksuppl_cba>).

*Para cada reserva se asigna los supplementos.
        LOOP AT lt_booksupp_r ASSIGNING FIELD-SYMBOL(<ls_booksupp_r>)
                                                USING KEY entity
                                              WHERE TravelId =  <ls_travel_r>-TravelId
                                                    AND BookingId = <ls_booking_r>-BookingId.
          APPEND VALUE #(  %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId && <ls_booksupp_r>-BookingSupplementId
                                          %data = CORRESPONDING #( <ls_booksupp_r> EXCEPT   TravelID BookingId )
            )  TO  <ls_booksuppl_cba>-%target.

        ENDLOOP.
      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.

  METHOD recalcTotProce.
  ENDMETHOD.

  METHOD rejectTravel.
  ENDMETHOD.

ENDCLASS.
