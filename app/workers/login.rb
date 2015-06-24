class Login
  @queue = :logins

  def self.perform(username, password)
    soap_client = MyFreightWorldCarrier.new

    begin
      userToken = soap_client.login(username, password)
    end
  end
end