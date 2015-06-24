class AddEstimatedValueToFreightItems < ActiveRecord::Migration
  def change
    add_column :freight_items, :estimated_value, :decimal, :precision => 10, :scale => 2
  end
end
