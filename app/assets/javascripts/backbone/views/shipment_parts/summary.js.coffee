class ShipX.Views.ShipmentPartsSummary extends Backbone.View

  initialize: (opts) ->
    @id = @$el.attr('data-id')
    @renumberLineItems();

  renumberLineItems: () ->
    for line_item, i in @$(".line-item")
      $(line_item).find(".numbered-col").text(i+1)
      for field in $(line_item).find("[data-field]")
        $(field).attr('name',"shipment[freight_items_attributes][#{i}][#{$(field).attr('data-field')}]")