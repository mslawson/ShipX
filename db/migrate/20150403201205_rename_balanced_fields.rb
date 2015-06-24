class RenameBalancedFields < ActiveRecord::Migration
  def change
    rename_column :users, :balanced_id, :stripe_id
    rename_column :shipments, :balanced_debit_id, :stripe_transaction_id
    remove_column :shipments, :balanced_order_id
    remove_column :shipments, :balanced_debit_href
  end
end
