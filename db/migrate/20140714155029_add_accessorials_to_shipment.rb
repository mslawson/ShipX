class AddAccessorialsToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :accessorials, :text
  end
end
