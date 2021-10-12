@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transactional Carrier View'
@Metadata.ignorePropagatedAnnotations: true


define view entity ZTK_I_Carrier_S
  as select from ZTK_I_Carrier as Airline
  association        to parent ZTK_I_CarriersLockSingleton_S as _CarrierSingleton on $projection.CarrierSingletonID = _CarrierSingleton.CarrierSingletonID

{
  key AirlineID,
      1 as CarrierSingletonID,

      Name,

      CurrencyCode,

      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      LocalLastChangedBy,
      //local etag field --> odata etag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,

      //total etag field
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,

      /* Associations */
      _CarrierSingleton
}