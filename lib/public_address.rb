require 'net/http'
require 'uri'

module PublicAddress
  def self.as_ip_address
    uri = URI.parse('http://whatismyip.akamai.com')
    response = Net::HTTP.get_response(uri)
    response.body
  end

  def self.as_cidr
    "#{as_ip_address}/32"
  end
end
