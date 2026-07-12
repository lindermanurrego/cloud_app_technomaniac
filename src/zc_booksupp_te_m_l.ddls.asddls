@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplements travel projection view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKSUPP_TE_M_L as projection on ZI_BOOKSUPP_TE_M_L
{
    key TravelId,
    key BookingId,
    key BookingSupplementId,
    @ObjectModel.text.element: [ 'SupplementDesc' ]
    SupplementId,
    _SupplementText.Description as SupplementDesc :localized,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    LastChangedAt,
    /* Associations */
    _Booking: redirected to parent ZC_BOOKING_TEC_M_L,
    _Supplement,
    _SupplementText,
    _Travel
}
