@EndUserText.label: 'Carrier Singleton Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['CarrierSingletonID']

define root view entity ZTK_C_CarriersLockSingleton_S
  provider contract transactional_query
  as projection on ZTK_I_CarriersLockSingleton_S
{
  key CarrierSingletonID,

      @Consumption.hidden: true
      LastChangedAtMax,
      /* Associations */
      _Airline : redirected to composition child ZTK_C_Carrier_S
}
