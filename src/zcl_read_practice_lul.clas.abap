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


*Leyendo varias entidades a la vez
     READ ENTITIES OF zi_travel_tech_m_l
      ENTITY zi_travel_tech_m_l
      ALL FIELDS
      WITH VALUE #(  (   %key-TravelId = '00005002 ' )
                                   (    %key-TravelId = '00004136 '  ) )
      RESULT DATA(lt_result_travel)

      ENTITY ZI_BOOKING_TEC_M_L
        ALL FIELDS
        WITH VALUE #( ( %key-TravelId =  '00005002 '
                                      %key-BookingId = '0001 ' )
        )
        RESULT DATA(lt_result_booking)
      FAILED DATA(lt_failed_sort).
    IF lt_failed_sort IS NOT INITIAL.
      out->write( 'READ FAILED' ).
    ELSE.
         out->write( lt_result_travel ).
         out->write( lt_result_booking ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
