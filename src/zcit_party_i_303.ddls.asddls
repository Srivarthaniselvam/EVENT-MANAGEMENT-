@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Event Participants - Interface'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZCIT_PARTY_I_303 
  as select from zcit_party_303
  association to parent ZCIT_EVENT_I_303 as _Event on $projection.EventId = _Event.EventId
{
    key event_id      as EventId,
    key part_id       as PartId,
    
    first_name        as FirstName,
    last_name         as LastName,
    email             as Email,
    
    @EndUserText.label: 'Ticket Type'
    ticket_type       as TicketType,
    
    reg_date          as RegDate,
    
    @Semantics.amount.currencyCode: 'CurrencyCode'
    amount_paid       as AmountPaid,
    
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
    currency_code     as CurrencyCode,
    
    /* Association back to Parent */
    _Event 
}
