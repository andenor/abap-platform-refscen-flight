@AbapCatalog.sqlViewName: 'ZTKFK_CURRHLP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help View for Currency Conversion'
define view ZTKFK_CURRENCY_HELPER
  with parameters
    amount             : ZTKFK_total_price,
    source_currency    : ZTKFK_currency_code,
    target_currency    : ZTKFK_currency_code,
    exchange_rate_date : ZTKFK_booking_date

  as select from ZTKFK_agency

{
  key currency_conversion( amount             => $parameters.amount,
                           source_currency    => $parameters.source_currency,
                           target_currency    => $parameters.target_currency,
                           exchange_rate_date => $parameters.exchange_rate_date,
                           error_handling     => 'SET_TO_NULL' ) as ConvertedAmount
}
