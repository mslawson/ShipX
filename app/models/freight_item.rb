class FreightItem < ActiveRecord::Base
  belongs_to :shipment

  validates_numericality_of :quantity, presence: true
  validates_numericality_of :weight, presence: true
  validates_numericality_of :dim_length, presence: true
  validates_numericality_of :dim_width, presence: true
  validates_numericality_of :dim_height, presence: true
  validates_numericality_of :estimated_value, presence: true, :allow_nil => true
 

  serialize :accessorials, JSON

  # i can't figure out how to get a default return value that's not "null" from serialize, :accessorials
  def accessorials_obj
    if self.accessorials.nil?
      return []
    else
      return self.accessorials
    end
  end

  def as_soap_object

    accs = []
    unless accessorials.nil?
      accessorials.each do |acc|
        accs << {'AccessorialKey' => acc} if (acc && !acc.blank?)
      end
    end

    {
      'Weight' => weight,
      'FreightClass' => freight_class_code,
      'HandlingUnitsType' => freight_type,
      'NumHandlingUnits' => quantity, # what is this?
      'NumPieces' => piece_count || 1,
      'Nmfc' => nmfc,
      'Sub' => nmfc_sub,
      'PurchaseOrder' => purchase_order,
      'Description' => bol_description,
      'FreightAccessorials' => {'Accessorial' => accs},
      'Dimensions' => [],
      'FreightIdentifier' => freight_identifier
    }
  end

  def requires_piece_count?
    (self.freight_type == 'TYPE_CRATE') || (self.freight_type == 'PALLET_XXX')
  end

end
