class AddAvailableCreditToCreditApplication < ActiveRecord::Migration
  def change
    add_column :credit_applications, :available_credit, :decimal, :precision => 10, :scale => 2, :default => 0.00
  end
end
