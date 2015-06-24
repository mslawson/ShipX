class MyFreightWorld

  def initialize

    @client = Savon.client(wsdl: File.join(Rails.root, 'public', 'wsdl', MY_FREIGHT_WORLD["wsdl_file"]),
      log_level: :debug,
      read_timeout: 90,
      log: true) do
      pretty_print_xml true
    end

  end

  def authenticate

    request = {'quoteServiceKey' => MY_FREIGHT_WORLD["quote_service_key"]}
    response = @client.call(:authenticate, message: request)
    @auth_key = response.body[:authenticate_response][:authenticate_result]

    Rails.logger.info response
  end

  def import_data_dictionaries

    response = make_request(:get_data_dictionary)

    response.body[:get_data_dictionary_response][:get_data_dictionary_result].each do |dict_type, values|

      dictionary      = Dictionary.where(:code => dict_type).first_or_initialize
      dictionary.name = humanize_key_name(dict_type)
      dictionary.save

      values[:entries][:dictionary_entry].each do |entry|
        dict_entry      = DictionaryEntry.where(dictionary_id: dictionary.id, key: entry[:key]).first_or_initialize
        dict_entry.name = entry[:description]
        dict_entry.save
      end

    end

  end

  def update_tracking(shipment)

    authenticate

    if @auth_key

      response = make_request(:get_shipment_status, {'connectionKey' => @auth_key, 'bol' => shipment.bol})

      if status = response.body[:get_shipment_status_response][:get_shipment_status_result]
        current_status = shipment.shipment_events.first
        if !current_status || (current_status.message != status[:description])
          ShipmentEvent.create(shipment_id: shipment.id, status_key: status[:status_key], message: status[:description])
          if status[:status_key] == "EXT_DELVRD"
            shipment.status = Shipment::SHIPMENT_STATUS_DELIVERED
            shipment.save
          end
        end
      end

    end

  end

  def fetch_simple_quote(shipment)

    authenticate

    if @auth_key
      response = make_request(:generate_quotes, {'connectionKey' => @auth_key, 'shipment' => shipment.as_quote_object})
#      response = mock_quotes

      Rails.logger.info response
      return response.body[:generate_quotes_response][:generate_quotes_result]

    else
      # authentication error
      raise "Authentication error"

    end

  end

#   def fetch_basic_quote
#
#     shipment =     {
#           'RecordType'              => 'QUOTEONLYX',
#           'ShipmentID'              => "Shipment",
#           'VendorID'                => "ShipX",
#           'PickupReadyDateTime'     => "2014-10-23T12:12:12",
#           'Origin'                  =>        {
#                 'CompanyName' => 'nanme',
#                 'ContactName' => 'name',
#                 'Street1' => '7062 shadow glen dr',
#                 'Street2' => '',
#                 'City' => 'Frisco',
#                 'State' => 'TX',
#                 'Zipcode' => 75035,
#                 'Phone' => '555-444-1212',
#                 'Fax' => '555-444-1212',
#               #'LocationTypeAccessorial' => location_type,
#                 'Email' => 'test@me.com',
#                 'CloseTime' => '2014-07-09T20:00:00',
#                 'PurchaseOrder' => "po"
#               },
#           'Destination'             =>     {
#                 'CompanyName' => 'company_name',
#                 'ContactName' => 'contact_name',
#                 'Street1' => '2130 Westridge',
#                 'Street2' => '',
#                 'City' => 'Wichita',
#                 'State' => 'KS',
#                 'Zipcode' => 67203,
#                 'Phone' => '555-444-1212',
#                 'Fax' => '555-444-1212',
#               #'LocationTypeAccessorial' => location_type,
#                 'Email' => 'test@me.com',
#                 'CloseTime' => '2014-07-09T20:00:00',
#                 'PurchaseOrder' => "po"
#               },
#           'ShipmentAccessorials'    => [],
#           'FreightItems'            => {"Freight" =>     [{
#                 'Weight' => 25,
#                 'FreightClass' => 60,
#                 'HandlingUnitsType' => 'TYPE_BOXXX',
#                 'NumHandlingUnits' => 1, # what is this?
#                 'NumPieces' => 1,
#                 'FreightAccessorials' => []
#               }]},
#           'ExtraBOLInfo'            => "bol",
#           'SpecialInstructions'     => "inst"
#         }
#
#     authenticate
#
#     if @auth_key
#       response = make_request(:generate_quotes, {'connectionKey' => @auth_key, 'shipment' => shipment})
# #      response = mock_quotes
#
#       Rails.logger.info response
#       return response.body[:generate_quotes_response][:generate_quotes_result]
#
#     else
#       # authentication error
#       raise "Authentication error"
#
#     end
#
#   end
#
#   def fetch_full_quote
#
#     shipment =     {
#           'RecordType'              => 'QUOTEONLYX',
#           'ShipmentID'              => "Shipment",
#           'VendorID'                => "ShipX",
#           'PickupReadyDateTime'     => "2014-10-23T12:12:12",
#           'Origin'                  =>    {
#                 'Zipcode' => 75035
#               },
#           'Destination'             => {
#                           'Zipcode' => 67203
#                         },
#           'ShipmentAccessorials'    => [],
#           'FreightItems'            => {"Freight" =>     [{
#                 'Weight' => 25,
#                 'FreightClass' => 60,
#                 'HandlingUnitsType' => 'TYPE_BOXXX',
#                 'NumHandlingUnits' => 1, # what is this?
#                 'NumPieces' => 1,
#                 'FreightAccessorials' => []
#               }]},
#           'ExtraBOLInfo'            => "bol",
#           'SpecialInstructions'     => "inst"
#         }
#
#     authenticate
#
#     if @auth_key
#       response = make_request(:generate_quotes, {'connectionKey' => @auth_key, 'shipment' => shipment})
# #      response = mock_quotes
#
#       Rails.logger.info response
#       return response.body[:generate_quotes_response][:generate_quotes_result]
#
#     else
#       # authentication error
#       raise "Authentication error"
#
#     end
#
#   end

  def fetch_full_quote(shipment)

    authenticate

    if @auth_key
      response = make_request(:generate_quotes, {'connectionKey' => @auth_key, 'shipment' => shipment.as_soap_object})
