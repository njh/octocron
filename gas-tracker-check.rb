#!/usr/bin/env ruby

require 'yaml'
require 'date'

require './octopus-api'

config = YAML.load_file('config.yml')

octopus = OctopusAPI.new(config)

tracker_rate = octopus.get_single_rate_for_day(:gas, config['gas_tracker_tariff'])
puts "Tracker (#{config['gas_tracker_tariff']}): #{tracker_rate}"

variable_rate = octopus.get_single_rate_for_day(:gas, config['gas_variable_tariff'])
puts "Variable (#{config['gas_variable_tariff']}): #{variable_rate}"

fixed_rate = octopus.get_single_rate_for_day(:gas, config['gas_fixed_tariff'])
puts "Fixed (#{config['gas_fixed_tariff']}): #{fixed_rate}"
