#!/usr/bin/env ruby

require 'time'
require 'yaml'
require 'erb'

require './lib/octopus-api'

config = YAML.load_file('config.yml')

octopus = OctopusAPI.new(config)
account = octopus.account_info

def format_kwh(number)
  number.to_s.gsub(/\B(?=(...)*\b)/, ',') + ' kWh'
end

def find_active_product(meter_point)
  now = Time.now
  agreement = meter_point[:agreements].find { |ag|
    Time.parse(ag[:valid_from]) < now and (ag[:valid_to].nil? or now < Time.parse(ag[:valid_to]))
  }
  unless agreement.nil?
    agreement[:tariff_code]
  end
end

renderer = ERB.new(DATA.read, trim_mode: '-')
puts renderer.result


__END__
Account Number: <%= octopus.account_number %>
Grid Supply Point: <%= octopus.lookup_grid_supply_point %>

Electricity
-----------
<% account[:electricity_meter_points].each do |meter_point| -%>
MPAN: <%= meter_point[:mpan] %>
Meter SNs: <%= meter_point[:meters].map { |meter| meter[:serial_number] }.join(', ') %>
Active Tariff: <%= find_active_product(meter_point) %>
Estimated Annual Usage: <%= format_kwh(meter_point[:consumption_standard]) %>
<% end -%>

Gas
---
<% account[:gas_meter_points].each do |meter_point| -%>
MPRN: <%= meter_point[:mprn] %>
Meter SNs: <%= meter_point[:meters].map { |meter| meter[:serial_number] }.join(', ') %>
Active Tariff: <%= find_active_product(meter_point) %>
Estimated Annual Usage: <%= format_kwh(meter_point[:consumption_standard]) %>
<% end %>
