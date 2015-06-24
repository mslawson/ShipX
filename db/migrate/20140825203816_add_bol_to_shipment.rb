class AddBolToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :bol, :string
  end
end
