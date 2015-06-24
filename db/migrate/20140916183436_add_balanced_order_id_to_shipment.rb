class AddBalancedOrderIdToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :balanced_order_id, :string
  end
end
