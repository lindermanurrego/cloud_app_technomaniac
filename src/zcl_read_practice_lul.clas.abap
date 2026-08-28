CLASS zcl_read_practice_lul DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_read_practice_lul IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.


*Leyendo solo algunos campos con la estructura de control
*    READ ENTITY zi_travel_tech_m_l
*      FROM VALUE #(  (   %key-TravelId = '00005002 '
*                                        %control = VALUE  #(    AgencyId         = if_abap_behv=>mk-on
*                                                                                CUSTOMERID  = if_abap_behv=>mk-on
*                                                                                BEGINDATE    = if_abap_behv=>mk-on
*                                        )
*                              ) )
*      RESULT DATA(lt_result_short)
*      FAILED DATA(lt_failed_sort).

*Leyendo todos los campos con la instruccion ALL FIELDS
*    READ ENTITY zi_travel_tech_m_l
*     ALL FIELDS
**    FIELDS ( AgencyId CreatedAt CustomerId )
*      WITH  VALUE #(  (   %key-TravelId = '00005002 ' )
*                                   (    %key-TravelId = '00004172 '  ) )
*      RESULT DATA(lt_result_short)
*      FAILED DATA(lt_failed_sort).


*Leyendo la asociacion
*    READ ENTITY zi_travel_tech_m_l
*    BY \_Booking
*     ALL FIELDS
**    FIELDS ( AgencyId CreatedAt CustomerId )
*      WITH  VALUE #(  (   %key-TravelId = '00005002 ' )
*                                   (    %key-TravelId = '00004136 '  ) )
*      RESULT DATA(lt_result_short)
*      FAILED DATA(lt_failed_sort).


*Leyendo varias entidades a la vez.
* Se debe siempre especificar toda la llave mirar el ejemplo en la entidad Booking
*    READ ENTITIES OF zi_travel_tech_m_l
*     ENTITY zi_travel_tech_m_l
*     ALL FIELDS
*     WITH VALUE #(  (   %key-TravelId = '00005002 ' )
*                                  (    %key-TravelId = '00004136 '  ) )
*     RESULT DATA(lt_result_travel)
*
*     ENTITY zi_booking_tec_m_l
*       ALL FIELDS
*       WITH VALUE #( ( %key-TravelId =  '00005002 '
*                                     %key-BookingId = '0001 ' )
*       )
*       RESULT DATA(lt_result_booking)
*     FAILED DATA(lt_failed_sort).
*
*    IF lt_failed_sort IS NOT INITIAL.
*      out->write( 'READ FAILED' ).
*    ELSE.
*      out->write( lt_result_travel ).
*      out->write( lt_result_booking ).
*    ENDIF.

*Leyendo entidades haciendo uso de la tabla de operacoines
    DATA:it_optab           TYPE abp_behv_retrievals_tab,
         it_travel          TYPE TABLE FOR READ IMPORT zi_travel_tech_m_l,
         it_travel_result   TYPE TABLE FOR READ RESULT zi_travel_tech_m_l,
         it_bookings        TYPE TABLE FOR READ IMPORT zi_travel_tech_m_l\_Booking,
         it_bookings_result TYPE TABLE FOR READ RESULT  zi_travel_tech_m_l\_Booking.


    it_travel = VALUE #(     (   %key-TravelId = '00005002'
                                              %control = VALUE  #(    AgencyId         = if_abap_behv=>mk-on
                                                                                     customerid  = if_abap_behv=>mk-on
                                                                                    begindate    = if_abap_behv=>mk-on
                                                                               )     )   ).
    it_bookings  = VALUE #(     (   %key-TravelId = '00005002'
                                                     %control = VALUE  #(   BookingDate  = if_abap_behv=>mk-on
                                                                                            BookingStatus    = if_abap_behv=>mk-on
                                                                                            BookingId        = if_abap_behv=>mk-on
                                                                                      )  ) ).


    it_optab = VALUE #( (  op = if_abap_behv=>op-r-read
                                           entity_name = 'ZI_TRAVEL_TECH_M_L'
                                           instances = REF #( it_travel )
                                           results    = REF #( it_travel_result )
                                           )
                                       (  op = if_abap_behv=>op-r-read_ba
                                           entity_name = 'ZI_TRAVEL_TECH_M_L'
                                           sub_name     = '_BOOKING'
                                           instances = REF #( it_bookings )
                                           results    = REF #( it_bookings_result )
                                           )
                                           )  .

    READ ENTITIES   OPERATIONS   it_optab
              FAILED DATA(lt_failed_sort).

    IF lt_failed_sort IS NOT INITIAL.
      out->write( 'READ FAILED' ).
    ELSE.
      out->write( it_travel_result ).
      out->write( it_bookings_result ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
