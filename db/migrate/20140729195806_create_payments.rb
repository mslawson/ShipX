class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :shipment_id, :null => false
      t.integer :payment_method_id, :null => false
      t.integer :status, :null => false
      t.integer :error_code
      t.string :error_message
      t.string :transaction_id
      t.string :rebill_token
      t.decimal :amount, :precision => 10, :scale => 2, :null => false

      t.timestamps
    end
  end
end
