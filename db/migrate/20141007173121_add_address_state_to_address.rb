class AddAddressStateToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :address_state, :integer, :default => 0, :null => false
  end
end
