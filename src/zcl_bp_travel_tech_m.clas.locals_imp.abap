CLASS lsc_zi_travel_tech_m_l DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_travel_tech_m_l IMPLEMENTATION.

  METHOD save_modified.
    DATA : lt_travel_log   TYPE STANDARD TABLE OF zlog_travel_m_lu,
           lt_travel_log_c TYPE STANDARD TABLE OF zlog_travel_m_lu.

    IF create-zi_travel_tech_m_l IS NOT INITIAL.

      lt_travel_log = CORRESPONDING #(   create-zi_travel_tech_m_l  ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log>) .

        <ls_travel_log>-changing_operation = 'CREATE'.
        GET TIME STAMP FIELD <ls_travel_log>-created_at.

        READ TABLE create-zi_travel_tech_m_l ASSIGNING FIELD-SYMBOL(<ls_travel>)
                                                                         WITH TABLE KEY  entity
                                                                         COMPONENTS  TravelId = <ls_travel_log>-travelid.

        IF sy-subrc  IS INITIAL.
          IF <ls_travel>-%control-BookingFee = cl_abap_behv=>flag_changed.
            <ls_travel_log>-changed_field_name = 'Booking_Fee'.
            <ls_travel_log>-changed_value         = <ls_travel>-BookingFee.
            TRY.
                <ls_travel_log>-change_id                = cl_system_uuid=>create_uuid_x16_static(   ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
            APPEND <ls_travel_log> TO lt_travel_log_c.
          ENDIF.

          IF <ls_travel>-%control-OverallStatus = cl_abap_behv=>flag_changed.
            <ls_travel_log>-changed_field_name = 'OverallStatus'.
            <ls_travel_log>-changed_value         = <ls_travel>-OverallStatus.
            TRY.
                <ls_travel_log>-change_id                = cl_system_uuid=>create_uuid_x16_static(   ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
            APPEND <ls_travel_log> TO lt_travel_log_c.
          ENDIF.
        ENDIF.
      ENDLOOP.

      INSERT zlog_travel_m_lu FROM TABLE @lt_travel_log_c.

    ENDIF.

    IF  update-zi_travel_tech_m_l IS NOT INITIAL.

    ENDIF.
    IF delete-zi_travel_tech_m_l IS NOT INITIAL.

    ENDIF.


  ENDMETHOD.

ENDCLASS.

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

    METHODS recalcTotPrice FOR MODIFY
       keys FOR ACTION zi_travel_tech_m_l~recalcTotPrice.

    METHODS rejecttravel FOR MODIFY
       keys FOR ACTION zi_travel_tech_m_l~rejecttravel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR zi_travel_tech_m_l RESULT result.
    METHODS validatecustomer FOR VALIDATE ON SAVE
       keys FOR zi_travel_tech_m_l~validatecustomer.
    METHODS validatebookingfee FOR VALIDATE ON SAVE
       keys FOR zi_travel_tech_m_l~validatebookingfee.

    METHODS validatecurrencycode FOR VALIDATE ON SAVE
       keys FOR zi_travel_tech_m_l~validatecurrencycode.

    METHODS validatedates FOR VALIDATE ON SAVE
       keys FOR zi_travel_tech_m_l~validatedates.

    METHODS validatestatus FOR VALIDATE ON SAVE
       keys FOR zi_travel_tech_m_l~validatestatus.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
       keys FOR zi_travel_tech_m_l~calculatetotalprice.

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
          APPEND CORRESPONDING #( <fs_booking> ) TO  mapped-zi_booking_tec_m_l
                         ASSIGNING FIELD-SYMBOL(<ls_new_map_book>).
          IF <fs_booking>-BookingId IS INITIAL.
            lv_max_booking += 10.
            <ls_new_map_book>-BookingId = lv_max_booking.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD accepTravel.

    MODIFY ENTITIES OF zi_travel_tech_m_l IN LOCAL MODE
      ENTITY zi_travel_tech_m_l
       UPDATE FIELDS ( OverallStatus )
       WITH VALUE #( FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                           OverallStatus = 'A' ) ).

    READ ENTITIES OF zi_travel_tech_m_l IN LOCAL MODE
    ENTITY zi_travel_tech_m_l
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).
    .
    result  = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                 %param  =  ls_result ) ).

  ENDMETHOD.
