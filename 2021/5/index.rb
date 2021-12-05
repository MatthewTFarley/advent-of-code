# frozen_string_literal: true

public

def puzzle_one
  locate_danger_areas do |x1, x2, y1, y2|
    x1 != x2 && y1 != y2
  end
end

def puzzle_two
  locate_danger_areas
end

private

def locate_danger_areas
  start_end.each do |(x1, y1), (x2, y2)|
    next if block_given? && yield(x1, x2, y1, y2)
    x_range = get_range(x1, x2, y1, y2)
    y_range = get_range(y1, y2, x1, x2)
    x_range.zip(y_range).each { |x, y| grid[y][x] += 1 }
  end
  grid.flatten.count { |num| num > 1 }
end

def get_range(a1, a2, b1, b2)
  if a2 > a1
    (a1..a2).to_a.reverse
  elsif a1 > a2
    a2..a1
  else
    (b1 - b2).abs.next.times.map { a1 }
  end
end

def grid
  @grid ||= begin
    raw_input
    .scan(/\d+/)
    .max { |str1, str2| str1.to_i <=> str2.to_i }
    .to_i
    .next
    .then { |max| max.times.map { max.times.map { 0 } } }
  end
end

def start_end
  @start_end ||= input.map do |str|
    str.split(' -> ').map { |sub| sub.split(',').map(&:to_i) }
  end
end

def raw_input
  IO.read("#{__dir__}/input.txt")
end

def input
  IO.readlines("#{__dir__}/input.txt", chomp: true)
end
