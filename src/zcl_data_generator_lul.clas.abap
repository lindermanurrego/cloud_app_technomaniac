CLASS zcl_data_generator_lul DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_data_generator_lul IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

      " delete existing entries in the database table
    DELETE FROM ztravel_tech_m_l.
    DELETE FROM zbooking_tec_m_l .
    DELETE FROM zbooksupp_te_m_l.
    COMMIT WORK.
    " insert travel demo data
    INSERT ztravel_tech_m_l  FROM (
        SELECT *
          FROM /dmo/travel_m
      ).
    COMMIT WORK.

    " insert booking demo data
    INSERT zbooking_tec_lul  FROM (
        SELECT *
          FROM   /dmo/booking_m
*            JOIN ytravel_tech_m AS y
*            ON   booking~travel_id = y~travel_id

      ).
    COMMIT WORK.
    INSERT zbooksupp_te_m_l FROM (
        SELECT *
          FROM   /dmo/booksuppl_m
*            JOIN ytravel_tech_m AS y
*            ON   booking~travel_id = y~travel_id

      ).
    COMMIT WORK.

    out->write( 'Travel and booking demo data inserted.').
  ENDMETHOD.
ENDCLASS.
