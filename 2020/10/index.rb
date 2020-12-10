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
  adapters
  .each_cons(2)
  .group_by { |x, y| y - x }
  .values
  .map(&:count)
  .reduce(:*)
end

def variant_two
  get_sum(0)
end

private

def adapters
  @adapters ||=
    IO
    .readlines("#{__dir__}/input.txt")
    .map(&:to_i)
    .sort
    .then { |a| [0, *a, a.last + 3] }
end

def get_sum(index, cache = {})
  adapter = adapters[index]
  cached_item = is_cached = cache[adapter]
  is_penultimate, penultimate_sum = adapter == adapters[-2], 1

  return cached_item || penultimate_sum if is_cached || is_penultimate

  index.next
  .upto(index + 3)
  .select { |option_index| if option = adapters[option_index] then (option - adapter).between?(1, 3) end }
  .each.sum { |option_index| get_sum(option_index, cache) }
  .tap { |sum| cache[adapter] = sum }
end

class PuzzleVariantError < StandardError; end
