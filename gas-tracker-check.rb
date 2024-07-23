#!/usr/bin/env ruby

require 'yaml'
require 'date'

require './lib/octopus-api'

config = YAML.load_file('config.yml')
octopus = OctopusAPI.new(config)

date = Date.today
puts "Checking Gas rates for #{date} in region #{octopus.grid_supply_point}:"
puts

tracker_rate = octopus.get_single_rate_for_day(:gas, config['gas_tracker_tariff'], date)
puts "Tracker (#{config['gas_tracker_tariff']}): #{tracker_rate.round(1)} p/kWh"

variable_rate = octopus.get_single_rate_for_day(:gas, config['gas_variable_tariff'], date)
puts "Variable (#{config['gas_variable_tariff']}): #{variable_rate.round(1)} p/kWh"

fixed_rate = octopus.get_single_rate_for_day(:gas, config['gas_fixed_tariff'], date)
puts "Fixed (#{config['gas_fixed_tariff']}): #{fixed_rate.round(1)} p/kWh"

puts

if tracker_rate > variable_rate
  $stderr.puts 'Warning: Variable rate for Gas is cheaper than Tracker'
  exit(1)
elsif tracker_rate > fixed_rate
  $stderr.puts 'Warning: Fixed rate for Gas is cheaper than Tracker'
  exit(1)
else
  puts 'Tracker is the cheapest option.'
  exit(0)
end
