class Payment < ActiveRecord::Base

  PAYMENT_STATUS_SUCCESS = 1
  PAYMENT_STATUS_FAILED  = 0

  has_many :payment_splits
end
