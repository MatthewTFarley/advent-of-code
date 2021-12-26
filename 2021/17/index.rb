# frozen_string_literal: true
require 'ostruct'

public

def puzzle_one
  valid_xs
    .flat_map { |x| (0..100).map { |y| positions_for(x, y) } }
    .reduce(0) do |overall_max_y, run|
      run.hit_target? ? [overall_max_y, run.max_y].max : overall_max_y
    end
end

def puzzle_two
  (0..Input.x2).flat_map do |x|
    (Input.y1..100).map { |y| positions_for(x, y) }
  end.count(&:hit_target?)
end

private

def positions_for(x, y)
  y_min = [Input.y1, Input.y2].min
  next_x_inc, next_y_inc = x, y
  current_x, current_y = 0, 0
  max_y = current_y
  hit_target = false
  until next_x_inc.zero? && current_y < y_min
    max_y = [max_y, current_y].max
    if xs.include?(current_x) && ys.include?(current_y)
      hit_target = true
    end
    current_x += next_x_inc
    current_y += next_y_inc
    next_x_inc -= 1 if next_x_inc.positive?
    next_y_inc -= 1
  end
  OpenStruct.new(hit_target?: hit_target, max_y: max_y)
end

def valid_xs
  [].tap do |valid_xs|
    x1, x2 = Input.numbers
    next_x = x1
    while x1 < (last_res = furthest_distance(next_x))
      valid_xs << next_x if (x1..x2).include?(last_res)
      next_x -= 1
    end
  end.sort
end

def furthest_distance(n)
  1.upto(n).reduce(0, &:+)
end

def xs
  to_a(*Input.numbers.take(2))
end

def ys
  to_a(*Input.numbers.drop(2))
end

def to_a(n1, n2)
  (n1 < n2 ? n1.upto(n2) : n1.downto(n2)).to_a
end

module Input
  class << self
    def line
      @@line ||= IO.readlines("#{__dir__}/input.txt", chomp: true).first
    end

    def x1; numbers[0]; end
    def x2; numbers[1]; end
    def y1; numbers[2]; end
    def y2; numbers[3]; end

    def numbers
      @numbers ||= line.scan(/x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)/).first.map(&:to_i)
    end
  end
end
