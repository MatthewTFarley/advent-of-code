# frozen_string_literal: true

public

def puzzle_one
  groups.max
end

def puzzle_two
  groups.sort.reverse.take(3).sum
end

private

def groups
  index = 0
  input.each_with_object([]) do |item, list|
    if item.empty?
      index += 1
    else
      list[index] ||= 0
      list[index] += item.to_i
    end
  end
end

def input
  @input ||= IO.read("#{__dir__}/input.txt").split("\n")
end
