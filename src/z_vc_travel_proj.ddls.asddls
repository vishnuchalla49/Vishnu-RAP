@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'proj'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z_VC_TRAVEL_PROJ
  as projection on Z_VC_TRAVEL
{
  key TravelId,
      @Consumption.valueHelpDefinition: [{
                    entity.name:'/DMO/I_AGENCY',
                    entity.element: 'AgencyID'
                    }]
      AgencyId,
      @Consumption.valueHelpDefinition: [{
                    entity.name:'/DMO/I_CUSTOMER',
                    entity.element: 'CustomerID'
                    }]
      CustomerID,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _Agency,
      _Attachment : redirected to composition child Z_VC_ATTACH_PROJ,
      _Currency,
      _Customer,
      _OverallStatus
}
