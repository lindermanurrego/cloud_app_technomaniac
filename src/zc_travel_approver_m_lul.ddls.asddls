@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approver projection travel'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true


@UI.headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travels',
    title: {
        type: #STANDARD,
        label: 'Travel',
        value: 'TravelId'
    }
}
define root view entity ZC_TRAVEL_APPROVER_M_LUL
  provider contract transactional_query
  as projection on ZI_TRAVEL_TECH_M_L
{
      @UI.facet: [{
            id: 'Travel',
            purpose: #STANDARD,
            position: 10,
            label: 'Travel',
            type: #IDENTIFICATION_REFERENCE
        },
        {
            id: 'Booking',
            purpose: #STANDARD,
            position: 20,
            label: 'Booking',
            type: #LINEITEM_REFERENCE,
             targetElement: '_Booking'
          }
        ]

      @UI:{ lineItem: [{  position : 10, importance:  #HIGH }],
                identification:[{ position: 10 }]
              }
      @Search.defaultSearchElement: true
  key TravelId,
      @UI:{ lineItem: [{  position : 20 }],
                selectionField: [{ position: 20 }],
                 identification:[{ position: 20 }]
              }
      @Consumption.valueHelpDefinition: [{  entity: {
                                                name: '/DMO/I_Agency',
                                                element: 'AgencyID'
                                            } }]
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Search.defaultSearchElement: true
      AgencyId,
      _Agency.Name       as AgencyName,
      @UI:{ lineItem: [{  position : 30 }],
               selectionField: [{ position: 30 }],
                identification:[{ position: 30 }]
             }
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{  entity: {
                                                 name: '/DMO/I_Customer',
                                                 element: 'CustomerID'
                                             } }]
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      _Customer.LastName as CustomerName,
      @UI.lineItem: [{  position : 40 }]
      BeginDate,
      @UI.lineItem: [{  position : 41 }]
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI.lineItem: [{  position : 42, importance: #MEDIUM }]
      @UI.identification: [{  position : 42 }]
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI.lineItem: [{  position : 43, importance: #MEDIUM }]
      @UI.identification: [{  position : 43 , label: 'Total Price'}]
      TotalPrice,
      @Consumption.valueHelpDefinition: [{  entity: {
                                                 name: 'I_Currency',
                                                 element: 'Currency'
                                             } }]
      CurrencyCode,
      @UI.lineItem: [{  position : 45, importance: #MEDIUM }]
      @UI.identification: [{  position : 45 , label: 'Total Price'}]
      Description,
      @UI:{
             lineItem: [{ position: 15, importance: #HIGH },
                              {type: #FOR_ACTION, dataAction: 'accepTravel',label: 'Accept Travel' },
                              {type: #FOR_ACTION, dataAction: 'rejectTravel',label: 'Reject Travel' }
                                   ],
              identification: [{ position:15  },
                                       {type: #FOR_ACTION, dataAction: 'accepTravel',label: 'Accept Travel' },
                                       {type: #FOR_ACTION, dataAction: 'rejectTravel',label: 'Reject Travel' }
                             ],
               textArrangement: #TEXT_ONLY,
               selectionField: [{ position: 40 }]
           }
      @EndUserText.label: 'Overall Status'
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Overall_Status_VH', element: 'OverallStatus' }}]
      @ObjectModel.text.element: ['OverallStatusText']
      OverallStatus,
      @UI.hidden: true
      _Status._Text.Text as OverallStatusText : localized,
      @UI.hidden: true
      CreatedBy,
      @UI.hidden: true
      CreatedAt,
      @UI.hidden: true
      LastChangedBy,
      @UI.hidden: true
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZC_BOOKING_APPROVER_M_LUL,
      _Currency,
      _Customer,
      _Status
}
