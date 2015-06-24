class AddUserTokenToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :user_token, :string
  end
end
