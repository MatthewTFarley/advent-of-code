# frozen_string_literal: true

public

def puzzle_one
  BasinFinder.new
    .low_points
    .map(&:num)
    .map(&:next)
    .sum
end

def puzzle_two
  BasinFinder.new
    .three_largest
    .map(&:count)
    .reduce(1, &:*)
end

private

class Point
  attr_reader :num, :x, :y

  def initialize (num, x, y)
    @num = num
    @x = x
    @y = y
  end


  def low_point?
    @low_point ||= adjacent.all? { |adj| adj.nil? || adj.num > num }
  end

  def higher_adjacent
    @higher_adjacent ||= adjacent.select { |adj| adj.num > num }
  end

  def adjacent
    @adjacent ||= [top, bottom, left, right].compact
  end

  def top
    @top ||= begin
      top_y = y - 1
      top_y >= 0 ? Input.grid[top_y][x] : nil
    end
  end

  def bottom
    @bottom ||= begin
      bottom_y = y + 1
      bottom_y < Input.grid.length ? Input.grid[bottom_y][x] : nil
    end
  end

  def left
    @left ||= begin
      left_x = x - 1
      left_x >= 0 ? Input.grid[y][left_x] : nil
    end
  end

  def right
    @right ||= begin
      right_x = x + 1
      right_x < Input.grid[y].length ? Input.grid[y][right_x] : nil
    end
  end
end

class BasinFinder
  attr_reader :basins

  def initialize
    @basins = low_points.map { |point, basin| Basin.new(point) }
  end

  def low_points
    @low_points ||=
      Input.grid.each.with_index.each_with_object([]) do |(row, y), lows|
        row.each_with_index do |point, x|
          lows << point if point.low_point?
        end
      end
  end

  def three_largest
    basins.map(&:members).sort_by(&:count).reverse.take(3)
  end
end

class Basin
  attr_reader :low_point

  def initialize(low_point)
    @low_point = low_point
  end

  def members
    @members ||= [low_point].tap do |points|
      points.each do |point|
        points.concat(point.higher_adjacent.reject { |adj| adj.num == 9 })
      end
    end.uniq
  end
end

class Input
  class << self
    def grid
      @@grid ||=
        IO.readlines("#{__dir__}/input.txt", chomp: true)
        .map.with_index do |row, y|
          row.split('').map.with_index do |num, x|
            Point.new(num.to_i, x, y)
          end
        end
    end
  end
end
