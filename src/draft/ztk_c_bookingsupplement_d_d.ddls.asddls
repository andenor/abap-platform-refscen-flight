@EndUserText.label: 'BookingSuppl Proj View for Draft RefScen'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['BookingSupplementID']

define view entity ZTK_C_BookingSupplement_D_D
  as projection on ZTK_I_BookingSupplement_D
{
  key BookSupplUUID,

      TravelUUID,

      BookingUUID,

      @Search.defaultSearchElement: true
      BookingSupplementID,

      @ObjectModel.text.element: ['SupplementDescription']
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZTK_I_SUPPLEMENT', element: 'SupplementID' } ,
                     additionalBinding: [ { localElement: 'BookSupplPrice',  element: 'Price', usage: #RESULT },
                                          { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT }] }]
      SupplementID,
      _SupplementText.Description as SupplementDescription : localized,

      BookSupplPrice,

      @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
      CurrencyCode,

      LocalLastChangedAt,

      /* Associations */
      _Booking : redirected to parent ZTK_C_Booking_D_D,
      _Product,
      _SupplementText,
      _Travel  : redirected to ZTK_C_Travel_D_D
}