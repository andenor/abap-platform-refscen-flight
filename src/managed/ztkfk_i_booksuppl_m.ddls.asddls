@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement View - CDS data model'

define view entity ZTKFK_I_BookSuppl_M 
  as select from ZTKFK_booksuppl_m as BookingSupplement

  association        to parent ZTKFK_I_Booking_M  as _Booking     on  $projection.travel_id    = _Booking.travel_id
                                                                 and $projection.booking_id   = _Booking.booking_id

  association [1..1] to ZTKFK_I_Travel_M       as _Travel         on  $projection.travel_id    = _Travel.travel_id
  association [1..1] to ZTKFK_I_Supplement     as _Product        on $projection.supplement_id = _Product.SupplementID
  association [1..*] to ZTKFK_I_SupplementText as _SupplementText on $projection.supplement_id = _SupplementText.SupplementID
{
  key travel_id,
  key booking_id,
  key booking_supplement_id,
      supplement_id,
      @Semantics.amount.currencyCode: 'currency_code'
      price,
      currency_code,
      
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at,

      /* Associations */
      _Travel, 
      _Booking,
      _Product, 
      _SupplementText    
} 
