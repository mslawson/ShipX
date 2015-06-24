require 'base64'

# Exposes authenticated carrier user actions to the Carrier module
class Carrier::SessionController < ActionController::Base
  layout "carrier"

  # Home action for carrier
  def home
    if !session[:carrier]
      redirect_to :controller => 'carrier/account', :action => 'login' and return
    end

    @carrier_signed_in = true
  end

  #Default Pricing action for carrier
  def getdefaultpricing
    @carrierPricing = {}
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierPricing = soap_client.getDefaultPricing(session[:carrier]["token"])
    end

    render :json => @carrierPricing
  end

  #Default Pricing action for carrier
  def updatedefaultpricing
    pricing = params["pricing"]
    @carrierPricing = {}
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierPricing = soap_client.updateDefaultPricing(session[:carrier]["token"], pricing)
    end

    render :json => @carrierPricing
  end

  # Get all lanes action for carrier
  def lanes
    @carrierLanes = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierLanes = soap_client.getLanes(session[:carrier]["token"])
    end

    render :json => @carrierLanes
  end

  # Create a new lane action for carrier
  def createlane
    originRegionId = params["originRegionId"]
    destinationRegionId = params["destinationRegionId"]
    costFactor = params["costFactor"]
    costFactorUseDefault = params["costFactorUseDefault"] == "true"
    minimumCharge = params["minimumCharge"]
    minimumChargeUseDefault = params["minimumChargeUseDefault"] == "true"
    @carrierLanes = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierLanes = soap_client.createLane(session[:carrier]["token"], originRegionId, destinationRegionId, costFactor, costFactorUseDefault, minimumCharge, minimumChargeUseDefault)
    end

    render :json => @carrierLanes
  end

  # Updates an existing lane action for carrier
  def updatelane
    pricingId = params["pricingId"]
    originRegionId = params["originRegionId"]
    destinationRegionId = params["destinationRegionId"]
    costFactor = params["costFactor"]
    costFactorUseDefault = params["costFactorUseDefault"] == "true"
    minimumCharge = params["minimumCharge"]
    minimumChargeUseDefault = params["minimumChargeUseDefault"] == "true"
    @carrierLanes = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierLanes = soap_client.updateLane(session[:carrier]["token"], pricingId, originRegionId, destinationRegionId, costFactor, costFactorUseDefault, minimumCharge, minimumChargeUseDefault)
    end

    render :json => @carrierLanes
  end

  # Deletes an existing lane action for carrier
  def deletelane
    laneId = params["id"]
    @carrierLanes = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierLanes = soap_client.deleteLane(session[:carrier]["token"], laneId)
    end

    render :json => @carrierLanes
  end

  # Inserts a new lane pricing action for carrier
  def insertlanepricing
    pricingId = params["pricingId"]
    startDate = params["startDate"]
    endDate = params["endDate"]
    costFactor = params["costFactor"]
    costFactorUseDefault = params["costFactorUseDefault"] == "true"
    minimumCharge = params["minimumCharge"]
    minimumChargeUseDefault = params["minimumChargeUseDefault"] == "true"
    restoreCostFactor = params["restoreCostFactor"]
    restoreCostFactorUseDefault = params["restoreCostFactorUseDefault"] == "true"
    restoreMinimumCharge = params["restoreMinimumCharge"]
    restoreMinimumChargeUseDefault = params["restoreMinimumChargeUseDefault"] == "true"
    @lanePricings = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @lanePricings = soap_client.insertLanePricing(session[:carrier]["token"], pricingId, startDate, endDate, costFactor, costFactorUseDefault,
                                                    minimumCharge, minimumChargeUseDefault, restoreCostFactor, restoreCostFactorUseDefault, restoreMinimumCharge, restoreMinimumChargeUseDefault)
    end

    render :json => @lanePricings
  end

  # Updates an existing lane pricing action for carrier
  def updatelanepricing
    scheduledPricingId = params["scheduledPricingId"]
    pricingId = params["pricingId"]
    startDate = params["startDate"]
    endDate = params["endDate"]
    costFactor = params["costFactor"]
    costFactorUseDefault = params["costFactorUseDefault"] == "true"
    minimumCharge = params["minimumCharge"]
    minimumChargeUseDefault = params["minimumChargeUseDefault"] == "true"
    restoreCostFactor = params["restoreCostFactor"]
    restoreCostFactorUseDefault = params["restoreCostFactorUseDefault"]
    restoreMinimumCharge = params["restoreMinimumCharge"]
    restoreMinimumChargeUseDefault = params["restoreMinimumChargeUseDefault"]
    @lanePricings = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @lanePricings = soap_client.updateLanePricing(session[:carrier]["token"], scheduledPricingId, pricingId, startDate, endDate, costFactor, costFactorUseDefault,
                                                    minimumCharge, minimumChargeUseDefault, restoreCostFactor, restoreCostFactorUseDefault, restoreMinimumCharge, restoreMinimumChargeUseDefault)
    end

    render :json => @lanePricings
  end

  # Deletes an existing lane pricing action for carrier
  def deletelanepricing
    id = params["id"]
    pricingId = params["pricingId"]
    @lanePricings = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @lanePricings = soap_client.deleteLanePricing(session[:carrier]["token"], pricingId, id)
    end

    render :json => @lanePricings
  end
  # Create a new lane action for carrier
  def createlane
    originRegionId = params["originRegionId"]
    destinationRegionId = params["destinationRegionId"]
    costFactor = params["costFactor"]
    costFactorUseDefault = params["costFactorUseDefault"] == "true"
    minimumCharge = params["minimumCharge"]
    minimumChargeUseDefault = params["minimumChargeUseDefault"] == "true"
    @carrierLanes = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierLanes = soap_client.createLane(session[:carrier]["token"], originRegionId, destinationRegionId, costFactor, costFactorUseDefault, minimumCharge, minimumChargeUseDefault)
    end

    render :json => @carrierLanes
  end

  # Updates an existing lane action for carrier
  def updatelane
    pricingId = params["pricingId"]
    originRegionId = params["originRegionId"]
    destinationRegionId = params["destinationRegionId"]
    costFactor = params["costFactor"]
    costFactorUseDefault = params["costFactorUseDefault"] == "true"
    minimumCharge = params["minimumCharge"]
    minimumChargeUseDefault = params["minimumChargeUseDefault"] == "true"
    @carrierLanes = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierLanes = soap_client.updateLane(session[:carrier]["token"], pricingId, originRegionId, destinationRegionId, costFactor, costFactorUseDefault, minimumCharge, minimumChargeUseDefault)
    end

    render :json => @carrierLanes
  end

  # Deletes an existing lane action for carrier
  def deletelane
    laneId = params["id"]
    @carrierLanes = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierLanes = soap_client.deleteLane(session[:carrier]["token"], laneId)
    end

    render :json => @carrierLanes
  end

  # Inserts a new lane pricing action for carrier
  def insertlanepricing
    pricingId = params["pricingId"]
    startDate = params["startDate"]
    endDate = params["endDate"]
    costFactor = params["costFactor"]
    costFactorUseDefault = params["costFactorUseDefault"] == "true"
    minimumCharge = params["minimumCharge"]
    minimumChargeUseDefault = params["minimumChargeUseDefault"] == "true"
    restoreCostFactor = params["restoreCostFactor"]
    restoreCostFactorUseDefault = params["restoreCostFactorUseDefault"] == "true"
    restoreMinimumCharge = params["restoreMinimumCharge"]
    restoreMinimumChargeUseDefault = params["restoreMinimumChargeUseDefault"] == "true"
    @lanePricings = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @lanePricings = soap_client.insertLanePricing(session[:carrier]["token"], pricingId, startDate, endDate, costFactor, costFactorUseDefault,
                                             minimumCharge, minimumChargeUseDefault, restoreCostFactor, restoreCostFactorUseDefault, restoreMinimumCharge, restoreMinimumChargeUseDefault)
    end

    render :json => @lanePricings
  end

  # Updates an existing lane pricing action for carrier
  def updatelanepricing
    scheduledPricingId = params["scheduledPricingId"]
    pricingId = params["pricingId"]
    startDate = params["startDate"]
    endDate = params["endDate"]
    costFactor = params["costFactor"]
    costFactorUseDefault = params["costFactorUseDefault"] == "true"
    minimumCharge = params["minimumCharge"]
    minimumChargeUseDefault = params["minimumChargeUseDefault"] == "true"
    restoreCostFactor = params["restoreCostFactor"]
    restoreCostFactorUseDefault = params["restoreCostFactorUseDefault"]
    restoreMinimumCharge = params["restoreMinimumCharge"]
    restoreMinimumChargeUseDefault = params["restoreMinimumChargeUseDefault"]
    @lanePricings = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @lanePricings = soap_client.updateLanePricing(session[:carrier]["token"], scheduledPricingId, pricingId, startDate, endDate, costFactor, costFactorUseDefault,
                                                    minimumCharge, minimumChargeUseDefault, restoreCostFactor, restoreCostFactorUseDefault, restoreMinimumCharge, restoreMinimumChargeUseDefault)
    end

    render :json => @lanePricings
  end

  # Regions action for carrier
  def regions
    @carrierRegions = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierRegions = soap_client.getRegions(session[:carrier]["token"])
    end

    render :json => @carrierRegions
  end

  # Create Region action for carrier
  def createregion
    region_name = params["regionName"]
    region_active = params["active"] == "true"
    @carrierRegions = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierRegions = soap_client.createRegion(session[:carrier]["token"], region_name, region_active)
    end

    render :json => @carrierRegions
  end

  # Delete Region action for carrier
  def deleteregion
    region_id = params["regionId"]
    @carrierRegions = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierRegions = soap_client.deleteRegion(session[:carrier]["token"], region_id)
    end

    render :json => @carrierRegions
  end

  # Insert Region Zip action for carrier
  def insertregionzip
    region_id = params["regionId"]
    country_id = 1
    zip_code = params["zipCode"]
    excluded = params["excluded"]
    @carrierRegion = nil
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierRegion = soap_client.insertRegionZip(session[:carrier]["token"], region_id, country_id, zip_code, excluded)
    end

    render :json => @carrierRegion
  end

  # Delete Region Zip action for carrier
  def deleteregionzip
    region_id = params["regionId"]
    country_id = 1
    zip_code = params["zipCode"]
    excluded = params["excluded"]
    @carrierRegion = nil
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierRegion = soap_client.deleteRegionZip(session[:carrier]["token"], region_id, country_id, zip_code, excluded)
    end

    render :json => @carrierRegion
  end

  # Insert Region Zip Range action for carrier
  def insertregionziprange
    region_id = params["regionId"]
    country_id = 1
    starting_zip_code = params["startingZipCode"]
    ending_zip_code = params["endingZipCode"]
    excluded = params["excluded"]
    @carrierRegion = nil
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierRegion = soap_client.insertRegionZipRange(session[:carrier]["token"], region_id, country_id, starting_zip_code, ending_zip_code, excluded)
    end

    render :json => @carrierRegion
  end

  # Delete Region Zip Range action for carrier
  def deleteregionziprange
    region_id = params["regionId"]
    country_id = 1
    starting_zip_code = params["startingZipCode"]
    ending_zip_code = params["endingZipCode"]
    excluded = params["excluded"]
    @carrierRegion = nil
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierRegion = soap_client.deleteRegionZipRange(session[:carrier]["token"], region_id, country_id, starting_zip_code, ending_zip_code, excluded)
    end

    render :json => @carrierRegion
  end

  # Insert Region State action for carrier
  def insertregionstate
    region_id = params["regionId"]
    country_id = 1
    state = params["state"]
    excluded = params["excluded"]
    @carrierRegion = nil
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierRegion = soap_client.insertRegionState(session[:carrier]["token"], region_id, country_id, state, excluded)
    end

    render :json => @carrierRegion
  end

  # Delete Region State action for carrier
  def deleteregionstate
    region_id = params["regionId"]
    country_id = 1
    state = params["state"]
    excluded = params["excluded"]
    @carrierRegion = nil
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @carrierRegion = soap_client.deleteRegionState(session[:carrier]["token"], region_id, country_id, state, excluded)
    end

    render :json => @carrierRegion
  end

  # Countries action for carrier
  def countries
    @countries = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @countries = soap_client.getCountries(session[:carrier]["token"])
    end

    render :json => @countries
  end

  # States action for carrier
  def states
    @states = []
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      @states = soap_client.getStates(session[:carrier]["token"], 1)
    end

    render :json => @states
  end

  # Upload pricing for carrier
  def uploadpricing
    @uploadStatus = nil
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      if request.post?
        file_data = params[:file]
        if file_data.respond_to?(:read)
          pricing_contents = file_data.read
        elsif file_data.respond_to?(:path)
          pricing_contents = File.read(file_data.path)
        else
          return head 500
        end

        pricing_contents = Base64.encode64(pricing_contents)
        @uploadStatus = soap_client.uploadPricing(session[:carrier]["token"], pricing_contents)
      end
    end

    render :json => @uploadStatus
  end

  # Upload schedule pricing for carrier
  def uploadschedulepricing
    @uploadStatus = nil
    if session[:carrier]
      soap_client = MyFreightWorldCarrier.new
      if request.post?
        file_data = params[:file]
        if file_data.respond_to?(:read)
          pricing_contents = file_data.read
        elsif file_data.respond_to?(:path)
          pricing_contents = File.read(file_data.path)
        else
          return head 500
        end

        pricing_contents = Base64.encode64(pricing_contents)
        @uploadStatus = soap_client.uploadSchedulePricing(session[:carrier]["token"], pricing_contents)
      end
    end

    render :json => @uploadStatus
  end
end