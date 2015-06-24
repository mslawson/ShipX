class PaymentMethod < ActiveRecord::Base

  PAYMENT_METHOD_TYPE_CC = 0
  PAYMENT_METHOD_TYPE_LOC = 1

  belongs_to :user
  belongs_to :credit_application

  def description
    if self.payment_method_type == PAYMENT_METHOD_TYPE_CC
      "Credit Card xxxx-xxxx-xxxx-#{cc_last_four} exp #{cc_expiration_month}/#{cc_expiration_year}"
    else
      "Line of Credit"
    end
  end

  def is_cc?
    self.payment_method_type == PAYMENT_METHOD_TYPE_CC
  end

  def is_loc?
    self.payment_method_type == PAYMENT_METHOD_TYPE_LOC
  end

end