#      response = mock_quotes

      Rails.logger.info response
      return response.body[:generate_quotes_response][:generate_quotes_result]

    else
      # authentication error
      raise "Authentication error"

    end

  end

  def book_shipment(shipment)

    authenticate

    if @auth_key

      response = make_request(:book_shipment_from_quote, {'connectionKey' => @auth_key, 'bookingKey' => shipment.selected_quote})

      # <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
      #   <soap:Body>
      #     <BookShipmentFromQuoteResponse xmlns="http://webapi.myfreightworld.com/MFWQuoteBookService/1_3">
      #       <BookShipmentFromQuoteResult>
      #         <Bol>V_5_95177</Bol>
      #         <BolFileLocation>http://webapi.myfreightworld.com/WebDocuments_Dev/BOL/BOL__42QY19EHS_V_5_95177.pdf</BolFileLocation>
      #         <TerminalOriginationCode>260</TerminalOriginationCode>
      #         <TerminalOriginationPhone>2142671620</TerminalOriginationPhone>
      #         <TerminalDestinationCode>260</TerminalDestinationCode>
      #         <TerminalDestinationPhone>2142671620</TerminalDestinationPhone>
      #       </BookShipmentFromQuoteResult>
      #     </BookShipmentFromQuoteResponse>
      #   </soap:Body>
      # </soap:Envelope>

     Rails.logger.info response
     return response.body[:book_shipment_from_quote_response][:book_shipment_from_quote_result]

    else
     # authentication error
     raise "Authentication error"

    end

  end

  private

  def make_request(request, body={})
    begin
      @client.call(request,message: body)
    rescue Savon::SOAPFault => error
      Rails.logger.error error

      if error.to_hash[:fault][:detail][:error].is_a?(Array)
        err = error.to_hash[:fault][:detail][:error].map{|e| "#{e[:error_code]}: #{e[:error_message]}"}.join(", ")
      else
        err = "#{error.to_hash[:fault][:detail][:error][:error_code]}: #{error.to_hash[:fault][:detail][:error][:error_message]}"
      end

      raise err
    end
  end

  def humanize_key_name(key)
    key.to_s.humanize.split.map(&:capitalize).join(" ")
  end

  def mock_quotes

    quotes = []
    (1..5).each do |n|

      quote = {
          'BookingKey' => 'bookmepls',
          'DisplayName' => 'GoodTime Carrier',
          'CarrierKey' => 'GTCG',
          'CarrierSCAC' => 'GTCG',
          'ContractOwnership' => 'Brokers, Inc',
          'ContractOwnershipKey' => 'BICTG',
          'DeliveryDays' => 8,
          'TotalCost' => 652.32,
          'TotalPrice' => 602.32,
          'TotalFreightCost' => 602.32,
          'TotalFreightPrice' => 552.32,
          'PickupLocationAccessorial' => [{
            'Description' => '',
            'AccessorialKey' => 'BUSUNESSXX',
            'Cost' => 0.00,
            'Price' => 0.00
          }],
          'ShipmentAccessorials' => [],
          'PickupAccessorials' => [],
          'DeliveryAccessorials' => [],
          'FreightItem' => []
      }

      quotes << quote
    end

    {'QuoteKey' => 'quotekey','Quotes' => quotes}



  end

end