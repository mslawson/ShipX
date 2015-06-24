class AddSelectedQuoteToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :selected_quote, :string
  end
end
