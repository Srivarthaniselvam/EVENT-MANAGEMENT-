@EndUserText.label: 'Event Management - Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZCIT_EVENT_C_303
  provider contract transactional_query
  as projection on ZCIT_EVENT_I_303
{
    @Search.defaultSearchElement: true
    key EventId,
    
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.8
    EventName,

    EventType,
    
    TypeCriticality, // Used for color logic
    
    EventDate,
    Location,
    
    Status,
    
    StatusCriticality, // Used for color logic
    
    MaxAttendees,
    TotalRevenue,
    
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
    CurrencyCode,
    
    Locallastchangedat,

    /* Association Redirection */
    _Participants : redirected to composition child ZCIT_PARTY_C_303
}
