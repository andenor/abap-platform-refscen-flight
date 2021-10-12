@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Carrier Singleton Root View'

define root view entity ZTK_I_CarriersLockSingleton_S
  as select from    I_Language
    left outer join ZTK_carrier as carr on 0 = 0
  composition [0..*] of ZTK_I_Carrier_S as _Airline

{
  key 1                          as CarrierSingletonID,
      max (carr.last_changed_at) as LastChangedAtMax, 

      _Airline
}

where
  I_Language.Language = $session.system_language
