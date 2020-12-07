# frozen_string_literal: true

public

def main(puzzle_variant = '1')
  case puzzle_variant
  when '1' then variant_one
  when '2' then variant_two
  else raise PuzzleVariantError.new 'Invalid puzzle variant provided. Valid values are "1", and "2"'
  end

rescue StandardError => error
  error
end

def variant_one
  groups.map(&count_any_unique_yes).sum
end

def variant_two
  groups.map(&count_all_yes).sum
end

private

def groups
  @groups ||= File.open("#{__dir__}/input.txt", &:read).split("\n\n")
end

def count_any_unique_yes
  ->(group) { group.tr("\n", '').split('').uniq.count }
end

def count_all_yes
  ->(group) { group.split("\n").map(&split_chars).reduce(&:&).count }
end

def split_chars
  ->(str) { str.split('') }
end

class PuzzleVariantError < StandardError; end
