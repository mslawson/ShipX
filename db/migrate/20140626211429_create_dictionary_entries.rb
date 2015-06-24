class CreateDictionaryEntries < ActiveRecord::Migration
  def change
    create_table :dictionary_entries do |t|
      t.string :name, :null => false
      t.string :key, :null => false
      t.integer :dictionary_id, :null => false

      t.timestamps
    end
  end
end
