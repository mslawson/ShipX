class AddQuoteTimeToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :quote_time, :datetime
  end
end
