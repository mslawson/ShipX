# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $("#credit_app_status").change (e) ->
    window.location = '/admin/credit_applications?status='+$(e.currentTarget).val()
