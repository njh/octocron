require 'json'
require 'net/http'
require 'time'
require 'uri'

class OctopusAPI
  BASE_URL = 'https://api.octopus.energy/v1/'.freeze

  # Directory to use as a local disk cache for requests made to Octopus
  # Defaults to ./cache
  attr_accessor :cache_dir

  # The Octopus API key, as found on the Developer Dashboard
  # https://octopus.energy/dashboard/developer/
  attr_accessor :api_key

  # The Octopus account number, as found on the dashboard
  # https://octopus.energy/dashboard/
  attr_accessor :account_number

  # The Grid Supply Point Group ID (aka region)
  # May be looked up using Post Code and #lookup_grid_supply_point
  attr_reader :grid_supply_point

  def initialize(params = {})
    @cache_dir = './cache/'

    params.each_pair do |key, value|
      setter = "#{key}="
      if respond_to?(setter)
        send(setter, value)
      end
    end
  end

  def grid_supply_point=(code)
    @grid_supply_point = code.to_s[-1].upcase
  end

  def account_info(account_number = nil)
    account_number = @account_number if account_number.nil?
    raise 'No account number given' if account_number.nil?

    result = fetch_cached("accounts/#{account_number}")

    # I suspect that there can be more than one property but lets keep things simple
    result[:properties].first
  end

  def product_list
    result = fetch_cached('products')
    result[:results]
  end

  def lookup_grid_supply_point(postcode = nil)
    if postcode.nil?
      raise 'No postcode and no account number given' if @account_number.nil?

      postcode = account_info[:postcode]
    end

    cache_key = 'grid-supply-point-' + postcode.gsub(/\s+/, '')
    result = fetch_cached('industry/grid-supply-points', cache_key, postcode: postcode)

    # I suspect that there can be more than one result but lets keep things simple
    if result[:count] == 0
      raise 'No Grid Supply Points Found'
    elsif result[:count] == 1
      result[:results].first[:group_id]
    else
      raise 'More than one Grid Supply Point found'
    end
  end

  def tariff_to_product(code)
    parts = code.split('-')
    parts.slice(2, parts.length - 3).join('-')
  end

  def tariff_code(type, product_code)
    type_code = type.to_s[0].upcase

    "#{type_code}-1R-#{product_code}-#{grid_supply_point}"
  end

  def tariff_path(type, product_code, rate_type = 'standard-unit-rates')
    tariff_type = case type
                  when /^g/i
                    'gas-tariffs'
                  when /^e/i
                    'electricity-tariffs'
                  else
                    raise "Unknown tariff type: #{type}"
                  end

    [
      'products',
      product_code,
      tariff_type,
      tariff_code(type, product_code),
      rate_type
    ].join('/')
  end

  def get_rates_for_day(type, product_code, date)
    rate_type = 'standard-unit-rates'
    cache_key = [rate_type, tariff_code(type, product_code), date]
    result = fetch_cached(
      tariff_path(type, product_code, rate_type),
      cache_key,
      {
        period_from: "#{date}T00:00:00",
        period_to: "#{date + 1}T00:00:00",
      }
    )

    hash = {}
    result[:results].sort_by { |row| row[:valid_from] }.each do |row|
      hash[row[:valid_from]] = row[:value_inc_vat]
    end
    return hash
  end

  def get_rates_for_today(type, product_code)
    get_rates_for_day(type, product_code, Date.today)
  end

  def get_rates_for_days(type, product_code, start_date, end_date)
    rates = {}
    (start_date...end_date).each do |date|
      rates.merge!(get_rates_for_day(type, product_code, date))
    end
    return rates
  end

  def get_rates_for_past_days(type, product_code, number_days)
    end_date = Date.today
    start_date = end_date - number_days
    get_rates_for_days(type, product_code, start_date, end_date)
  end

  def get_single_rate_for_day(type, product_code, date = Date.today)
    get_rates_for_day(type, product_code, date).values.first
  end

  def get_average_rate_for_day(type, product_code, date = Date.today)
    rates = get_rates_for_day(type, product_code, date)
    rates.values.sum / rates.length
  end

  def fetch(path, query = {})
    # The Octopus API requires a trailing slash
    path += '/' unless path[-1] == '/'

    uri = URI.parse(BASE_URL + path)
    uri.query = URI.encode_www_form(query)

    response = nil
    Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
      request = Net::HTTP::Get.new(uri)
      if @api_key
        request.basic_auth(@api_key, '')
      end

      response = http.request(request)
      if response.code != '200'
        raise "Octopus API request for #{uri} failed: #{response.message} #{response.body}"
      end
    end

    JSON.parse(response.body, symbolize_names: true)
  end

  def fetch_cached(path, cache_key = nil, query = {})
    cache_key = cache_key.join('-') if cache_key.is_a?(Enumerable)
    cache_key = path.gsub('/', '-') if cache_key.nil?
    filepath = File.join(@cache_dir, "#{cache_key}.json")

    if File.exist?(filepath)
      # We already have a cached copy
      json = File.read(filepath)
      data = JSON.parse(json, symbolize_names: true)
    else
      Dir.mkdir(@cache_dir) unless Dir.exist?(@cache_dir)

      # Fetch data and write it to local disk
      data = fetch(path, query)
      File.open(filepath, 'w') do |file|
        file.write JSON.pretty_generate(data)
      end
    end

    return data
  end
end