*Este metodo realizara la copia de un viaje y todas las reservas y suplementos asociados
  METHOD copyTravel.

    DATA:it_travel        TYPE TABLE FOR CREATE zi_travel_tech_m_l,
         it_booking_cba   TYPE TABLE FOR CREATE zI_TRAVEL_TECH_M_L\_Booking,
         it_booksuppl_cba TYPE TABLE FOR CREATE zi_booking_tec_m_l\_Bookingsuppl.

*..Verificar que no hay cid vacios
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_with_out_cid>) WITH KEY %cid =  ' '.
    ASSERT <ls_with_out_cid> IS NOT ASSIGNED.
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
*..Crear la entidad haciendouso de MODIFY


    MODIFY ENTITIES OF zi_travel_tech_m_l IN LOCAL MODE
    ENTITY zi_travel_tech_m_l
    CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus Description )
    WITH it_travel
    ENTITY zi_travel_tech_m_l
     CREATE BY \_Booking
     FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus )
     WITH it_booking_cba
    ENTITY zi_booking_tec_m_l
     CREATE BY \_Bookingsuppl
     FIELDS ( BookingSupplementId SupplementId Price CurrencyCode )
     WITH it_booksuppl_cba
     MAPPED DATA(it_mapped).

    mapped-zi_travel_tech_m_l           = it_mapped-zi_travel_tech_m_l.
    mapped-zi_booking_tec_m_l   = it_mapped-zi_booking_tec_m_l .
    mapped-zi_booksupp_te_m_l   = it_mapped-zi_booksupp_te_m_l.


  ENDMETHOD.

  METHOD recalcTotPrice.

    TYPES: BEGIN OF ty_total,
             price TYPE  /dmo/flight_price,
             curr  TYPE : /dmo/currency_code,
           END OF ty_total.

    DATA: lt_total      TYPE TABLE OF ty_total,
          lv_conv_price TYPE /dmo/flight_price.
    READ ENTITIES OF zi_travel_tech_m_l IN LOCAL MODE
       ENTITY zi_travel_tech_m_l
       FIELDS ( BookingFee CurrencyCode )
       WITH CORRESPONDING #(  keys  )
       RESULT DATA(lt_travel).

    READ ENTITIES OF zi_travel_tech_m_l IN LOCAL MODE
       ENTITY zi_travel_tech_m_l BY \_Booking
       FIELDS ( FlightPrice CurrencyCode )
       WITH CORRESPONDING #(  lt_travel  )
       RESULT DATA(lt_ba_booking).

    READ ENTITIES OF zi_travel_tech_m_l  IN LOCAL MODE
       ENTITY zi_booking_tec_m_l BY \_Bookingsuppl
       FIELDS ( Price CurrencyCode )
       WITH CORRESPONDING #(  lt_ba_booking  )
       RESULT DATA(lt_ba_booksuppl).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      lt_total = VALUE #(   ( price = <ls_travel>-BookingFee curr = <ls_travel>-CurrencyCode )   ).
      LOOP AT lt_ba_booking ASSIGNING FIELD-SYMBOL(<ls_booking>)
*                                                 USING KEY entity
                                                 WHERE TravelId = <ls_travel>-TravelId
                                                    AND CurrencyCode IS NOT INITIAL.
        APPEND VALUE #( price = <ls_booking>-FlightPrice curr = <ls_booking>-CurrencyCode )
           TO lt_total.
        LOOP AT lt_ba_booksuppl ASSIGNING FIELD-SYMBOL(<ls_booksuppl>)
                                                 USING KEY entity
                                                   WHERE TravelId = <ls_booking>-TravelId
                                                          AND BookingId = <ls_booking>-BookingId.
          APPEND VALUE #( price = <ls_booksuppl>-Price curr = <ls_booksuppl>-CurrencyCode )
             TO lt_total.
        ENDLOOP.
      ENDLOOP.
