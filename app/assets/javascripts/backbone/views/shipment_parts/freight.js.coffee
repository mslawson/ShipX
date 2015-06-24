class ShipX.Views.ShipmentPartsFreight extends Backbone.View

  initialize: (opts) ->
    console.log "start freight"
    @render()
    @renumberLineItems()

  events:
    'click #add-freight': 'addFreightLineItem'
    'click .remove-freight': 'removeFreightLineItem'
    'change .freight-class': 'checkFreightClass'
    'change .freight-type': 'checkFreightType'
    'blur .dim': 'checkFreightClass'

  render: () ->
    if $(".line-items").find(".line-item").length == 0
      @addFreightLineItem(null)

  addFreightLineItem: (e) ->
    @$(".line-item-template").clone().css('display','block').removeClass('line-item-template').appendTo(".line-items")
    @renumberLineItems()

  removeFreightLineItem: (e) ->
    if confirm("Are you sure?")
      $(e.currentTarget).closest('.line-item').remove()

  renumberLineItems: () ->
    for line_item, i in @$(".line-item:not(.line-item-template)")
      $(line_item).find(".numbered-col").text(i+1)
      for field in $(line_item).find("[data-field]")
        if $(field).attr('data-field').slice(-2) == "[]"
          str = $(field).attr('data-field')
          sub = str.substring(0,str.length-2)
          $(field).attr('name',"shipment[freight_items_attributes][#{i}][#{sub}][]")
        else
          $(field).attr('name',"shipment[freight_items_attributes][#{i}][#{$(field).attr('data-field')}]")

    #shipment[freight_items_attributes][0][weight_unit]

  checkFreightType: (e) ->
    val = $(e.currentTarget).val()
    if (val == "TYPE_CRATE") || (val == "PALLET_XXX")
      $(e.currentTarget).closest('.line-item').find('.piece-count-group').show()
    else
      $(e.currentTarget).closest('.line-item').find('.piece-count-group').hide()
      $(e.currentTarget).closest('.line-item').find('input[data-field=piece_count]').val(1)

  checkFreightClass: (e) ->
    context = $(e.currentTarget).closest(".line-item")
    length = parseFloat(context.find("input[data-field=dim_length]").val())
    width = parseFloat(context.find("input[data-field=dim_width]").val())
    height = parseFloat(context.find("input[data-field=dim_height]").val())
    weight = parseFloat(context.find("input[data-field=weight]").val())
    user_freight_class = parseInt(context.find("select[data-field=freight_class_code]").val())
    return unless length && width && height && weight


    ci = length * width * height
    cf = ci / 1278
    density = parseInt(weight / cf)

    freight_class = switch
      when density > 50 then 50
      when density >= 35 then 55
      when density >= 30 then 60
      when density >= 22.5 then 65
      when density >= 15 then 70
      when density >= 13.5 then 77.5
      when density >= 12 then 85
      when density >= 10.5 then 92.5
      when density >= 9 then 100
      when density >= 8 then 110
      when density >= 7 then 125
      when density >= 6 then 150
      when density >= 5 then 175
      when density >= 4 then 200
      when density >= 3 then 250
      when density >= 2 then 300
      when density >= 1 then 400
      when density < 1 then 500

    if user_freight_class != freight_class
      context.find(".freight-class").attr('title',"Based on your dimensions, our calculations indicate the correct class may be #{freight_class}.  Check with your carrier to be certain of class before shipping.")
      context.find(".freight-class").tooltip('show')
    else
      context.find(".freight-class").tooltip('hide')