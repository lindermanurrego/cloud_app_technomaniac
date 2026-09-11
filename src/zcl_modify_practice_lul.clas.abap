CLASS zcl_modify_practice_lul DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_modify_practice_lul IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*.Operacion de modificar creando entidades y se crea la entidad hija
*1->...  { FROM fields_tab }
*       CREATE, CREATE BY, UP☺DATE, DELETE, EXECUTE
*       For DELETE, EXECUTE we can use this option only
*       The %control structure must be filled explicitly in the internal table fields_tab for CREATE, CREATE BY and UPDATE

    DATA : lt_book TYPE TABLE FOR CREATE zi_travel_tech_m_l\_Booking.
*    MODIFY ENTITY zi_travel_tech_m_l
*      CREATE FROM VALUE #(
*                             ( %cid = 'cid1'
*                               %data-BeginDate = '20240225'
*                               %control-BeginDate = if_abap_behv=>mk-on
*      ) )
*     CREATE BY \_Booking
*        FROM VALUE #( ( %cid_ref = 'cid1'
*                                     %target  = VALUE #( ( %cid = 'cid11'
*                                                                          %data-bookingdate = '20240216'
*                                                                           %control-Bookingdate = if_abap_behv=>mk-on  ) )
*         ) )
*      FAILED FINAL(it_failed)
*      MAPPED FINAL(it_mapped)
*      REPORTED FINAL(it_result).
*
*    IF  it_failed IS NOT INITIAL.
*      out->write( it_failed ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.
***Al eliminar la entidad raiz se eliminan los hijos
**   MODIFY ENTITY zi_travel_tech_m_l
**   DELETE FROM VALUE #( (  %key-TravelId = '00004215'
**   ) ) FAILED FINAL(it_failed1)
**      MAPPED FINAL(it_mapped1)
**      REPORTED FINAL(it_result1).
**
**    IF  it_failed1 IS NOT INITIAL.
**      out->write( it_failed1 ).
**    ELSE.
**      COMMIT ENTITIES.
**    ENDIF.

***Al eliminar la entidad los hijos NO se elimina la entidad raiz
**   MODIFY ENTITY  ZI_BOOKING_TEC_M_L
**   DELETE FROM VALUE #( (  %key-TravelId = '00004217'
**                                               %key-BookingId = '0010'
**   ) ) FAILED FINAL(it_failed1)
**      MAPPED FINAL(it_mapped1)
**      REPORTED FINAL(it_result1).
**
**    IF  it_failed1 IS NOT INITIAL.
**      out->write( it_failed1 ).
**    ELSE.
**      COMMIT ENTITIES.
**    ENDIF.

*Crear las entidades pero con el AUTOCOMPLETADO del campo %cid
*2->   | { AUTO FILL CID WITH fields_tab }
*    MODIFY ENTITY zi_travel_tech_m_l
*        CREATE AUTO FILL CID WITH VALUE #(
*                  (  %data-BeginDate = '20240229'
*                    %control-BeginDate = if_abap_behv=>mk-on
*
*         ) )
*            FAILED FINAL(it_failed)
*         MAPPED FINAL(it_mapped)
*         REPORTED FINAL(it_result).
*
*    IF it_failed IS NOT INITIAL.
*      out->write( it_failed ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.

*Actualizando un campo de una entidad
*3->   | { [AUTO FILL CID] FIELDS ( comp1 comp2 ... ) WITH fields_tab }
*    MODIFY ENTITIES OF zi_travel_tech_m_l
*     ENTITY zi_travel_tech_m_l
*     UPDATE FIELDS ( BeginDate )
*     WITH VALUE #(  (  %key-TravelId = '00004243'
*                                      BeginDate     = '20240304'
*                                      )
*                                   ) .
*    COMMIT ENTITIES.


*Actualizando un campo de una entidad y eliminando una entidad en la misma declaracion
**4->   | { [AUTO FILL CID] FIELDS ( comp1 comp2 ... ) WITH fields_tab }
**    MODIFY ENTITIES OF zi_travel_tech_m_l
**     ENTITY zi_travel_tech_m_l
**     UPDATE FIELDS ( BeginDate )
**     WITH VALUE #(  (  %key-TravelId = '00004217'
**                                      BeginDate     = '20240304'
**                                      ) )
**       ENTITY zi_travel_tech_m_l
**       DELETE FROM VALUE #( (  TravelId  = '00004243'  ) )                                 .
**    COMMIT ENTITIES.

*Actualizando entidades de otra forma . Esta version no es muy recomendable por performance
*5->  | { [AUTO FILL CID] SET FIELDS WITH fields_tab } ...
    MODIFY ENTITY zi_travel_tech_m_l
    UPDATE SET FIELDS WITH VALUE #( ( %key-TravelId = '0000004217'
                                                                   BeginDate = '20240325' ) ).
    COMMIT ENTITIES.
  ENDMETHOD.
ENDCLASS.
