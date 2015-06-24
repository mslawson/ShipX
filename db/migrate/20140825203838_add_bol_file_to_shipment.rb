class AddBolFileToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :bol_file, :string
  end
end
