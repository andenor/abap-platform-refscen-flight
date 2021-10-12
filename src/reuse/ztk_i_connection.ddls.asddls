@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Connection View - CDS Data Model'

@Search.searchable: true

define view entity ZTK_I_Connection
  as select from ZTK_connection as Connection
  
  association [1..1] to ZTK_I_Carrier as _Airline  on $projection.AirlineID = _Airline.AirlineID

{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @ObjectModel.text.association: '_Airline'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZTK_I_Carrier', element: 'CarrierID'} }]
  key Connection.carrier_id      as AirlineID,

      @Search.defaultSearchElement: true
  key Connection.connection_id   as ConnectionID,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZTK_I_Airport', element: 'Airport_ID' } }]
      Connection.airport_from_id as DepartureAirport,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZTK_I_Airport', element: 'Airport_ID' } }]
      Connection.airport_to_id   as DestinationAirport,

      Connection.departure_time  as DepartureTime,

      Connection.arrival_time    as ArrivalTime,

      @Semantics.quantity.unitOfMeasure: 'DistanceUnit'
      Connection.distance        as Distance,

      Connection.distance_unit   as DistanceUnit, 
      
      /* Associations */
      _Airline
}
