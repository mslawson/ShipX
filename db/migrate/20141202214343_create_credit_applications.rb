class CreateCreditApplications < ActiveRecord::Migration
  def change
    create_table :credit_applications do |t|
      t.string :company_name, :null => false
      t.string :alternate_name
      t.string :contact_name, :null => false
      t.string :title
      t.string :phone_number, :null => false
      t.string :company_address_1, :null => false
      t.string :company_address_2
      t.string :city, :null => false
      t.string :state, :null => false
      t.string :zip_code, :null => false
      t.integer :status, :null => false, :default => 0
      t.integer :user_id, :null => false
      t.text :message
      t.decimal :credit_line, :precision => 10, :scale => 2

      t.timestamps
    end
  end
end
