class RemoveAccessorialsFromAddress < ActiveRecord::Migration
  def change
    remove_column :addresses, :accessorials
    add_column :addresses, :location_type, :string
  end
end
