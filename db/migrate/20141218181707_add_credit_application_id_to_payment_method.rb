class AddCreditApplicationIdToPaymentMethod < ActiveRecord::Migration
  def change
    add_column :payment_methods, :credit_application_id, :integer
  end
end
