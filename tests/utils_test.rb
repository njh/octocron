$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minitest/autorun'

require 'utils'

class UtilsTest < Minitest::Test
  def test_half_hour_period_low
    time = Time.utc(2024, 7, 19, 14, 5, 20)
    period = half_hour_period(time)
    assert_equal('2024-07-19T14:00:00Z', period.iso8601)
  end

  def test_half_hour_period_high
    time = Time.utc(2024, 7, 19, 7, 57, 50)
    period = half_hour_period(time)
    assert_equal('2024-07-19T07:30:00Z', period.iso8601)
  end

  def test_half_hour_period_low_local
    time = Time.new(2024, 7, 19, 14, 5, 20, '+01:00')
    period = half_hour_period(time)
    assert_equal('2024-07-19T14:00:00+01:00', period.iso8601)
  end

  def test_half_hour_period_high_local
    time = Time.new(2024, 7, 19, 7, 57, 50, '+01:00')
    period = half_hour_period(time)
    assert_equal('2024-07-19T07:30:00+01:00', period.iso8601)
  end

  def test_calculate_quantile_median_odd
    dataset = [1, 3, 3, 6, 7, 8, 9]
    points = calculate_quantile_points(dataset, 1)
    assert_equal([6], points)
  end

  def test_calculate_quantile_median_even
    dataset = [1, 2, 3, 4, 5, 6, 8, 9]
    points = calculate_quantile_points(dataset, 1)
    assert_equal([4.5], points)
  end

  def test_calculate_quartile_points
    dataset = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    points = calculate_quartile_points(dataset)
    assert_equal([3.25, 5.5, 7.75], points)
  end

  def test_calculate_quartile_points_wikipeda_example1
    dataset = [6, 7, 15, 36, 39, 40, 41, 42, 43, 47, 49]
    points = calculate_quartile_points(dataset)
    assert_equal([25.5, 40.0, 42.5], points)
  end

  def test_calculate_quartile_points_random_20
    dataset = [85, 2, 95, 14, 45, 57, 65, 72, 8, 34, 28, 51, 89, 60, 77, 18, 10, 32, 21, 99]
    points = calculate_quartile_points(dataset)
    assert_equal([20.25, 48.0, 73.25], points)
  end

  def test_format_as_columns_2items_1col
    items = ['one', 'two']
    result = format_as_columns(items, 1, 8)
    assert_equal(
      ["one     ",
       "two     "],
      result
    )
  end

  def test_format_as_columns_2items_2cols
    items = ['one', 'two']
    result = format_as_columns(items, 2, 8)
    assert_equal(
      ["one     two     "],
      result
    )
  end

  def test_format_as_columns_4items_2cols
    items = ['one', 'two', 'three', 'four']
    result = format_as_columns(items, 2, 8)
    assert_equal(
      ["one     three   ",
       "two     four    "],
      result
    )
  end

  def test_format_as_columns_7items_3cols
    items = ['one', 'two', 'three', 'four', 'five', 'six', 'seven']
    result = format_as_columns(items, 3, 8)
    assert_equal(
      ["one     four    seven   ",
       "two     five            ",
       "three   six             "],
      result
    )
  end
end
