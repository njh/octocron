#!/usr/bin/env ruby

require 'yaml'
require 'date'

require './lib/octopus-api'

config = YAML.load_file('config.yml')
octopus = OctopusAPI.new(config)

date = Date.today
puts "Checking Electricity rates for #{date} in region #{octopus.grid_supply_point}:"
puts

agile_rate = octopus.get_average_rate_for_day(:electricity, config['electricity_agile_tariff'], date)
puts "Agile (#{config['electricity_agile_tariff']}): #{agile_rate.round(1)} p/kWh average"

variable_rate = octopus.get_single_rate_for_day(:electricity, config['electricity_variable_tariff'], date)
puts "Variable (#{config['electricity_variable_tariff']}): #{variable_rate.round(1)} p/kWh"

fixed_rate = octopus.get_single_rate_for_day(:electricity, config['electricity_fixed_tariff'], date)
puts "Fixed (#{config['electricity_fixed_tariff']}): #{fixed_rate.round(1)} p/kWh"

puts

if agile_rate > variable_rate
  $stderr.puts "Warning: Variable rate for Electricity is cheaper than Agile"
  exit(1)
elsif agile_rate > fixed_rate
  $stderr.puts "Warning: Fixed rate for Electricity is cheaper than Agile"
  exit(1)
else
  puts "Agile is the cheapest option."
  exit(0)
end
