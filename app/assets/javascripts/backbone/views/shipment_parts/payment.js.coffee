class ShipX.Views.ShipmentPartsPayment extends Backbone.View

  initialize: (opts) ->
    @id = @$el.attr('data-id')
    console.log "payment"
    Stripe.setPublishableKey(window.PUBLISH_KEY)


  events:
    'click .quote-row': 'selectQuote'
    'click #continue-button': 'validatePayment'
    'change input[name=payment_method]': 'selectPaymentMethod'

  selectQuote: (e) ->
    e.preventDefault()
    @$(".quote-row").removeClass('active')
    $(e.currentTarget).addClass('active')
    @$("#selected-quote").val($(e.currentTarget).attr('data-id'))
    @$("#continue-button").attr('disabled',false)

  selectPaymentMethod: (e) ->
    if $(e.currentTarget).val() == 'new'
      $("#new_payment_method").removeClass('hidden')
    else
      $("#new_payment_method").addClass('hidden')
      $("input[name='shipment[payment_method_id]'").val($(e.currentTarget).val())

  validatePayment: (e) ->
    if ($("input[name=payment_method]").length > 0) && ($("input[name=payment_method]:checked").val() != "new")
      return true

    $form = $("form")
    Stripe.card.createToken($form, _.bind(@.stripeResponseHandler, @))

    e.preventDefault()
    $(e.currentTarget).attr('disabled','disabled')
    @payload = {
      name: $("input[name='shipment[payment_card_name]']").val(),
      number: $("input[name='shipment[payment_card_number]']").val(),
      expiration_month: $("select[name='shipment[payment_card_exp_month]']").val(),
      expiration_year: $("select[name='shipment[payment_card_exp_year]']").val(),
      cvv: $("input[name='shipment[payment_card_cvv]']").val()
    }
    return false

  stripeResponseHandler: (status, response) ->
    console.log response

    if response.error
      alert_box = null
      if $(".alert.alert-danger").length > 0
        alert_box = $(".alert.alert-danger")[0]
      else
        $(".alert-boxes").append("<div class='alert alert-danger'><b>Error:</b> </div>")
        alert_box = $(".alert.alert-danger")[0]

      $(alert_box).html('<b>Error: </b>' + response.error.message)
      $("#continue-button").removeAttr('disabled')

#      _.each response.errors, (error) ->
#        _.each error.extras, (k, v) ->
#          friendly_name = null
#          if v == "number"
#            $("input[name='shipment[payment_card_number]']").closest(".form-group").addClass("has-error")
#            friendly_name = "Card number"
#          else if v == "cvv"
#            $("input[name='shipment[payment_card_cvv]']").closest(".form-group").addClass("has-error")
#            friendly_name = "Card CVV"
#          else if v == "expiration_month"
#            $("select[name='shipment[payment_card_exp_month]']").closest(".form-group").addClass("has-error")
#            friendly_name = "Expiration Month"
#          else if v == "expiration_year"
#            $("select[name='shipment[payment_card_exp_year]']").closest(".form-group").addClass("has-error")
#            friendly_name = "Expiration Year"


    else
      console.log @payload
      @payload.token_id = response.id
      @payload.cc_last_four = @payload.number.substr(-4)
      jQuery.post "/api/v1/payment_methods", @payload, (r, xhr, httpstatus) =>
        if httpstatus.status == 201
          $("input[name='shipment[payment_method_id]'").val(r.id)
          $("form#edit_shipment").submit()
        else
          console.log "error"

