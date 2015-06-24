class MyFreightWorldCarrier

  def initialize

    @client = Savon.client(wsdl: File.join(Rails.root, 'public', 'wsdl', MY_FREIGHT_WORLD["carrier_wsdl_file"]),
                           log_level: :debug,
                           log: true) do
      pretty_print_xml true
    end

  end

  def authenticate

    request = {'quoteServiceKey' => MY_FREIGHT_WORLD["quote_service_key"]}
    response = @client.call(:authenticate, message: request)
    @auth_key = response.body[:authenticate_response][:authenticate_result]

    Rails.logger.info response
  end

  def login(user, password)
    authenticate

    response = make_request(:login, {'connectionKey' => @auth_key, 'user' => user, 'password' => password})

    Rails.logger.info response
    return response.body[:login_response][:login_result]
  end

  def getLanes(token)
    authenticate

    response = make_request(:get_routes, {'connectionKey' => @auth_key, 'carrierToken' => token})
    return response.body[:get_routes_response][:get_routes_result]
  end

  def createLane(token, originRegionId, destinationRegionId, costFactor, costFactorUseDefault, minimumCharge, minimumChargeUseDefault)
    authenticate

    response = make_request(:insert_pricing, {'connectionKey' => @auth_key, 'carrierToken' => token,
                                              'originRegionId' => originRegionId, 'destinationRegionId' => destinationRegionId,
                                              'costFactor' => costFactor, 'costFactorUseDefault' => costFactorUseDefault,
                                              'minimumCharge' => minimumCharge, 'minimumChargeUseDefault' => minimumChargeUseDefault})
    return response.body[:insert_pricing_response][:insert_pricing_result]
  end

  def updateLane(token, pricingId, originRegionId, destinationRegionId, costFactor, costFactorUseDefault, minimumCharge, minimumChargeUseDefault)
    authenticate

    response = make_request(:update_pricing, {'connectionKey' => @auth_key, 'carrierToken' => token, 'pricingId' => pricingId,
                                              'originRegionId' => originRegionId, 'destinationRegionId' => destinationRegionId,
                                              'costFactor' => costFactor, 'costFactorUseDefault' => costFactorUseDefault,
                                              'minimumCharge' => minimumCharge, 'minimumChargeUseDefault' => minimumChargeUseDefault})
    return response.body[:update_pricing_response][:update_pricing_result]
  end

  def deleteLane(token, laneId)
    authenticate

    response = make_request(:delete_pricing, {'connectionKey' => @auth_key, 'carrierToken' => token,
                                              'pricingId' => laneId})
    return response.body[:delete_pricing_response][:delete_pricing_result]
  end

  def insertLanePricing(token, pricingId, startDate, endDate, costFactor, costFactorUseDefault,
                        minimumCharge, minimumChargeUseDefault, restoreCostFactor,
                        restoreCostFactorUseDefault, restoreMinimumCharge, restoreMinimumChargeUseDefault)
    authenticate

    response = make_request(:insert_scheduled_pricing, {'connectionKey' => @auth_key, 'carrierToken' => token,
                                                        'pricingId' => pricingId, 'startDate' => startDate, 'endDate' => endDate,
                                                        'costFactor' => costFactor, 'costFactorUseDefault' => costFactorUseDefault,
                                                        'minimumCharge' => minimumCharge, 'minimumChargeUseDefault' => minimumChargeUseDefault,
                                                        'restoreCostFactor' => restoreCostFactor, 'restoreCostFactorUseDefault' => restoreCostFactorUseDefault,
                                                        'restoreMinimumCharge' => restoreMinimumCharge, 'restoreMinimumChargeUseDefault' => restoreMinimumChargeUseDefault})
    return response.body[:insert_scheduled_pricing_response][:insert_scheduled_pricing_result]
  end

  def updateLanePricing(token, id, pricingId, startDate, endDate, costFactor, costFactorUseDefault,
                        minimumCharge, minimumChargeUseDefault, restoreCostFactor,
                        restoreCostFactorUseDefault, restoreMinimumCharge, restoreMinimumChargeUseDefault)
    authenticate

    response = make_request(:update_scheduled_pricing, {'connectionKey' => @auth_key, 'carrierToken' => token,
                                                        'scheduledPricingId' => id,
                                                        'pricingId' => pricingId, 'startDate' => startDate, 'endDate' => endDate,
                                                        'costFactor' => costFactor, 'costFactorUseDefault' => costFactorUseDefault,
                                                        'minimumCharge' => minimumCharge, 'minimumChargeUseDefault' => minimumChargeUseDefault,
                                                        'restoreCostFactor' => restoreCostFactor, 'restoreCostFactorUseDefault' => restoreCostFactorUseDefault,
                                                        'restoreMinimumCharge' => restoreMinimumCharge, 'restoreMinimumChargeUseDefault' => restoreMinimumChargeUseDefault})
    return response.body[:update_scheduled_pricing_response][:update_scheduled_pricing_result]
  end

  def deleteLanePricing(token, pricingId, id)
    authenticate

    response = make_request(:delete_scheduled_pricing, {'connectionKey' => @auth_key, 'carrierToken' => token, 'pricingId' => pricingId,
                                                        'scheduledPricingId' => id})
    return response.body[:delete_scheduled_pricing_response][:delete_scheduled_pricing_result]
  end

  def getRegions(token)
    authenticate

    response = make_request(:get_regions, {'connectionKey' => @auth_key, 'carrierToken' => token})
    return response.body[:get_regions_response][:get_regions_result]
  end

  def createRegion(token, regionName, isActive)
    authenticate

    response = make_request(:insert_region, {'connectionKey' => @auth_key, 'carrierToken' => token, 'description' => regionName, 'active' => isActive})
    return response.body[:insert_region_response][:insert_region_result]
  end

  def deleteRegion(token, regionId)
    authenticate

    response = make_request(:delete_region, {'connectionKey' => @auth_key, 'carrierToken' => token, 'regionId' => regionId})
    return response.body[:delete_region_response][:delete_region_result]
  end

  def getCountries(token)
    authenticate

    response = make_request(:get_countries, {'connectionKey' => @auth_key, 'carrierToken' => token})
    return response.body[:get_countries_response][:get_countries_result]
  end

  def getStates(token, countryId)
    authenticate

    response = make_request(:get_states, {'connectionKey' => @auth_key, 'carrierToken' => token, "countryId" => countryId})
    return response.body[:get_states_response][:get_states_result]
  end

  def insertRegionZip(token, regionId, countryId, zip, exclude)
    authenticate

    response = make_request(:insert_zip, {'connectionKey' => @auth_key, 'carrierToken' => token, "regionId" => regionId, "countryId" => countryId, "zip" => zip, "exclude" => exclude})
    return response.body[:insert_zip_response][:insert_zip_result]
  end

  def deleteRegionZip(token, regionId, countryId, zip, exclude)
    authenticate

    response = make_request(:delete_zip, {'connectionKey' => @auth_key, 'carrierToken' => token, "regionId" => regionId, "countryId" => countryId, "zip" => zip, "exclude" => exclude})
    return response.body[:delete_zip_response][:delete_zip_result]
  end

  def insertRegionZipRange(token, regionId, countryId, startZip, endZip, exclude)
    authenticate

    response = make_request(:insert_zip_range, {'connectionKey' => @auth_key, 'carrierToken' => token, "regionId" => regionId,
                                                "countryId" => countryId, "startZip" => startZip, "endZip" => endZip, "exclude" => exclude})
    return response.body[:insert_zip_range_response][:insert_zip_range_result]
  end

  def deleteRegionZipRange(token, regionId, countryId, startZip, endZip, exclude)
    authenticate

    response = make_request(:delete_zip_range, {'connectionKey' => @auth_key, 'carrierToken' => token, "regionId" => regionId,
                                                "countryId" => countryId, "startZip" => startZip, "endZip" => endZip, "exclude" => exclude})
    return response.body[:delete_zip_range_response][:delete_zip_range_result]
  end

  def insertRegionState(token, regionId, countryId, state, exclude)
    authenticate

    response = make_request(:insert_state, {'connectionKey' => @auth_key, 'carrierToken' => token, "regionId" => regionId, "countryId" => countryId, "state" => state, "exclude" => exclude})
    return response.body[:insert_state_response][:insert_state_result]
  end

  def deleteRegionState(token, regionId, countryId, state, exclude)
    authenticate

    response = make_request(:delete_state, {'connectionKey' => @auth_key, 'carrierToken' => token, "regionId" => regionId, "countryId" => countryId, "state" => state, "exclude" => exclude})
    return response.body[:delete_state_response][:delete_state_result]
  end

  def getDefaultPricing(token)
    authenticate

    response = make_request(:get_pricing_configuration, {'connectionKey' => @auth_key, 'carrierToken' => token})
    return response.body[:get_pricing_configuration_response][:get_pricing_configuration_result]
  end

  def updateDefaultPricing(token, pricing)
    authenticate

    response = make_request(:update_pricing_configuration, {'connectionKey' => @auth_key, 'carrierToken' => token, 'pricing' => pricing})
    return response.body[:update_pricing_configuration_response][:update_pricing_configuration_result]
  end

  def uploadPricing(token, data)
    authenticate

    response = make_request(:upload_pricing, {'connectionKey' => @auth_key, 'carrierToken' => token, 'data' => data})
    return response.body[:upload_pricing_response][:upload_pricing_result]
  end

  def uploadSchedulePricing(token, data)
    authenticate

    response = make_request(:upload_scheduled_pricing, {'connectionKey' => @auth_key, 'carrierToken' => token, 'data' => data})
    return response.body[:upload_scheduled_pricing_response][:upload_scheduled_pricing_result]
  end

  def make_request(request, body={})
    begin
      @client.call(request,message: body)
    rescue Savon::SOAPFault => error
      Rails.logger.error error

      if error.to_hash[:fault][:detail][:error].is_a?(Array)
        err = error.to_hash[:fault][:detail][:error].map{|e| "#{e[:error_code]}: #{e[:error_message]}"}.join(", ")
      else
        err = "#{error.to_hash[:fault][:detail][:error][:error_code]}: #{error.to_hash[:fault][:detail][:error][:error_message]}"
      end

      raise err
    end
  end
end