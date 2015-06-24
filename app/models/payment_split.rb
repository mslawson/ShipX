class PaymentSplit < ActiveRecord::Base

  PAYMENT_SPLIT_SHIPX_FEE = 0
  PAYMENT_SPLIT_SHIPX_SERVICE_FEE = 1
  PAYMENT_SPLIT_CARRIER_PORTION = 2

  belongs_to :payment

  def fund_description
    case fund
      when PAYMENT_SPLIT_CARRIER_PORTION
        "Carrier Portion"
      when PAYMENT_SPLIT_SHIPX_SERVICE_FEE
        "Processing Fee"
      when PAYMENT_SPLIT_SHIPX_FEE
        "ShipX Fee"
    end
  end
end
