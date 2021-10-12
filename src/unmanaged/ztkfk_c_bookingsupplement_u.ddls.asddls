@EndUserText.label: 'Booking Supplement Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true

@Search.searchable: true
define view entity ZTKFK_C_BookingSupplement_U
  as projection on ZTKFK_I_BookingSupplement_U

{     //ZTKFK_I_BookingSupplement_U
      @Search.defaultSearchElement: true
  key TravelID,

      @Search.defaultSearchElement: true
  key BookingID,

  key BookingSupplementID,

      @Consumption.valueHelpDefinition: [ {entity: { name:    'ZTKFK_I_SUPPLEMENT',
                                                     element: 'SupplementID' },
                                           additionalBinding: [ { localElement: 'Price',        element: 'Price'},
                                                                { localElement: 'CurrencyCode', element: 'CurrencyCode' } ] } ]
      @ObjectModel.text.element: ['SupplementText']
      SupplementID,
      _SupplementText.Description as SupplementText : localized,

      Price,

      @Consumption.valueHelpDefinition: [ { entity: { name:    'I_Currency', 
                                                      element: 'Currency' } } ]
      CurrencyCode,

//      LastChangedAt,

      /* Associations */
      //ZTKFK_I_BookingSupplement_U
      _Booking : redirected to parent ZTKFK_C_Booking_U,
      _Travel  : redirected to ZTKFK_C_Travel_U ,         
      _Product,
      _SupplementText

}
