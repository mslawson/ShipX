class CreatePaymentMethods < ActiveRecord::Migration
  def change
    create_table :payment_methods do |t|
      t.integer :user_id, :null => false
      t.integer :payment_method_type, :null => false
      t.string :rebill_id
      t.boolean :saved, :null => false, :default => 1
      t.integer :cc_expiration_month
      t.integer :cc_expiration_year
      t.integer :cc_last_four

      t.timestamps
    end
  end
end
