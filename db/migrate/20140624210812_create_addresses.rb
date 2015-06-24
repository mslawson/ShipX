class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :company_name
      t.string :contact_name
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :phone
      t.string :fax
      t.string :email
      t.datetime :close_time

      t.timestamps
    end
  end
end
