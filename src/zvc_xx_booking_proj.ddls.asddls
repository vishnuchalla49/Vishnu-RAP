@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'booking proj'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zvc_xx_booking_proj
  as projection on ZVC_XX_BOOKING
{
  key TravelId,
  key BookingId,
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

      _Travel       : redirected to parent ZVC_XX_TRAVEL_PROJ,
      _BookingSuppl : redirected to composition child ZVC_XX_BOOKSUPPL_PROJ
}
