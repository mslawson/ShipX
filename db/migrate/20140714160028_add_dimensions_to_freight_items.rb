class AddDimensionsToFreightItems < ActiveRecord::Migration
  def change
    add_column :freight_items, :dim_length, :decimal, :precision => 10, :scale => 2
    add_column :freight_items, :dim_width, :decimal, :precision => 10, :scale => 2
    add_column :freight_items, :dim_height, :decimal, :precision => 10, :scale => 2
  end
end
