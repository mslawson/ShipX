class AddErrorInfoToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :error_message, :string
  end
end
