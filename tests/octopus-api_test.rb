$:.unshift(File.dirname(__FILE__))

require 'minitest/autorun'
require './octopus-api.rb'

class OctopusAPITest < Minitest::Test

  def test_tarrif_to_product
  	octopus = OctopusAPI.new
    product = octopus.tarrif_to_product('E-1R-SILVER-FLEX-22-11-25-B')
    assert_equal('SILVER-FLEX-22-11-25', product)
  end

end
