# frozen_string_literal: true

public

def puzzle_one
  get_nth_number(2020)
end

def puzzle_two
  get_nth_number(30000000)
end

private

def get_nth_number(n)
  cache = {}
  numbers.each.with_index(1) { |num, index| cache[num] ||= []; cache[num] << index }
  numbers.length.next.upto(n).each do |index|
    last_num = numbers.last
    occurrences = cache[last_num]
    next_num = occurrences.length == 1 ? 0 : occurrences.reduce(:-)
    cache[next_num] ||= []
    cache[next_num].unshift(index)
    cache[next_num].pop if cache[next_num].length > 2
    numbers << next_num
  end
  numbers.last
end

def numbers
  @numbers ||= IO.readlines("#{__dir__}/input.txt", chomp: true).first.split(',').map(&:to_i)
end
