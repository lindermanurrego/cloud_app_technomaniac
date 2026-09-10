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
*.Operacion de modificar creando entidades
*1->...  { FROM fields_tab }
*       CREATE, CREATE BY, UP☺DATE, DELETE, EXECUTE
*       For DELETE, EXECUTE we can use this option only
*       The %control structure must be filled explicitly in the internal table fields_tab for CREATE, CREATE BY and UPDATE
    DATA : lt_book TYPE TABLE FOR CREATE zi_travel_tech_m_l\_Booking.
    MODIFY ENTITY zi_travel_tech_m_l
      CREATE FROM VALUE #(
                             ( %cid = 'cid1'
                               %data-BeginDate = '20240225'
                               %control-BeginDate = if_abap_behv=>mk-on
      ) )
     CREATE BY \_Booking
        FROM VALUE #( ( %cid_ref = 'cid1'
                                     %target  = VALUE #( ( %cid = 'cid11'
                                                                          %data-bookingdate = '20240216'
                                                                           %control-Bookingdate = if_abap_behv=>mk-on  ) )
         ) )
      FAILED FINAL(it_failed)
      MAPPED FINAL(it_mapped)
      REPORTED FINAL(it_result).

    IF  it_failed IS NOT INITIAL.
      out->write( it_failed ).
    ELSE.
      COMMIT ENTITIES.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
