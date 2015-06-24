class ChangeShipmentDateToDateTime < ActiveRecord::Migration
  def change
    change_column :shipments, :pickup_date, :datetime
  end
end
