require 'open-uri'

module PublicAddress
  def self.as_ip_address
    open('http://whatismyip.akamai.com').read
  end

  def self.as_cidr
    "#{as_ip_address}/32"
  end
end
