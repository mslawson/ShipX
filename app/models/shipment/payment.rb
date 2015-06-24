class Shipment::Payment < Shipment

  validates_presence_of :payment_method_id

end