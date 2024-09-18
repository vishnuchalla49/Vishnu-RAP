@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Root Entity Proj'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZVC_XX_TRAVEL_PROJ
  as projection on ZVC_XX_TRAVEL
{
          @ObjectModel.text.element: [ 'Description' ]
  key     TravelId,
          @ObjectModel.text.element: [ 'AgencyName' ]
          @Consumption.valueHelpDefinition: [{
              entity.name: '/DMO/I_Agency',
              entity.element: 'AgencyID'
           }]
          AgencyId,
          @Semantics.text: true
          _Agency.Name       as AgencyName,
          @ObjectModel.text.element: [ 'CustomerName' ]
          @Consumption.valueHelpDefinition: [{
              entity.name: '/DMO/I_Customer',
              entity.element: 'CustomerID'
           }]
          CustomerId,
          @Semantics.text: true
          _Customer.LastName as CustomerName,
          BeginDate,
          EndDate,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          BookingFee,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          TotalPrice,
          CurrencyCode,
          @Semantics.text: true
          Description,
          @Consumption.valueHelpDefinition: [{
              entity.name: '/DMO/I_Overall_Status_VH',
              entity.element: 'OverallStatus'
           }]
          @ObjectModel.text.element: [ 'StatusText' ]
          OverallStatus,
          @Semantics.user.createdBy: true
          CreatedBy,
          CreatedAt,
          @Semantics.user.lastChangedBy: true
          LastChangedBy,
          LastChangedAt,
          @Semantics.text: true
          StatusText,
          Criticality,
          /* Associations */
          _Agency,
          _Booking    : redirected to composition child zvc_xx_booking_proj,
          _Attachment : redirected to composition child ZVC_ATTACHMENT_VIEW_PROJ,
          _Currency,
          _Customer,
          _OverallStatus,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VC_CALC'
          @EndUserText.label: 'CO2 TAX'
  virtual CO2TAX         : abap.int4,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VC_CALC'
          @EndUserText.label: 'Week Day'
  virtual dayOfTheFlight : abap.char( 9 )

}
