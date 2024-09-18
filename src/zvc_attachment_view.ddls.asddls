@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Attcahment View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity zvc_attachment_view
  as select from zvc_attachiu
  association to parent ZVC_XX_TRAVEL as _Travel on $projection.TravelId = _Travel.TravelId
{
  key travel_id             as TravelId,
      @EndUserText.label: 'Attachment Id'
  key id                    as Id,
      memo                  as Memo,
      @Semantics.largeObject:
      {
        mimeType: 'Filetype',
        fileName: 'Filename',
        contentDispositionPreference: #INLINE
      }
      @EndUserText.label: 'Attachment'
      attachment            as Attachment,
      @EndUserText.label: 'Filename'
      filename              as Filename,
      @Semantics.mimeType: true
      filetype              as Filetype,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _Travel
}
