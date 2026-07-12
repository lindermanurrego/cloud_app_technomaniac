@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking projection view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKING_TEC_M_L
  as projection on ZI_BOOKING_TEC_M_L
{
  key BookingId,
  key TravelId,
      BookingDate,
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      _Customer.LastName as CustomerName,
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId,
      _Carrier.Name as CarrierName,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      @ObjectModel.text.element: [ 'BookingStatusText' ]
      BookingStatus,
       _Status._Text.Text as BookingStatusText:localized,
      LastChangedAt,
      /* Associations */
      _Bookingsuppl : redirected to composition child ZC_BOOKSUPP_TE_M_L,
      _Carrier,
      _Connection,
      _Customer,
      _Status,
      _Travel       : redirected to parent ZC_TRAVEL_TECH_M_L
}
