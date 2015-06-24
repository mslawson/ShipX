module CreditApplicationsHelper

  def credit_application_status(credit_application)
    if credit_application.pending?
      "Pending"
    elsif credit_application.approved?
      "Approved"
    elsif credit_application.denied?
      "Denied"
    end

  end

end
