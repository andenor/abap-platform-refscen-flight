@EndUserText.label: 'Carrier Singleton Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['CarrierSingletonID']

define root view entity ZTKFK_C_CarriersLockSingleton_S
  provider contract transactional_query
  as projection on ZTKFK_I_CarriersLockSingleton_S
{
  key CarrierSingletonID,

      @Consumption.hidden: true
      LastChangedAtMax,
      /* Associations */
      _Airline : redirected to composition child ZTKFK_C_Carrier_S
}
