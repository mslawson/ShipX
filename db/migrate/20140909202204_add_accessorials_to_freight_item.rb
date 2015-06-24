class AddAccessorialsToFreightItem < ActiveRecord::Migration
  def change
    add_column :freight_items, :accessorials, :text
  end
end
