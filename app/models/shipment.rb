class Shipment < ActiveRecord::Base

  SHIPMENT_STATUS_OPEN      = 0
  SHIPMENT_STATUS_QUOTED    = 1
  SHIPMENT_STATUS_BOOKED    = 2
  SHIPMENT_STATUS_DECLINED  = 3
  SHIPMENT_STATUS_EXPIRED   = 4
  SHIPMENT_STATUS_ERROR     = 5
  SHIPMENT_STATUS_INPROCESS = 6
  SHIPMENT_STATUS_DELIVERED = 7

  belongs_to :origin_address, class_name: 'Address', autosave: true
  belongs_to :destination_address, class_name: 'Address', autosave: true
  belongs_to :user
  belongs_to :payment_method

  has_many :freight_items, autosave: true
  has_many :shipment_events
  has_many :payments, class_name: '::Payment'

  accepts_nested_attributes_for :origin_address, :destination_address
  accepts_nested_attributes_for :freight_items

  # transient devise attributes
  cattr_accessor :login_email, :login_password, :register_email, :register_password, :register_password_confirmation, :user_signed_in

  serialize :quote_payload, JSON
  serialize :accessorials, JSON

  scope :active, -> { where(status: [SHIPMENT_STATUS_OPEN, SHIPMENT_STATUS_QUOTED, SHIPMENT_STATUS_ERROR]) }
  scope :booked, -> { where(status: [SHIPMENT_STATUS_BOOKED]) }
  scope :delivered, -> { where(status: [SHIPMENT_STATUS_DELIVERED]) }

  # is this the right term for this?
  scope :complete, -> { where(status: [SHIPMENT_STATUS_BOOKED, SHIPMENT_STATUS_DELIVERED]) }

  def in_error_state?
    self.status == SHIPMENT_STATUS_ERROR
  end

  def hazardous?
    freight_items.each do |fi|
      return true if fi.hazardous?
    end
    return false
  end

  def editable?
    [SHIPMENT_STATUS_OPEN, SHIPMENT_STATUS_QUOTED, SHIPMENT_STATUS_ERROR, SHIPMENT_STATUS_INPROCESS].include? status
  end

  def booked?
    self.status == SHIPMENT_STATUS_BOOKED
  end

  def fetch_quotes
    Resque.enqueue(SimpleQuote, self.id)
  end

  def sorted_quotes
    to_iter = (quote_payload['quotes']['quote'].is_a?(Hash)) ? [quote_payload['quotes']['quote']] : quote_payload['quotes']['quote']
    quotes = to_iter.sort do |x,y|
      x['total_price'].to_f <=> y['total_price'].to_f
    end
  end

  def shipment_accessorials
    if quote_payload && quote["shipment_accessorials"] && quote["shipment_accessorials"]["accessorial"]
      return quote_payload["shipment_accessorials"]["accessorial"]
    else
      return quote_payload["shipment_accessorials"]
    end
  end

  def selected_quote_object

    to_iter = (quote_payload['quotes']['quote'].is_a?(Hash)) ? [quote_payload['quotes']['quote']] : quote_payload['quotes']['quote']

    if !selected_quote.nil?
      to_iter.each do |quote|
        return quote if quote['booking_key'] == selected_quote
      end
    end

    if !selected_carrier.nil?
      to_iter.each do |quote|
        return quote if quote['carrier_key'] == selected_carrier
      end
    end

    return nil
  end

  def book!
    Resque.enqueue(Book,self.id)
  end

  def total_price
    format("%.2f",selected_quote_object['total_price'].to_f + shipx_fee + processing_fee)
  end

  def shipx_fee
    ConfigurationItem.standard_shipx_fee
  end

  def carrier_portion
    selected_quote_object['total_price'].to_f
  end

  def processing_fee(rate=nil)
    if rate.nil?
      ((selected_quote_object['total_price'].to_f + shipx_fee) * ConfigurationItem.var_service_fee).round(2)+ConfigurationItem.fixed_service_fee
    else
      ((rate.to_f + shipx_fee) * ConfigurationItem.var_service_fee).round(2)+ConfigurationItem.fixed_service_fee
    end
  end

  def as_soap_object
    fis = []
    freight_items.each do |fi|
      fis << fi.as_soap_object
    end

    accs = []
    unless accessorials.nil?
      accessorials.each do |acc|
        accs << {'AccessorialKey' => acc} if (acc && !acc.blank?)
      end
    end

    # QUOTEDSHIP
    {
      'RecordType'              => 'QUOTEDSHPM',
      'ShipmentID'              => "Shipment-#{id}",
      'VendorID'                => "ShipX",
      'HazardousMaterialsPhone' => hazardous_materials_phone,
      'PickupReadyDateTime'     => pickup_date.strftime("%Y-%m-%dT%H:%M:00"),
      'Origin'                  => origin_address.as_soap_object,
      'Destination'             => destination_address.as_soap_object,
      'ShipmentAccessorials'    => {'Accessorial' => accs},
      'FreightItems'            => {"Freight" => fis},
      'ExtraBOLInfo'            => "bol",
      'SpecialInstructions'     => "inst"
    }
  end

  def as_quote_object
    fis = []
    freight_items.each do |fi|
      fis << fi.as_soap_object
    end

    accs = []
    unless accessorials.nil?
      accessorials.each do |acc|
        accs << {'AccessorialKey' => acc} if (acc && !acc.blank?)
      end
    end

    # QUOTEDSHIP
    {
      'RecordType'              => 'QUOTEONLYX',
      'ShipmentID'              => "Shipment-#{id}",
      'VendorID'                => "ShipX",
      'PickupReadyDateTime'     => pickup_date.strftime("%Y-%m-%dT%H:%M:00"),
      'Origin'                  => origin_address.as_quoting_object,
      'Destination'             => destination_address.as_quoting_object,
      'ShipmentAccessorials'    => {'Accessorial' => accs},
      'FreightItems'            => {"Freight" => fis}
    }
  end

end
