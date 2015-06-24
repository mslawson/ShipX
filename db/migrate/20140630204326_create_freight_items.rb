class CreateFreightItems < ActiveRecord::Migration
  def change
    create_table :freight_items do |t|
      t.integer :shipment_id, :null => false
      t.decimal :weight, :null => false, :precision => 10, :scale => 2
      t.string :weight_unit, :null => false
      t.string :freight_class_code
      t.string :freight_type, :null => false
      t.integer :quantity, :null => false, :default => 1
      t.boolean :hazardous, :null => false, :default => 0
      t.string :nmfc
      t.string :nmfc_sub
      t.string :purchase_order
      t.string :bol_description
      t.string :freight_identifier

      t.timestamps
    end
    add_index :freight_items, :shipment_id
  end
end
