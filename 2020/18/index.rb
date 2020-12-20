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
  require_relative './integer_monkey_patch_1.rb'
  lines.sum { |line| eval(line) }
end

def variant_two
  require_relative './integer_monkey_patch_2.rb'
  lines.sum { |line| eval(line) }
end

def lines
  @lines ||= file.split("\n")
end

class PuzzleVariantError < StandardError; end
