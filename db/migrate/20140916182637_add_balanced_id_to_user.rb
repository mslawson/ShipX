class AddBalancedIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :balanced_id, :string
  end
end
