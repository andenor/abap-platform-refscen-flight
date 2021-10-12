@EndUserText.label: 'Travel Projection View for Draft RefScen'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZTKFK_C_Travel_A_D
  provider contract transactional_query
  as projection on ZTKFK_I_Travel_D

{
  key TravelUUID,

      @Search.defaultSearchElement: true
      TravelID,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['AgencyName']
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZTKFK_I_Agency', element: 'AgencyID'  } }]
      AgencyID,
      _Agency.Name       as AgencyName,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['CustomerName']
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZTKFK_I_Customer', element: 'CustomerID'  } }]
      CustomerID,
      _Customer.LastName as CustomerName,

      BeginDate,

      EndDate,

      BookingFee,

      TotalPrice,

      @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
      CurrencyCode,

      Description,
      
      @ObjectModel.text.element: ['OverallStatusText']
      @Consumption.valueHelpDefinition: [{ entity: {name: 'ZTKFK_I_Overall_Status_VH', element: 'OverallStatus' } }]      
      OverallStatus,
      _OverallStatus._Text.Text as OverallStatusText : localized, 
      

      LocalLastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZTKFK_C_Booking_A_D,
      _Currency,
      _OverallStatus, 
      _Customer
}
