CLASS lhc_zi_booksupp_te_m_l DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateCurrencyCode FOR VALIDATE ON SAVE
      keys FOR ZI_BOOKSUPP_TE_M_L~validateCurrencyCode.

    METHODS validatePrice FOR VALIDATE ON SAVE
      keys FOR ZI_BOOKSUPP_TE_M_L~validatePrice.

    METHODS validateSupplement FOR VALIDATE ON SAVE
      keys FOR ZI_BOOKSUPP_TE_M_L~validateSupplement.

ENDCLASS.

CLASS lhc_zi_booksupp_te_m_l IMPLEMENTATION.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validatePrice.
  ENDMETHOD.

  METHOD validateSupplement.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

