class ShipmentPartsController < ApplicationController

  before_filter :authorize_shipment

  STEPS = ['location_info', 'freight', 'quoting', 'results', 'summary', 'payment', 'booking', 'complete']

  # if not defined, the code will auto-humanize the name (see ShipmentsHelper)
  STEP_NAMES = {
    'location_info' => "Location Info",
    'freight' => "Freight",
    'results' => "Results",
    'summary' => "Details"
  }

  def edit
    @steps = STEPS
    if wizard_step_shipment.editable?
      if step.present?
        @step_name = step
        @step_index = STEPS.index(@step_name)
        render @step_name
      else
        # 404!
        render "#{Rails.root.to_s}/public/404.html", :layout => false, :status => 404
      end
    elsif (wizard_step_shipment.is_a?(Shipment::Complete) && wizard_step_shipment.booked?) || (wizard_step_shipment.booked?)
      redirect_to track_shipment_path(wizard_step_shipment) and return
    else
      redirect_to :back #, :alert => "Step not editable"
    end
  end

  def update
    @steps = STEPS
    @shipment_model = wizard_step_shipment
    if @shipment_model.update_attributes(permitted_attributes) && callbacks_for_step(step)
      if next_step && params[:commit] && params[:commit].downcase.include?("continue")
        redirect_to edit_shipment_shipment_part_path(@shipment_model, next_step)
      else
        redirect_to track_shipment_path(@shipment)
      end
    else
      #@shipment_model.valid?
      @shipment = @shipment_model
      @step_name = step
      @step_index = STEPS.index(@step_name)
      render step, :error => "Please complete all required fields"
    end
  end

  class << self   
    def name_for_step(step)
      # if not defined, the code will auto-humanize the name
      STEP_NAMES[step]
    end
  end

  private

  def permitted_attributes
    self.send("#{step}_attributes")
  end

  def authorize_shipment
    @shipment = wizard_step_shipment
    if user_signed_in?
      raise CanCan::AccessDenied unless @shipment.user_id == current_user.id
    else
      raise CanCan::AccessDenied unless @shipment.user_token == session[:user_token]
    end
  end

  def wizard_step_shipment
    shipment_klass = "Shipment::#{step.camelcase}".constantize rescue Shipment
    shipment_klass.find(params[:shipment_id])
  end

  def step
    STEPS.find { |a_step| a_step == params[:id].to_s.downcase }
  end

  def next_step
    current_step_index = STEPS.index(step)
    next_step = STEPS[current_step_index+1]
  end

  def location_info_attributes
    return {} unless params[:shipment]
    params[:shipment].permit(:pickup_date, :origin_address_attributes => [:id, :company_name, :contact_name, :address_1, :address_2, :city, :state, :zipcode, :phone, :location_type], :destination_address_attributes => [:id,  :company_name, :contact_name, :address_1, :address_2, :city, :state, :zipcode, :phone, :location_type])
  end

  def freight_attributes
    return {} unless params[:shipment]
    params[:shipment].permit(:accessorials => [], :freight_items_attributes => [:id, :weight, :weight_unit, :freight_type, :freight_class_code, :quantity, :hazardous, :dim_length, :dim_width, :dim_height, :estimated_value, :piece_count, :accessorials => []])
  end

  def quoting_attributes
    {}
  end

  def booking_attributes
    {}
  end

  def results_attributes
    return {} unless params[:shipment]
    params[:shipment].permit(:selected_carrier)
  end

  def summary_attributes

    params[:shipment] ||= {}

    # this is our way of hacking this into model-space
    if user_signed_in?
      params[:shipment][:user_signed_in] = true
    else
      params[:shipment][:user_signed_in] = false
    end

    params[:shipment].permit(:login_email, :login_password, :register_email, :register_password, :register_password_confirmation, :user_signed_in, :hazardous_materials_phone, :special_instructions, :freight_items_attributes => [:id, :bol_description, :nmfc, :nmfc_sub], :origin_address_attributes => [:id, :company_name, :contact_name, :address_1, :address_2, :city, :state, :zipcode, :phone, :address_state], :destination_address_attributes => [:id,  :company_name, :contact_name, :address_1, :address_2, :city, :state, :zipcode, :phone, :address_state])

  end

  def payment_attributes
    params[:shipment].permit(:payment_method_id, :status)
  end

  def callbacks_for_step(step)
    if self.respond_to?("#{step}_callback",true)
      return self.send("#{step}_callback")
    else
      return true
    end
  end

  def summary_callback
    unless user_signed_in?
      if @shipment_model.user
        sign_in @shipment_model.user
        @shipment = Shipment.find(@shipment_model.id)
        @shipment.user_id = @shipment_model.user.id
        @shipment.save
      end
    end
    return true
  end

  def payment_callback
    return false unless params[:shipment][:tc] == "on"
    return true if @shipment.status == Shipment::SHIPMENT_STATUS_BOOKED
    @shipment.status = Shipment::SHIPMENT_STATUS_INPROCESS
    @shipment.save
    @shipment.book!
    return true
  end

  def results_callback
    @shipment.reload
    @shipment.selected_quote_price = @shipment.total_price
    @shipment.save
  end

  def freight_callback
    @shipment.reload
    @shipment.status = Shipment::SHIPMENT_STATUS_OPEN
    @shipment.save
    @shipment.fetch_quotes
    return true
  end

end