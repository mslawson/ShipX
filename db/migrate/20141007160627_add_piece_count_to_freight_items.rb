class AddPieceCountToFreightItems < ActiveRecord::Migration
  def change
    add_column :freight_items, :piece_count, :integer, :default => 1
  end
end
