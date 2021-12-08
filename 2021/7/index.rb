# frozen_string_literal: true

public

def puzzle_one
  least_fuel_cost do |fuel_cost_tracker, starting, ending|
    travel_distance = distance(starting, ending)
    fuel_cost = travel_distance * frequency[starting]
    fuel_cost_tracker[ending] += fuel_cost
  end
end

def puzzle_two
  least_fuel_cost do |fuel_cost_tracker, starting, ending|
    travel_distance = distance(starting, ending)
    travel_distance.times.with_index(1) do |fuel_cost|
      fuel_cost_tracker[ending] += fuel_cost * frequency[starting]
    end
  end
end

private

def least_fuel_cost
  minmax.each_with_object(Hash.new(0)) do |ending, fuel_cost_tracker|
    unique_starting_positions.each do |starting|
      yield fuel_cost_tracker, starting, ending
    end
  end.values.sort.first
end

def distance(x, y)
  (x - y).abs
end

def minmax
  @minmax ||= Range.new(*input.minmax)
end

def frequency
  @frequency ||= input.tally
end

def unique_starting_positions
  @unique_starting_positions ||= input.uniq
end

def input
  IO
  .readlines("#{__dir__}/input.txt", chomp: true)
  .first
  .split(',')
  .map(&:to_i)
end

# guesses
# 466558