*Recorre la tabla sumando los totales
      LOOP AT lt_total ASSIGNING FIELD-SYMBOL(<ls_total>).
        IF <ls_total>-curr = <ls_travel>-CurrencyCode.
          lv_conv_price = <ls_total>-price.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = <ls_total>-price
              iv_currency_code_source = <ls_total>-curr
              iv_currency_code_target = <ls_travel>-CurrencyCode
              iv_exchange_rate_date   =  cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = lv_conv_price
          ).

        ENDIF.
        <ls_travel>-TotalPrice =  <ls_travel>-TotalPrice + lv_conv_price.
      ENDLOOP.
      CLEAR lt_total.
    ENDLOOP.    "Loop que recorre todas las entidades padres

*..Actualiza el totalprice de todas las entidades
    MODIFY ENTITIES OF zi_travel_tech_m_l IN LOCAL MODE
    ENTITY zi_travel_tech_m_l
    UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( lt_travel ).
  ENDMETHOD.

  METHOD rejectTravel.
    MODIFY ENTITIES OF zi_travel_tech_m_l IN LOCAL MODE
    ENTITY zi_travel_tech_m_l
     UPDATE FIELDS ( OverallStatus )
     WITH VALUE #( FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                         OverallStatus = 'X' ) ).

    READ ENTITIES OF zi_travel_tech_m_l IN LOCAL MODE
    ENTITY zi_travel_tech_m_l
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).
    .
    result  = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                 %param  =  ls_result ) ).



  ENDMETHOD.
*Implementacion de las caracteristicas : Habilita o deshabilita los botones de acuerdo al estado
  METHOD get_instance_features.

    READ ENTITIES OF zi_travel_tech_m_l  IN LOCAL MODE
                       ENTITY zi_travel_tech_m_l
      FIELDS ( TravelId OverallStatus )
   WITH CORRESPONDING  #(  keys )
   RESULT DATA(lt_travel).

    result = VALUE #(  FOR ls_travel IN lt_travel
                                   (  %tky = ls_travel-%tky
                                      %features-%action-accepTravel = COND #(  WHEN ls_travel-OverallStatus = 'A'
                                                                                                               THEN if_abap_behv=>fc-o-disabled
                                                                                                               ELSE  if_abap_behv=>fc-o-enabled
                                                                                                                  )
                                         %features-%action-rejectTravel = COND #(  WHEN ls_travel-OverallStatus = 'X'
                                                                                                               THEN if_abap_behv=>fc-o-disabled
                                                                                                               ELSE  if_abap_behv=>fc-o-enabled
                                                                                                                  )
                                         %features-%assoc-_Booking      = COND #(  WHEN ls_travel-OverallStatus = 'X'
                                                                                                               THEN if_abap_behv=>fc-o-disabled
                                                                                                               ELSE  if_abap_behv=>fc-o-enabled
                                                                                                                  )
                                        )
                               ).
  ENDMETHOD.
  METHOD validateCustomer.
    DATA: lt_cust TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

*..Leer los clientes de las entidades
    READ ENTITIES OF zi_travel_tech_m_l  IN LOCAL MODE
                       ENTITY zi_travel_tech_m_l
      FIELDS ( CustomerId )
   WITH CORRESPONDING  #(  keys )
   RESULT DATA(lt_travel).

*..Elimianr duplicados
    lt_cust = CORRESPONDING #(   lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId ).
    DELETE  lt_cust WHERE customer_id  IS INITIAL.
