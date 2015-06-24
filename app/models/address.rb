class Address < ActiveRecord::Base

  ADDRESS_STATE_STUB_QUOTE = 0
  ADDRESS_STATE_READY_TO_BOOK = 1

  with_options if: :is_ready_to_book? do |addr|
    addr.validates :address_1, presence: true
    addr.validates :city, presence: true
    addr.validates :state, presence: true
    addr.validates :company_name, presence: true
    addr.validates :contact_name, presence: true
    addr.validates :phone, presence: true
  end
  validates_presence_of :zipcode, :location_type

  def as_soap_object
    {
      'CompanyName' => company_name,
      'ContactName' => contact_name,
      'Street1' => address_1,
      'Street2' => address_2,
      'City' => city,
      'State' => state,
      'Zipcode' => zipcode,
      'Phone' => phone,
      'Fax' => fax,
      'LocationTypeAccessorial' => {
          'AccessorialKey' => location_type
      },
      'Email' => email,
      'CloseTime' => '2014-07-09T20:00:00',
      'PurchaseOrder' => "po"
    }
  end

  def as_quoting_object
    {
        'Zipcode' => zipcode,
        'LocationTypeAccessorial' => {
          'AccessorialKey' => location_type
        }
    }
  end

  def as_url
    URI::escape("#{address_1}, #{city}, #{state}, #{zipcode}, United States")
  end

  def as_html_block
    rows = []
    rows << company_name if company_name
    rows << contact_name if contact_name
    rows << address_1
    rows << address_2 if address_2 && !address_2.empty?
    rows << "#{city}, #{state} #{zipcode}"
    rows << "Phone: #{phone}" if phone
    rows << "Fax: #{fax}" if fax
    rows << "Email: #{email}" if email
    rows.join("<br/>")
  end

  private

  def is_ready_to_book?
    self.address_state == ADDRESS_STATE_READY_TO_BOOK
  end

end
