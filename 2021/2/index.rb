# frozen_string_literal: true

public

def main(puzzle_variant = '1')
  case puzzle_variant
  when '1' then variant_one
  when '2' then variant_two
  else raise PuzzleVariantError.new 'Invalid puzzle variant provided. Valid values are "1", and "2"'
  end

rescue PuzzleVariantError => error
  error
end

def variant_one
  commands.each_with_object({ distance: 0, depth: 0 }) do |(direction, magnitude), coordinates|
    case direction
    when 'up' then coordinates[:depth] -= magnitude
    when 'down' then coordinates[:depth] += magnitude
    when 'forward' then coordinates[:distance] += magnitude
    end
  end.then(&:values).reduce(1, &:*)
end

def variant_two
  commands.each_with_object({ distance: 0, depth: 0, aim: 0 }) do |(direction, magnitude), coordinates|
    case direction
    when 'up' then coordinates[:aim] -= magnitude
    when 'down' then coordinates[:aim] += magnitude
    when 'forward'
      coordinates[:distance] += magnitude
      coordinates[:depth] += coordinates[:aim] * magnitude
    end
  end.then(&:values).take(2).reduce(1, &:*)
end

private

def commands
  input.map do |command|
    direction, magnitude = command.split(' ')
    [direction, magnitude.to_i]
  end
end

def input
  @input ||= IO.readlines("#{__dir__}/input.txt")
end

class PuzzleVariantError < StandardError; end
