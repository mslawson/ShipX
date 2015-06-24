class AddHoldTokenToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :hold_id, :string
  end
end
