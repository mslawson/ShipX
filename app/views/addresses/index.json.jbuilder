json.array!(@addresses) do |address|
  json.extract! address, :id, :company_name, :contact_name, :address_1, :address_2, :city, :state_id, :zipcode, :phone, :fax, :email, :close_time
  json.url address_url(address, format: :json)
end
