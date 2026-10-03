CLASS lhc_zi_booksupp_te_m_l DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateCurrencyCode FOR VALIDATE ON SAVE
      keys FOR ZI_BOOKSUPP_TE_M_L~validateCurrencyCode.

    METHODS validatePrice FOR VALIDATE ON SAVE
      keys FOR ZI_BOOKSUPP_TE_M_L~validatePrice.

    METHODS validateSupplement FOR VALIDATE ON SAVE
      keys FOR ZI_BOOKSUPP_TE_M_L~validateSupplement.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      keys FOR ZI_BOOKSUPP_TE_M_L~calculateTotalPrice.

ENDCLASS.

CLASS lhc_zi_booksupp_te_m_l IMPLEMENTATION.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validatePrice.
  ENDMETHOD.

  METHOD validateSupplement.
  ENDMETHOD.

  METHOD calculateTotalPrice.
      DATA: it_travel TYPE STANDARD TABLE OF zi_travel_tech_m_l WITH UNIQUE HASHED KEY KEY COMPONENTS TravelId.

       it_travel = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING  TravelId = TravelId  ).
        MODIFY ENTITIES OF zi_travel_tech_m_l IN LOCAL MODE
         ENTITY zi_travel_tech_m_l
         EXECUTE recalcTotPrice
         FROM  CORRESPONDING #(  it_travel ).
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

