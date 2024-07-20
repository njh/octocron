$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'minitest/autorun'

require './octopus-api'

class OctopusAPITest < Minitest::Test
  def test_initialize
    octopus = OctopusAPI.new
    assert_nil(octopus.api_key)
    assert_nil(octopus.account_number)
  end

  def test_initialize_with_hash
    params = { api_key: 'foobar', 'account_number' => 'sk_xxyyzz', :grid_supply_point => :b }
    octopus = OctopusAPI.new(params)
    assert_equal('foobar', octopus.api_key)
    assert_equal('sk_xxyyzz', octopus.account_number)
    assert_equal('B', octopus.grid_supply_point)
  end

  def test_tariff_to_product
    octopus = OctopusAPI.new
    product = octopus.tariff_to_product('E-1R-SILVER-FLEX-22-11-25-B')
    assert_equal('SILVER-FLEX-22-11-25', product)
  end

  def test_tariff_code_gas
    octopus = OctopusAPI.new(grid_supply_point: 'a')
    code = octopus.tariff_code(:gas, 'SILVER-23-12-06')
    assert_equal('G-1R-SILVER-23-12-06-A', code)
  end

  def test_tariff_code_elec
    octopus = OctopusAPI.new(grid_supply_point: '_B')
    code = octopus.tariff_code(:electricity, 'LOYAL-FIX-12M-24-03-22')
    assert_equal('E-1R-LOYAL-FIX-12M-24-03-22-B', code)
  end

  def test_tariff_path_gas
    octopus = OctopusAPI.new(grid_supply_point: 'a')
    path = octopus.tariff_path(:gas, 'SILVER-23-12-06', 'standard-unit-rates')
    assert_equal('products/SILVER-23-12-06/gas-tariffs/G-1R-SILVER-23-12-06-A/standard-unit-rates', path)
  end

  def test_tariff_path_elec
    octopus = OctopusAPI.new(grid_supply_point: '_B')
    path = octopus.tariff_path(:electricity, 'LOYAL-FIX-12M-24-03-22', 'standing-charges')
    assert_equal('products/LOYAL-FIX-12M-24-03-22/electricity-tariffs/E-1R-LOYAL-FIX-12M-24-03-22-B/standing-charges',
                 path)
  end

  def test_half_hour_period_low
    octopus = OctopusAPI.new
    time = Time.utc(2024, 7, 19, 14, 5, 20)
    period = octopus.half_hour_period(time)
    assert_equal('2024-07-19T14:00:00Z', period.iso8601)
  end

  def test_half_hour_period_high
    octopus = OctopusAPI.new
    time = Time.utc(2024, 7, 19, 7, 57, 50)
    period = octopus.half_hour_period(time)
    assert_equal('2024-07-19T07:30:00Z', period.iso8601)
  end

  def test_half_hour_period_low_local
    octopus = OctopusAPI.new
    time = Time.new(2024, 7, 19, 14, 5, 20, '+01:00')
    period = octopus.half_hour_period(time)
    assert_equal('2024-07-19T14:00:00+01:00', period.iso8601)
  end

  def test_half_hour_period_high_local
    octopus = OctopusAPI.new
    time = Time.new(2024, 7, 19, 7, 57, 50, '+01:00')
    period = octopus.half_hour_period(time)
    assert_equal('2024-07-19T07:30:00+01:00', period.iso8601)
  end
end
