@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel BO for unmanaged'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
 serviceQuality: #X,
 sizeCategory: #S,
 dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity ZVC_XX_C_Travel
  as select from /dmo/travel as Travel
  association [1] to ZVC_XX_Agency           as _Agency       on $projection.AgencyId = _Agency.AgencyId
  association [1] to ZVC_XX_CUSTOMER         as _Customer     on $projection.CustomerId = _Customer.CustomerId
  association [1] to I_Currency              as _Currency     on $projection.CurrencyCode = _Currency.Currency
  association [1] to /DMO/I_Travel_Status_VH as _TravelStatus on $projection.TravelStatus = _TravelStatus.TravelStatus
{
      @ObjectModel.text.element: [ 'TravelId' ]
  key travel_id                                                             as TravelId,
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Consumption.valueHelpDefinition: [{ entity:{ name:'ZVC_XX_Agency',element:'AgencyId' }}]
      agency_id                                                             as AgencyId,
      _Agency.Name                                                          as AgencyName,
      @ObjectModel.text.element:[ 'CustomerName' ]
      @Consumption.valueHelpDefinition:[{ entity:{ name:'ZVC_XX_Customer', element:'CustomerId' }}]
      customer_id                                                           as CustomerId,
      _Customer.CustomerName                                                as CustomerName,
      begin_date                                                            as BeginDate,
      end_date                                                              as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee                                                           as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price                                                           as TotalPrice,
      currency_code                                                         as CurrencyCode,
      description                                                           as Description,
      @ObjectModel.text.element: [ '_TravelStatus' ]
      @Consumption.valueHelpDefinition: [{ entity: {name:'/dmo/i_travel_status_vh', element:'TravelStatus' } }]
      status                                                                as TravelStatus,
      _TravelStatus._Text[Language = $session.system_language].TravelStatus as TravelStatuss,
      createdby                                                             as Createdby,
      createdat                                                             as Createdat,
      lastchangedby                                                         as Lastchangedby,
      lastchangedat                                                         as Lastchangedat,
      _Agency,
      _Customer,
      _Currency,
      _TravelStatus

}
