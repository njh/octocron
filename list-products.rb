#!/usr/bin/env ruby

require './lib/octopus-api'

octopus = OctopusAPI.new
products = octopus.product_list

def display_products(products, direction)
  puts direction
  puts '-' * direction.length
  products.each do |product|
    next if product[:direction].upcase != direction.upcase

    puts "#{product[:code]}: #{product[:full_name]}"
  end
  puts
end

display_products(products, 'Import')
display_products(products, 'Export')
