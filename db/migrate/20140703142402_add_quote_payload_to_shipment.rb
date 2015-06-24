class AddQuotePayloadToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :quote_payload, :text
  end
end
