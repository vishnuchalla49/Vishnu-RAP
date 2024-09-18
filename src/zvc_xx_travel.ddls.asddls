@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Root Entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZVC_XX_TRAVEL
  as select from /dmo/travel_m
  composition [0..*] of ZVC_XX_BOOKING           as _Booking
  composition [0..*] of zvc_attachment_view     as _Attachment
  association [1]    to /DMO/I_Agency               as _Agency     on $projection.AgencyId = _Agency.AgencyID
  association [1]    to /DMO/I_Customer             as _Customer   on $projection.CustomerId = _Customer.CustomerID
  association [1]    to I_Currency                  as _Currency   on $projection.CurrencyCode = _Currency.Currency
  association [1..1] to /DMO/I_Overall_Status_VH as _OverallStatus on $projection.OverallStatus = _OverallStatus.OverallStatus
{
  key travel_id       as TravelId,
      agency_id       as AgencyId,
      customer_id     as CustomerId,
      begin_date      as BeginDate,
      end_date        as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee     as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price     as TotalPrice,
      currency_code   as CurrencyCode,
      description     as Description,
      overall_status  as OverallStatus,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      //Local ETag Field --> Odata Etag
      last_changed_at as LastChangedAt,
      case overall_status
          when 'O' then 'Open'
          when 'A' then 'Approved'
          when 'R' then 'Rejected'
          when 'X' then 'Cancelled'
          end         as StatusText,
      case overall_status
          when 'O' then 1
          when 'A' then 3
          when 'R' then 2
          when 'X' then 2
          end         as Criticality,
      /*Expose associations*/
      _Booking,
      _Attachment,
      _Agency,
      _Customer,
      _Currency,
      _OverallStatus
}
