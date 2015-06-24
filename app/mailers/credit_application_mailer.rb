class CreditApplicationMailer < ActionMailer::Base
  default from: "shipx@nine70labs.com"
  include Resque::Mailer
  layout 'email'
  include ActionView::Helpers::NumberHelper

  def app_submitted(credit_app)
    @credit_app = credit_app
    mail(to: 'david@nine70labs.com', subject: "New ShipX Credit Application")
  end

  def app_approved(credit_app)
    @credit_app = credit_app
    mail(to: credit_app.user.email, subject: "ShipX Credit Application Approved")
  end

  def app_rejected(credit_app)
    @credit_app = credit_app
    mail(to: credit_app.user.email, subject: "ShipX Credit Application Denied")
  end

end
