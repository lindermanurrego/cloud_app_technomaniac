@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approver projection booking'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_BOOKING_APPROVER_M_LUL as projection on ZI_BOOKING_TEC_M_L
{
    key BookingId,
    key TravelId,
    BookingDate,
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
@Semantics.amount.currencyCode: 'CurrencyCode'        
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LastChangedAt,
    /* Associations */
    _Bookingsuppl,
    _Carrier,
    _Connection,
    _Customer,
    _Status,
    _Travel: redirected to  parent ZC_TRAVEL_APPROVER_M_LUL 
}
