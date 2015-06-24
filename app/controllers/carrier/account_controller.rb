# Exposes account management features to the Carrier module
class Carrier::AccountController < ActionController::Base
  layout "carrier"

  # Login action for carrier
  def login
    if session[:carrier]
      redirect_to :controller => 'carrier/session', :action => "home" and return
    end

    @carrier_signed_in = false
    if request.post?
      carrierEmail = params['email']
      carrierPassword = params['password']

      soap_client = MyFreightWorldCarrier.new
      userToken = soap_client.login(carrierEmail, carrierPassword)
      if userToken
        session[:carrier] = {"email" => carrierEmail, "token" => userToken}
        redirect_to :controller => "carrier/session", :action => "home" and return
      else
        @error = "Invalid credentials, please try again"
      end
    end
  end

  # Logout action for carrier
  def logout
    session.delete(:carrier)
    redirect_to action: "login"
  end
end