class AddSelectedCarrierToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :selected_carrier, :string
  end
end
