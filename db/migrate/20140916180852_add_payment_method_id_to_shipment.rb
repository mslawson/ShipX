class AddPaymentMethodIdToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :payment_method_id, :integer
  end
end
