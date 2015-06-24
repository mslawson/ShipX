class ShipX.Views.ShipmentPartsLocationInfo extends Backbone.View

  initialize: (opts) ->
    #$("#user_phone").mask "999-999-9999"
    @$("#date-picker").datetimepicker({formatTime: "g:i A", format: "Y-m-d h:i A", minDate: 0, maxDate: "+1970/01/07", beforeShowDay: $.datepicker.noWeekends})

  events:
    'change #user_user_type': 'company_field'

  company_field: (e) ->
    console.log "nothing"
 