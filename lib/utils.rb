require 'io/console'
require 'time'

# Function to display an array of strings
# as columns on a text terminal.
def format_as_columns(strings, column_count, column_width = nil)
  per_column = (strings.count.to_f / column_count).ceil

  if column_width.nil?
    height, width = IO.console.winsize
    column_width = (width.to_f / column_count).floor
  end

  result = []
  (0...per_column).each do |r|
    row = ''
    (0...column_count).each do |c|
      index = (c * per_column) + r
      if strings[index].nil?
        item = ''
      else
        item = strings[index]
      end
      row += item.ljust(column_width)
    end
    result << row
  end

  return result
end

# Calculate which half-hour period a point in time belongs in
# If no time is given, the current half-hour period is returned
def half_hour_period(time = Time.now)
  min = (time.min < 30) ? 0 : 30
  args = [time.year, time.month, time.day, time.hour, min, 0]
  if time.utc_offset == 0
    Time.utc(*args)
  else
    Time.new(*args, time.utc_offset)
  end
end

# Calculate the quantile cut points for a dataset
# Interpolates between the two nearest ranks using a weighted average
def calculate_quantile_points(values, points)
  sorted = values.sort
  n = sorted.size

  (1..points).map do |i|
    rank = (i.to_f * (n - 1)) / (points + 1)
    lower_index = rank.floor
    upper_index = rank.ceil
    weight = rank - lower_index

    sorted[lower_index] * (1 - weight) + sorted[upper_index] * weight
  end
end

# Calculate the quartile cut points for a dataset
# Returns 3 numbers (Q1, Q2, Q3)
def calculate_quartile_points(values)
  calculate_quantile_points(values, 3)
end
