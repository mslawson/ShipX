class CreateShipmentEvents < ActiveRecord::Migration
  def change
    create_table :shipment_events do |t|
      t.integer :shipment_id
      t.string :status_key
      t.string :message
      t.string :url

      t.timestamps
    end
    add_index :shipment_events, :shipment_id
  end
end
