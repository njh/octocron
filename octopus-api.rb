#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'uri'


class OctopusAPI
  BASE_URL="https://api.octopus.energy/v1/"

  # The Octopus API key, as found on the Developer Dashboard
  # https://octopus.energy/dashboard/developer/
  attr_accessor :api_key

  # The Octopus account number, as found on the dashboard
  # https://octopus.energy/dashboard/
  attr_accessor :account_number

  def initialize(params={})
    params.each_pair do |key, value|
      setter = "#{key}="
      if respond_to?(setter)
        self.send(setter, value)
      end
    end
  end

  def account_info(account_number=nil)
    account_number = @account_number if account_number.nil?
    raise "No account number given" if account_number.nil?

  	result = get("accounts/#{account_number}/")
  	# I suspect that there can be more than one property but lets keep things simple
  	result[:properties].first
  end

  def grid_supply_point(postcode=nil)
    if postcode.nil?
      raise "No postcode and no account number given" if @account_number.nil?
      postcode = account_info[:postcode]
    end
  
  	result = get('industry/grid-supply-points/', postcode: postcode)
  	
  	# I suspect that there can be more than one result but lets keep things simple
  	if result[:count] === 0
  	  raise "No Grid Supply Points Found"
  	elsif result[:count] === 1
  	  result[:results].first[:group_id]
  	else
  	  raise "More than one Grid Supply Point found"
  	end
  end
  
  def tarrif_to_product(code)
    parts = code.split('-')
    parts.slice(2, parts.length - 3).join('-')
  end

  def get(path, query={})
    uri = URI.parse(BASE_URL + path)
    uri.query = URI.encode_www_form(query)
    
    puts "Fetching: #{uri}"
    response = nil
	Net::HTTP.start(uri.host, uri.port, :use_ssl => (uri.scheme == 'https')) do |http|
	  request = Net::HTTP::Get.new(uri)
      if @api_key
        request.basic_auth(@api_key, '')
      end

	  response = http.request(request)
	  if response.code != '200'
	    raise "Octopus API get failed: #{response}"
	  end
	end

	JSON.parse(response.body, :symbolize_names => true)
  end

end
