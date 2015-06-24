class CreateConfigurationItems < ActiveRecord::Migration
  def change
    create_table :configuration_items do |t|
      t.string :configuration_key, :null => false
      t.string :configuration_value, :null => false
      t.timestamps
    end
    add_index :configuration_items, :configuration_key, :unique => true
  end
end
