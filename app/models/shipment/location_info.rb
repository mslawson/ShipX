class Shipment::LocationInfo < Shipment

  validates_presence_of :origin_address, :destination_address, :pickup_date

  after_save :geocode_city_state
  # @TODO: validate date format

  private

  def geocode_city_state
    begin
      if origin_address.city.nil?
        result = Geokit::Geocoders::GoogleGeocoder.geocode origin_address.zipcode
        if result
          origin_address.city = result.city
          origin_address.state = result.state
          origin_address.save
        end
      end
      if destination_address.city.nil?
        result = Geokit::Geocoders::GoogleGeocoder.geocode destination_address.zipcode
        if result
          destination_address.city = result.city
          destination_address.state = result.state
          destination_address.save
        end
      end
    rescue => e
      Rails.logger.error e.to_s
    end
  end

end