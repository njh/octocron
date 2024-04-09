$:.unshift(File.dirname(__FILE__))

require 'minitest/autorun'
require './octopus-api.rb'

class OctopusAPITest < Minitest::Test
  def test_initialize
  	octopus = OctopusAPI.new
    assert_nil(octopus.api_key)
    assert_nil(octopus.account_number)
  end

  def test_initialize_with_hash
    params = {api_key: 'foobar', 'account_number' => 'sk_xxyyzz', :grid_supply_point => :b}
  	octopus = OctopusAPI.new(params)
    assert_equal('foobar', octopus.api_key)
    assert_equal('sk_xxyyzz', octopus.account_number)
    assert_equal('B', octopus.grid_supply_point)
  end

  def test_tarrif_to_product
  	octopus = OctopusAPI.new
    product = octopus.tarrif_to_product('E-1R-SILVER-FLEX-22-11-25-B')
    assert_equal('SILVER-FLEX-22-11-25', product)
  end

end
