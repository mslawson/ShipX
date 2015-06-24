class ShipX.Views.Address extends Backbone.View

  initialize: (opts) ->
    #console.log "address initializing"
    @autocomplete_form()

  events:
    'change #user_user_type': 'company_field'

  company_field: (e) ->
    #console.log "nothing"

  autocomplete_form: ->
    autocomplete = undefined
    u_a_one = @$('.address-free-entry')
    #console.log u_a_one
    autocomplete = new google.maps.places.Autocomplete(u_a_one[0], {})
    google.maps.event.addListener autocomplete, "place_changed", =>
      addr = undefined
      ci = undefined
      city = undefined
      cnty = undefined
      i = undefined
      pc = undefined
      place = undefined
      postal_code = undefined
      st = undefined
      st_name = undefined
      st_num = undefined
      street1 = undefined
      place = autocomplete.getPlace()
      i = 0
      while i < place.address_components.length
        #console.log place.address_components
        addr = place.address_components[i]
        st_num = addr.long_name  if addr.types[0] is "street_number"
        st_name = addr.long_name  if addr.types[0] is "route"
        @$("input.city").val addr.long_name  if addr.types[0] is "locality"
        @$("select.state").val addr.short_name  if addr.types[0] is "administrative_area_level_1"
        @$("#user_county").val (addr.long_name).replace(new RegExp("\\bcounty\\b", "gi"), "").trim()  if addr.types[0] is "administrative_area_level_2"
        @$("input.zipcode").val addr.long_name  if addr.types[0] is "postal_code"
        if addr.types[0] is "country"
          $("#user_country_id option").each ->
            # console.log $(this).text().trim()  if addr.long_name.trim() is $(this).text().trim()
            $(this).prop('selected', true)  if $(this).data('iso') is addr.short_name.trim().toUpperCase()
            return
        i++
      if st_num isnt "" and (st_num?) and st_num isnt "undefined"
        street1 = st_num + " " + st_name
      else
        street1 = st_name
      @$("input.address_1").val street1
      u_a_one.blur()
      @$(".input-fields").show()
      @$(".free-entry-field").hide()
#      setTimeout (->
#        u_a_one.val("").val street1
#        return
#      ), 10
      #u_a_one.val street1
      return