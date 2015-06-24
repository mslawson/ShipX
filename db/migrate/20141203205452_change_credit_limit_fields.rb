class ChangeCreditLimitFields < ActiveRecord::Migration
  def change
    rename_column :credit_applications, :credit_line, :requested_credit_line
    add_column :credit_applications, :approved_credit_line, :integer
  end
end
