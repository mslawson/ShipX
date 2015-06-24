class AddAccessorialsToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :accessorials, :text
  end
end
