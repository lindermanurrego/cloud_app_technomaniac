@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplements'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BOOKSUPP_TE_M_L as select from zbooksupp_te_m_l
  association to parent ZI_BOOKING_TEC_M_L as _Booking on $projection.TravelId       = _Booking.TravelId
                                                                                                  and $projection.BookingId = _Booking.BookingId
  association[1..1] to ZI_TRAVEL_TECH_M_L as _Travel on $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement as _Supplement   on $projection.SupplementId = _Supplement.SupplementID
  association [1..*] to /DMO/I_SupplementText as _SupplementText   on $projection.SupplementId = _SupplementText.SupplementID
  
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      last_changed_at       as LastChangedAt,
      _Travel,
      _Booking,
      _Supplement,
      _SupplementText 
}
