@EndUserText.label: 'Booking Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true

@Search.searchable: true
define view entity ZTK_C_Booking_U
  as projection on ZTK_I_Booking_U

{      //ZTK_I_Booking_U
      @Search.defaultSearchElement: true
  key TravelID,
 
      @Search.defaultSearchElement: true
  key BookingID,

      BookingDate,

      @Consumption.valueHelpDefinition: [ { entity: { name:    'ZTK_I_Customer', 
                                                     element: 'CustomerID' } } ]
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['CustomerName']
      CustomerID,
      _Customer.LastName    as CustomerName,

      @Consumption.valueHelpDefinition: [ { entity: { name:    'ZTK_I_Carrier', 
                                                      element: 'AirlineID' } } ]
      @ObjectModel.text.element: ['AirlineName']
      AirlineID,
      _Carrier.Name     as AirlineName,

      @Consumption.valueHelpDefinition: [ { entity: { name:    'ZTK_I_Flight', 
                                                      element: 'ConnectionID' },
                                            additionalBinding: [ { localElement: 'FlightDate',   element: 'FlightDate' },
                                                                 { localElement: 'AirlineID',    element: 'AirlineID' },
                                                                 { localElement: 'FlightPrice',  element: 'Price'  },
                                                                 { localElement: 'CurrencyCode', element: 'CurrencyCode' } ] } ]
      ConnectionID,
      
      @Consumption.valueHelpDefinition: [ { entity: { name:    'ZTK_I_Flight', 
                                                      element: 'FlightDate' },
                                            additionalBinding: [ { localElement: 'ConnectionID', element: 'ConnectionID' },
                                                                 { localElement: 'AirlineID',    element: 'AirlineID' },
                                                                 { localElement: 'FlightPrice',  element: 'Price' },
                                                                 { localElement: 'CurrencyCode', element: 'CurrencyCode' } ] } ]
      FlightDate,
      
      FlightPrice,
      
      @Consumption.valueHelpDefinition: [ {entity: { name:    'I_Currency', 
                                                     element: 'Currency' } } ]
      CurrencyCode,
      
//      LastChangedAt,
      /* Associations */
      //ZTK_I_Booking_U
      _Travel: redirected to parent ZTK_C_Travel_U,
      _BookSupplement: redirected to composition child ZTK_C_BookingSupplement_U,
      _Carrier,
      _Connection,
      _Customer
}
