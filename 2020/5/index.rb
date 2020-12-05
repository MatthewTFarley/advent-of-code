# frozen_string_literal: true

public

def main(puzzle_variant = '1')
  seat_ids =
    IO
    .readlines("#{__dir__}/input.txt", chomp: true)
    .map do |boarding_pass|
      row = boarding_pass[0..6].split('').reduce(1..128, &bisect('F','B')).first - 1
      column = boarding_pass[7..9].split('').reduce(1..8, &bisect('L', 'R')).first - 1
      row * 8 + column
    end

    case puzzle_variant
    when '1' then seat_ids.max
    when '2' then seat_ids.sort.each_cons(2).find { |x,y| break x.next if y != x.next  }
    else raise PuzzleVariantError.new 'Invalid puzzle variant provided. Valid values are "1", and "2"'
    end

rescue StandardError => error
  error
end

def bisect(char1, char2)
  lambda do |range, char|
    half = range.size / 2
    case char
    when char1 then range.first(half)
    when char2 then range.last(half)
    else raise CharsetError.new "Could not bisect with char #{char} and charset: {#{char1}, #{char2}}"
    end
  end
end

class PuzzleVariantError < StandardError; end
class CharsetError < StandardError; end
