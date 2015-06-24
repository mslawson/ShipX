class OrderConfirmationMailer < ActionMailer::Base
  default from: "shipx@nine70labs.com"
  #include Resque::Mailer
  layout 'email'
  add_template_helper(ShipmentsHelper)

  def order_confirmation(shipment)
    @shipment = shipment
    mail(to: shipment.user.email, subject: "ShipX Order Confirmation #{shipment.id}")
  end

end
