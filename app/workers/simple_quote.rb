class SimpleQuote
  @queue = :quotes

  def self.perform(shipment_id)

    shipment = Shipment.find(shipment_id)

    soap_client = MyFreightWorld.new

    begin
      quote = soap_client.fetch_simple_quote(shipment)
      shipment.quote_payload = quote
      shipment.quote_time = Time.now
      shipment.status = Shipment::SHIPMENT_STATUS_QUOTED
      shipment.error_message = nil
      shipment.save

      to_iter = (quote[:quotes][:quote].is_a?(Hash)) ? [quote[:quotes][:quote]] : quote[:quotes][:quote]

      to_iter.each do |qt|
        crr = Carrier.where(carrier_key: qt[:carrier_key]).first_or_initialize
        if crr.new_record?
          crr.name = qt[:display_name]
          crr.save
        end
      end

    rescue => e
      #raise e
      shipment.error_message = e.to_s
      shipment.status = Shipment::SHIPMENT_STATUS_ERROR
      shipment.save
    end

    # save to shipment?

  end
end