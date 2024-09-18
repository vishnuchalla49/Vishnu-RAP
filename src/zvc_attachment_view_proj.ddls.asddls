@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Attachment Proj'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZVC_ATTACHMENT_VIEW_PROJ as projection on zvc_attachment_view
{ 
  key TravelId,
  key Id,
  Memo,
  Attachment,
  Filename,
  Filetype,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt,
  /* Associations */
  _Travel:redirected to parent ZVC_XX_TRAVEL_PROJ
}
