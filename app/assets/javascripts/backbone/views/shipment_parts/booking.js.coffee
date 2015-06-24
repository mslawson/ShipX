class ShipX.Views.ShipmentPartsBooking extends Backbone.View

  initialize: (opts) ->
    @id = @$el.attr('data-id')
    @interval = setInterval(@checkStatus.bind(this), 2000)

  checkStatus: () =>
    $.get "/api/v1/shipments/#{@id}", (data) =>
      if data.status == 2 # "BOOKED" status
        @$("form").submit()
        clearInterval(@interval)
      else if data.status == 5 # "ERROR" status
        window.location = "/shipments/#{@id}/shipment_parts/payment/edit"