@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Event Header - Interface'

define root view entity ZCIT_EVENT_I_303 
  as select from zcit_event_303
  composition [0..*] of ZCIT_PARTY_I_303 as _Participants
{
    key event_id          as EventId,
    event_name            as EventName,
    
    @EndUserText.label: 'Event Type'
    event_type            as EventType,
    
    // FIX: Use upper() to handle "party" vs "PARTY"
    case upper(event_type)
      when 'MARRAIGE'       then 3 
      when 'PARTY'          then 3 
      when 'BIRTHDAY'       then 3 
      when 'BABY SHOWER'    then 3 
      when 'GET TO GETHER'  then 3 
      when 'FAREWELL'       then 2 
      when 'CONFERENCE'     then 1 
      when 'WORKSHOP'       then 2 
      else 0 
    end                   as TypeCriticality,

    event_date            as EventDate,
    location              as Location,
    
    status                as Status,
    // FIX: Use upper() here as well for consistency
    case upper(status)
      when 'O' then 3 
      when 'D' then 2 
      when 'C' then 1 
      else 0 
    end                   as StatusCriticality,

    max_attendees         as MaxAttendees,
    
    @Semantics.amount.currencyCode: 'CurrencyCode'
    total_revenue         as TotalRevenue,
    currency_code         as CurrencyCode,
    
    localcreatedby        as Localcreatedby,
    localcreatedat        as Localcreatedat,
    locallastchangedby    as Locallastchangedby,
    locallastchangedat    as Locallastchangedat,
    lastchangedat         as Lastchangedat,
    
    _Participants 
}
