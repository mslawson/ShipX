jQuery ->

  $(document).on 'page:change', ->

    new ShipX.Views.ShipmentPartsLocationInfo(el: $("#shipment_parts-location")) if $("#shipment_parts-location").length > 0
    new ShipX.Views.ShipmentPartsFreight(el: $("#shipment_parts-freight")) if $("#shipment_parts-freight").length > 0
    new ShipX.Views.ShipmentPartsQuoting(el: $("#shipment_parts-quoting")) if $("#shipment_parts-quoting").length > 0
    new ShipX.Views.ShipmentPartsResults(el: $("#shipment_parts-results")) if $("#shipment_parts-results").length > 0
    new ShipX.Views.ShipmentPartsPayment(el: $("#shipment_parts-payment")) if $("#shipment_parts-payment").length > 0
    new ShipX.Views.ShipmentPartsSummary(el: $("#shipment_parts-summary")) if $("#shipment_parts-summary").length > 0
    new ShipX.Views.ShipmentPartsBooking(el: $("#shipment_parts-booking")) if $("#shipment_parts-booking").length > 0

    $(".address-fragment").each (idx, elem) =>
      new ShipX.Views.Address(el: $(elem))