@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Status Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
 serviceQuality: #A,
 sizeCategory: #S,
 dataClass: #MASTER
 }
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZTKFK_I_Booking_Status_VH
  as select from ZTKFK_book_stat

  association [0..*] to ZTKFK_I_Booking_Status_VH_Text as _Text on $projection.BookingStatus = _Text.BookingStatus

{
      @UI.textArrangement: #TEXT_ONLY
      @UI.lineItem: [{importance: #HIGH}]
      @ObjectModel.text.association: '_Text'
  key booking_status as BookingStatus,

      _Text
}
