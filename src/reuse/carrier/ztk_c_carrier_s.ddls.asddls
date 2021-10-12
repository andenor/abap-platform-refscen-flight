@EndUserText.label: 'Projection View Carrier'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['AirlineID']


define view entity ZTK_C_Carrier_S
  as projection on ZTK_I_Carrier_S
{
  key AirlineID,
  
      @Consumption.hidden: true
      CarrierSingletonID,
      
      Name,
      
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }, useForValidation: true }]
      CurrencyCode,
      
      LocalLastChangedAt,
      
      /* Associations */
      _CarrierSingleton : redirected to parent ZTK_C_CarriersLockSingleton_S
}
