class AddBalancedStatusesToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :balanced_debit_id, :string
    add_column :shipments, :balanced_debit_href, :string
  end
end
