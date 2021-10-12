@EndUserText.label: 'Travel Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true

@Search.searchable: true
define root view entity ZTKFK_C_Travel_U
  provider contract transactional_query
  as projection on ZTKFK_I_Travel_U

{     //ZTKFK_I_Travel_U

  key TravelID,

      @Consumption.valueHelpDefinition: [{ entity: { name:    'ZTKFK_I_Agency',
                                                     element: 'AgencyID' } }]
      @ObjectModel.text.element: ['AgencyName']
      @Search.defaultSearchElement: true
      AgencyID,
      _Agency.Name       as AgencyName,

      @Consumption.valueHelpDefinition: [{ entity: { name:    'ZTKFK_I_Customer',
                                                     element: 'CustomerID'  } }]
      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      CustomerID,
      _Customer.LastName as CustomerName,

      BeginDate,

      EndDate,

      BookingFee,

      TotalPrice,

      @Consumption.valueHelpDefinition: [{entity: { name:    'I_Currency',
                                                    element: 'Currency' } }]
      CurrencyCode,

      Memo,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZTKFK_I_Travel_Status_VH', element: 'TravelStatus' }}]
      @ObjectModel.text.element: ['StatusText']  
      Status,
      
      _TravelStatus._Text.Text as StatusText : localized,

      LastChangedAt,
      /* Associations */
      //ZTKFK_I_Travel_U
      _Booking : redirected to composition child ZTKFK_C_Booking_U,
      _Agency,
      _Currency,
      _Customer,
      _TravelStatus
      
     
}

