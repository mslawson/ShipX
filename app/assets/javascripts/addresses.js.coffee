# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(".phone").mask("(999) 999-9999")

  $(".trig-form-submit").click (e) ->
    $(e.currentTarget).closest("form").submit()

  $(window).keydown (event) ->
    if event.keyCode == 13
      event.preventDefault()
      return false