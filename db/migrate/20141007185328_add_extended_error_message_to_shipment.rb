class AddExtendedErrorMessageToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :extended_error_message, :text
  end
end
