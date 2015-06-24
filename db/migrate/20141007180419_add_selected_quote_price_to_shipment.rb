class AddSelectedQuotePriceToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :selected_quote_price, :decimal, :precision => 10, :scale => 2
  end
end
