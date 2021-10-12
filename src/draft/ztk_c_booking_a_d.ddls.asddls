@EndUserText.label: 'Booking Proj View for Draft RefScen'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZTK_C_Booking_A_D
  as projection on ZTK_I_Booking_D
{
  key BookingUUID,

      TravelUUID,

      @Search.defaultSearchElement: true
      BookingID,

      BookingDate,

      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZTK_I_Customer', element: 'CustomerID' }}]
      CustomerID,
      _Customer.LastName as CustomerName,

      @ObjectModel.text.element: ['CarrierName']
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZTK_I_Carrier', element: 'AirlineID' }}]
      AirlineID,
      _Carrier.Name      as CarrierName,

      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZTK_I_Flight', element: 'ConnectionID'},
                     additionalBinding: [ { localElement: 'FlightDate',   element: 'FlightDate'},
                                          { localElement: 'AirlineID',    element: 'AirlineID'},
                                          { localElement: 'FlightPrice',  element: 'Price', usage: #RESULT},
                                          { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT } ] } ]
      ConnectionID,

      FlightDate,

      
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZTK_I_Flight', element: 'ConnectionID'},
                     additionalBinding: [ { localElement: 'FlightDate',   element: 'FlightDate'},
                                          { localElement: 'AirlineID',    element: 'AirlineID'},
                                          { localElement: 'FlightPrice',  element: 'Price', usage: #RESULT },
                                          { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT } ] } ]
      FlightPrice,

      @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
      CurrencyCode,

      @ObjectModel.text.element: ['BookingStatusText']
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZTK_I_Booking_Status_VH', element: 'BookingStatus' }}]
      BookingStatus,
      _BookingStatus._Text.Text as BookingStatusText: localized, 

      LocalLastChangedAt,

      /* Associations */
      _BookingSupplement: redirected to composition child ZTK_C_BookingSupplement_A_D,
      _BookingStatus, 
      _Carrier,
      _Connection,
      _Customer,
      _Travel: redirected to parent ZTK_C_Travel_A_D
}
