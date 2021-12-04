# frozen_string_literal: true

public

def puzzle_one
  seat_ids.max
end

def puzzle_two
  seat_ids.sort.each_cons(2).find { |x,y| break x.next if y != x.next  }
end

private

def bisect(char1, char2)
  lambda do |range, char|
    half = range.size / 2
    case char
    when char1 then range.first(half)
    when char2 then range.last(half)
    end
  end
end

def seat_ids
  @seat_ids ||= input.map do |boarding_pass|
    row = boarding_pass[0..6].split('').reduce(1..128, &bisect('F','B')).first - 1
    column = boarding_pass[7..9].split('').reduce(1..8, &bisect('L', 'R')).first - 1
    row * 8 + column
  end
end

def input
  @input ||= IO.readlines("#{__dir__}/input.txt", chomp: true)
end
