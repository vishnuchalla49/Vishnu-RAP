@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'proj'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity Z_VC_ATTACH_PROJ
  as projection on Z_VC_ATTACH
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
      _Travel : redirected to parent Z_VC_TRAVEL_PROJ
}
