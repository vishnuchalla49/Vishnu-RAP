@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BookSuppl view Proj'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZVC_XX_BOOKSUPPL_PROJ
  as projection on ZVC_XX_BOOKSUPPL
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to parent zvc_xx_booking_proj,
      _Travel  : redirected to ZVC_XX_TRAVEL_PROJ

}
