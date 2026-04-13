@EndUserText.label: 'Participants - Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true // Ensure this is exactly like this

define view entity ZCIT_PARTY_C_303
  as projection on ZCIT_PARTY_I_303
{
    key EventId,
    key PartId,
    
    @Search.defaultSearchElement: true // This requires @Search.searchable: true above
    @Search.fuzzinessThreshold: 0.8
    FirstName,

    @Search.defaultSearchElement: true
    LastName,
    
    @Search.defaultSearchElement: true
    Email,
    
    TicketType,
    RegDate,
    
    @Semantics.amount.currencyCode: 'CurrencyCode'
    AmountPaid,
    
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
    CurrencyCode,

    /* Association Redirection */
    _Event : redirected to parent ZCIT_EVENT_C_303
}