*..Traer los clientes de la BD
    IF lt_cust IS NOT INITIAL.
      SELECT
      FROM /dmo/customer
      FIELDS customer_id
      FOR ALL ENTRIES IN @lt_cust
      WHERE customer_id = @lt_cust-customer_id
      INTO TABLE @DATA(lt_cust_db).

      IF sy-subrc IS INITIAL.
        LOOP AT lt_travel ASSIGNING   FIELD-SYMBOL(<ls_travel>).

          IF  <ls_travel>-CustomerId IS INITIAL OR NOT line_exists( lt_cust_db[ customer_id = <ls_travel>-CustomerId ]   ) .
            APPEND VALUE #(  %tky = <ls_travel>-%tky  ) TO failed-zi_booking_tec_m_l.
            APPEND VALUE #(  %tky = <ls_travel>-%tky
                                            %msg = NEW /dmo/cm_flight_messages(
                                                               textid = /dmo/cm_flight_messages=>customer_unkown
                                                               customer_id = <ls_travel>-CustomerId
                                                               severity         =  if_abap_behv_message=>severity-error
                                            )
                                            %element-CustomerId =  if_abap_behv=>mk-on
            ) TO reported-zi_booking_tec_m_l.

          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD validateBookingFee.
  ENDMETHOD.

  METHOD validateCurrencyCode.



  ENDMETHOD.

  METHOD validateDates.
    READ ENTITIES OF zi_travel_tech_m_l  IN LOCAL MODE
      ENTITY zi_travel_tech_m_l
      FIELDS (  BeginDate  EndDate )
     WITH CORRESPONDING  #(  keys )
       RESULT DATA(lt_travels).


    LOOP AT lt_travels INTO DATA(ls_travel).
      IF ls_travel-EndDate < ls_travel-BeginDate .
        APPEND VALUE #(  %tky = ls_travel-%tky  ) TO failed-zi_booking_tec_m_l.
        APPEND VALUE #(  %tky = ls_travel-%tky
                                        %msg = NEW /dmo/cm_flight_messages(
                                                           textid = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                                           begin_date = ls_travel-BeginDate
                                                           end_date    = ls_travel-EndDate
                                                           severity         =  if_abap_behv_message=>severity-error
                                        )
                                        %element-BeginDate =  if_abap_behv=>mk-on
                                        %element-endDate =  if_abap_behv=>mk-on
        ) TO reported-zi_travel_tech_m_l.
      ELSEIF   ls_travel-BeginDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #(  %tky = ls_travel-%tky  ) TO failed-zi_booking_tec_m_l.
        APPEND VALUE #(  %tky = ls_travel-%tky
                                        %msg = NEW /dmo/cm_flight_messages(
                                                           textid = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                                           begin_date = ls_travel-BeginDate
                                                           severity         =  if_abap_behv_message=>severity-error
                                        )
                                        %element-BeginDate =  if_abap_behv=>mk-on
        ) TO reported-zi_travel_tech_m_l.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITIES OF zi_travel_tech_m_l  IN LOCAL MODE
      ENTITY zi_travel_tech_m_l
      FIELDS (  OverallStatus )
     WITH CORRESPONDING  #(  keys )
       RESULT DATA(lt_travels).

    LOOP AT lt_travels INTO DATA(ls_travel).

      CASE ls_travel-OverallStatus.
        WHEN 'O'.
        WHEN 'X'.
        WHEN 'A'.
        WHEN  OTHERS.
          APPEND VALUE #(  %tky = ls_travel-%tky  ) TO failed-zi_booking_tec_m_l.
          APPEND VALUE #(  %tky = ls_travel-%tky
                                          %msg = NEW /dmo/cm_flight_messages(
                                                             textid = /dmo/cm_flight_messages=>status_invalid
                                                             status = ls_travel-OverallStatus
                                                             severity         =  if_abap_behv_message=>severity-error
                                          )
                                          %element-OverallStatus =  if_abap_behv=>mk-on
          ) TO reported-zi_travel_tech_m_l.
      ENDCASE.
    ENDLOOP.



  ENDMETHOD.

  METHOD calculateTotalPrice.

    MODIFY ENTITIES OF zi_travel_tech_m_l IN LOCAL MODE
       ENTITY zi_travel_tech_m_l
       EXECUTE recalcTotPrice
       FROM  CORRESPONDING #(  keys ).
  ENDMETHOD.

ENDCLASS.
