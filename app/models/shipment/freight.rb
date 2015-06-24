class Shipment::Freight < Shipment

  validates_presence_of :freight_items, :message => "must be added"
  validates_associated :freight_items, :message => "need weight, quantity, and dimensions provided."

  #after_update :fetch_quotes

  before_save :check_hazardous

  private

  def check_hazardous
    freight_items.each do |fi|
      if fi.hazardous?
        fi.accessorials = [] if fi.accessorials.nil?
        fi.accessorials << "HAZARDOUSX" unless fi.accessorials.include?("HAZARDOUSX")
      end
    end
  end

end