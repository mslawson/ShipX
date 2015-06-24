module AddressesHelper

  def address_short_name(address)
    "#{address.city}, #{address.state} #{address.zipcode}"
  end

end
