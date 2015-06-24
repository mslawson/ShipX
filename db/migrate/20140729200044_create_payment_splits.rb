class CreatePaymentSplits < ActiveRecord::Migration
  def change
    create_table :payment_splits do |t|
      t.integer :payment_id, :null => false
      t.decimal :amount, :precision => 10, :scale => 2, :null => false
      t.integer :fund, :null => false

      t.timestamps
    end
  end
end
