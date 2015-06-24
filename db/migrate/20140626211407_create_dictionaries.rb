class CreateDictionaries < ActiveRecord::Migration
  def change
    create_table :dictionaries do |t|
      t.string :name, :null => false
      t.string :code, :null => false

      t.timestamps
    end
  end
end
