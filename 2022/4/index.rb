# frozen_string_literal: true

public

def puzzle_one
  range_pairs.count do |(range1, range2)|
    range1.cover?(range2) || range2.cover?(range1)
  end
end

def puzzle_two
  range_pairs.count do |(range1, range2)|
    range1.overlaps?(range2)
  end
end

private

def range_pairs
  input.map do |range_pairs|
    range_pairs.split(',').map do |range_string|
      Range.new(*range_string.split('-').map(&:to_i))
    end
  end
end

def input
  IO.readlines("#{__dir__}/input.txt", chomp: true)
end
