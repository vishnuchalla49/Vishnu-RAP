@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ATTACH'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity Z_VC_ATTACH
  as select from zvc_attach
  association to parent Z_VC_TRAVEL as _Travel on $projection.TravelId = _Travel.TravelId
{
  key travel_id             as TravelId,
  key id                    as Id,
      memo                  as Memo,
      @Semantics.largeObject:
      {
        mimeType:'Filetype',
        fileName:'Filename',
        contentDispositionPreference:#INLINE
      }
      @EndUserText.label: 'Attachment'
      attachment            as Attachment,
      filename              as Filename,
      @Semantics.mimeType: true
      filetype              as Filetype,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt,
      _Travel
}
