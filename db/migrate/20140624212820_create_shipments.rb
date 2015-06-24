class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.integer :origin_address_id
      t.integer :destination_address_id
      t.date :pickup_date
      t.integer :user_id
      t.string :hazardous_materials_phone
      t.string :special_instructions
      t.integer :status, :null => false, :default => 0

      t.timestamps
    end
  end
end
