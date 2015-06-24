class CreateCreditEvents < ActiveRecord::Migration
  def change
    create_table :credit_events do |t|
      t.integer :credit_application_id, :null => false
      t.integer :shipment_id, :null => false
      t.integer :status, :null => false
      t.decimal :amount, :null => false, :precision => 10, :scale => 2

      t.timestamps
    end
  end
end
