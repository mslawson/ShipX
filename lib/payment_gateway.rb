class PaymentGateway

  def self.create_hold(shipment)

    hold = Stripe::Charge.create(
        amount: (shipment.total_price.to_f * 100).to_i, # to cents
        currency: 'usd',
      description: "Shipment #{shipment.id}",
        statement_descriptor: "ShipX Shipment #{shipment.id}",
        capture: false,
        customer: shipment.user.stripe_id,
        destination: ConfigurationItem.default_merchant_account,
        application_fee: ((shipment.shipx_fee + shipment.processing_fee)*100).to_i,
        source: shipment.payment_method.rebill_id
    )

    Rails.logger.info "Created card hold: #{hold.id}"
    return hold.id

  end

  def self.void_hold(token)
    # do nothing?
  end

  def self.capture_hold(token,shipment)

    charge = Stripe::Charge.retrieve(token)
    charge.capture

    payment = Payment.create(
        shipment_id: shipment.id,
        payment_method_id: shipment.payment_method_id,
        status: Payment::PAYMENT_STATUS_SUCCESS,
        transaction_id: charge.id,
        amount: (charge.amount.to_f/100).round(2)
    )

    PaymentSplit.create(
        payment_id: payment.id,
        amount: shipment.total_price.to_f - shipment.shipx_fee - shipment.processing_fee,
        fund: PaymentSplit::PAYMENT_SPLIT_CARRIER_PORTION
    )

    PaymentSplit.create(
        payment_id: payment.id,
        amount: shipment.shipx_fee,
        fund: PaymentSplit::PAYMENT_SPLIT_SHIPX_FEE
    )

    PaymentSplit.create(
        payment_id: payment.id,
        amount: shipment.processing_fee,
        fund: PaymentSplit::PAYMENT_SPLIT_SHIPX_SERVICE_FEE
    )

    return charge.id

  end

end