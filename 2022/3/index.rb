# frozen_string_literal: true

public

def puzzle_one
  compartment_pairs.sum do |compartment_pair|
    priority_of(first_intersected_item_in(compartment_pair))
  end
end

def puzzle_two
  rucksack_trios.sum do |rucksack_trio|
    priority_of(first_intersected_item_in(rucksack_trio))
  end
end

PRIORITY = [*'a'..'z', *'A'..'Z'].zip(1..52).to_h.freeze

private

def compartment_pairs
  input.map { |rucksack| in_halves(rucksack) }
end

def rucksack_trios
  input.in_groups_of(3).map do |rucksack_trio|
    rucksack_trio.map(&:chars)
  end
end

def in_halves(string)
  halved = string.length / 2
  string.chars.each_slice(halved).to_a
end

def priority_of(item)
  PRIORITY[item]
end

def first_intersected_item_in(lists)
  lists.reduce(&:intersection).first
end

def input
  IO.readlines("#{__dir__}/input.txt", chomp: true)
end
