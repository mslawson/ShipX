class ShipX.Views.ShipmentPartsResults extends Backbone.View

  initialize: (opts) ->
    @id = @$el.attr('data-id')
    console.log "results"


  events:
    'click .quote-row': 'selectQuote'

  selectQuote: (e) ->
    e.preventDefault()
    @$(".quote-row").removeClass('active')
    $(e.currentTarget).addClass('active')
    @$("#selected-carrier").val($(e.currentTarget).attr('data-id'))
    @$("#continue-button").attr('disabled',false)