#!/usr/bin/env ruby
#
# Display information about half-hour pricing for
# the Octopus Agile tariff for today.
#
# Colouring is based on the past 30 days of pricing:
#   Blue (negative rate)
#   Green (lowest quartile)
#   Yellow (lower-middle quartile)
#   Orange (upper-middle quartile)
#   Red (highest quartile)
#

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'time'
require 'yaml'
require 'rainbow'

require 'octopus-api'
require 'utils'

config = YAML.load_file('config.yml')
product_code = config['electricity_agile_tariff']

octopus = OctopusAPI.new(config)

days = 30
rates = octopus.get_rates_for_past_days(:electricity, product_code, days)
puts "Summary for past #{days} days"
puts "  Min: #{rates.values.min}"
puts "  Max: #{rates.values.max}"

points = calculate_quartile_points(rates.values)
colours = ['#68FC22', '#FAEB34', '#FD9925', '#FC2020']
puts '  Quartile Points: ' + points.map { |t| t.round(2) }.join(', ')

puts
puts 'Today:'
date = Date.today
now = half_hour_period
today = octopus.get_rates_for_day(:electricity, product_code, date)

rows = []
today.each_pair do |period, rate|
  time = Time.parse(period).localtime
  row = " #{time.strftime('%H:%M')} "

  strrate = format('%2.2fp', rate).rjust(5)
  if rate.negative?
    # Negative: blue
    row += Rainbow(strrate).white.bg('#225FFC')
  else
    q = points.find_index { |p| rate < p }
    q = points.length if q.nil?
    row += Rainbow(strrate).black.bg(colours[q])
  end

  if time == now
    row += Rainbow(' ←   ').bold
  else
    row += '     '
  end

  rows << row
end

puts format_as_columns(rows, 4).join("\n")
puts
