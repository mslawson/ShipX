class CreateCarriers < ActiveRecord::Migration
  def change
    create_table :carriers do |t|
      t.string :name
      t.string :carrier_key
      t.string :balanced_id
      t.text :description

      t.timestamps
    end
  end
end
