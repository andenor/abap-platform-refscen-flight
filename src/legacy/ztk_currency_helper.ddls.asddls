@AbapCatalog.sqlViewName: 'ZTK_CURRHLP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help View for Currency Conversion'
define view ZTK_CURRENCY_HELPER
  with parameters
    amount             : ZTK_total_price,
    source_currency    : ZTK_currency_code,
    target_currency    : ZTK_currency_code,
    exchange_rate_date : ZTK_booking_date

  as select from ZTK_agency

{
  key currency_conversion( amount             => $parameters.amount,
                           source_currency    => $parameters.source_currency,
                           target_currency    => $parameters.target_currency,
                           exchange_rate_date => $parameters.exchange_rate_date,
                           error_handling     => 'SET_TO_NULL' ) as ConvertedAmount
}
