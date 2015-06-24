class Book
  @queue = :bookings


  # Booking a shipment is a bit complex
  # We have to run a few checks before we call the full thing complete:
  #  1. Prior to this point, we only have a "QUOTEONLY" price.  So, we need to run a "full" quote to make sure the price is the same
  #  2. Assuming that our pricing is the same we run a "hold" on the CC to make sure customer can pay
  #  3. Next, we book the actual shipment using the booking_key from the full quote in step 1
  #  4. Once this succeeds, we capture the hold to complete the transaction
  def self.perform(shipment_id)

    shipment = Shipment.find(shipment_id)

    begin

      if shipment.quote_time < (Time.now - 20.minutes)
        raise "Your quote has expired, please re-quote your shipment before booking."
      end

      soap_client = MyFreightWorld.new

      # 1. run full quote and make sure our price is still valid
      quote_soap = soap_client.fetch_full_quote(shipment)
      selected_quote = nil

      quote_soap[:quotes][:quote].each do |quote|
        if quote[:carrier_key] == shipment.selected_carrier
          selected_quote = quote
          shipment.selected_quote = quote[:booking_key]
        end
      end

      if selected_quote.nil?
        raise "It appears that the detailed information you provided may have changed your shipment price.  Please re-run your quote for the latest pricing."
      end

      if shipment.total_price.to_f != shipment.selected_quote_price.to_f
        shipment.extended_error_message = "#{shipment.total_price} did not match #{shipment.selected_quote_price}"
        raise "It appears that the detailed information you provided may have changed your shipment price.  Please re-run your quote for the latest pricing."
      end

      shipment.quote_payload = quote_soap
      shipment.error_message = nil
      shipment.save

      # 2. Create CC Hold (for CC orders, skip for LOC orders)
      if shipment.payment_method.is_cc?
        hold_id = PaymentGateway.create_hold(shipment)
        if !hold_id
          raise "Could not create charge"
        end
        shipment.hold_id = hold_id
        shipment.save
      end

      # 3. Book shipment
      begin
        resp = soap_client.book_shipment(shipment)
        shipment.status = Shipment::SHIPMENT_STATUS_BOOKED
        shipment.error_message = nil
        shipment.bol = resp[:bol]
        shipment.bol_file = resp[:bol_file_location]

        # 4. capture the hold (for CC, otherwise mark LOC debited)
        if shipment.payment_method.is_cc?
          payment_id = PaymentGateway.capture_hold(hold_id,shipment)
          shipment.stripe_transaction_id = payment_id
          ShipmentEvent.create(shipment_id: shipment.id, message: "Shipment Booked")
          ShipmentEvent.create(shipment_id: shipment.id, message: "Card Charged $#{shipment.total_price}")
        elsif shipment.payment_method.is_loc?
          CreditEvent.create(shipment_id: shipment.id,
                             credit_application_id: shipment.payment_method.credit_application_id,
                             status: CreditEvent::CREDIT_EVENT_STATUS_OPEN,
                             amount: shipment.total_price.to_f)
          ShipmentEvent.create(shipment_id: shipment.id, message: "Shipment Booked")
          ShipmentEvent.create(shipment_id: shipment.id, message: "Line of Credit Debited $#{shipment.total_price}")
        end
      rescue => e
        # If it fails, void the hold
        Rails.logger.info e.to_json
        PaymentGateway.void_hold(hold_id) if shipment.payment_method.is_cc?
        Rails.logger.error e.to_s
        shipment.extended_error_message = e.to_s
        raise "There was a problem processing your payment.  Please check and try again."
        #raise e # this raw exception is very technical from BP, don't show it to the user
      end

      # All done!  Clean up
      shipment.status = Shipment::SHIPMENT_STATUS_BOOKED
      shipment.error_message = nil
      shipment.extended_error_message = nil
      shipment.bol = resp[:bol]
      shipment.bol_file = resp[:bol_file_location]

      OrderConfirmationMailer.order_confirmation(shipment).deliver
      shipment.save

    rescue => e
      shipment.status = Shipment::SHIPMENT_STATUS_ERROR
      shipment.error_message = e.to_s
      shipment.save
    end

  end
end