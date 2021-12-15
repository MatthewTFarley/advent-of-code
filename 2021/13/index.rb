# frozen_string_literal: true

public

def puzzle_one
  p = Paper.new
  pp p.grid.length
  pp p.grid.first.length
  p.fold!
  p.dots
  puts "\n"
  # puts p.pretty
end

def puzzle_two
  p = Paper.new
  p.fold!
  puts p.pretty
end

private

class Paper
  attr_reader :coords, :instructions
  attr_accessor :grid
  alias_method :c, :coords
  alias_method :i, :instructions

  def initialize
    @coords = Input.coords
    @instructions = Input.instructions
    @grid = build_grid!
  end

  def dots
    grid.flatten.count { |cell| cell == '#' }
  end

  def fold!(times = i.count)
    i.take(times).each do |axis, num|
      send(:"fold_#{axis}!", num)
    end
    self
  end

  def pretty
    grid.map { |row| row.join.reverse }
  end

  private

  def fold_x!(num)
    trans = grid.transpose
    left, right = [trans.slice(0...num), trans.slice(num.next..)]
    self.grid = left.reverse.zip(right).map.with_index do |(l_row, r_row), i|
      l_row.zip(r_row).map do |l, r|
        [l,r].include?('#') ? "#" : '.'
      end
    end.transpose
    self
  end

  def fold_y!(num)
    top, bottom = [grid.slice(0...num), grid.slice(num.next..)]
    self.grid = bottom.reverse.zip(top).map.with_index do |(b_row, t_row), i|
      b_row.zip(t_row).map do |b, t|
        [b,t].include?('#') ? "#" : '.'
      end
    end
    self
  end

  def coords_index
    @coords_index ||= coords.each_with_object({}) do |coord, hash|
      hash[coord] = coord
    end
  end

  def xs
    @xs ||= c.map(&:first)
  end

  def ys
    @ys ||= c.map(&:last)
  end

  def max_x
    @max_x ||= xs.max + 1
  end

  def max_y
    @max_y ||= ys.max + 1
  end

  def build_grid!
    max_y.times.map.with_index do |row, y|
      max_x.times.map.with_index do |cell, x|
        coords_index[[x,y]] ? '#' : '.'
      end
    end
  end
end

module Input
  class << self
    def coords
        IO.read("#{__dir__}/input.txt")
        .split("\n\n")
        .first.split("\n")
        .map { |c| c.split(',').map(&:to_i) }
    end

    def instructions
        IO.read("#{__dir__}/input.txt")
        .split("\n\n")[1]
        .split("\n")
        .flat_map do |c|
          c.scan(/(\w)=(\d+)/)
          .map { |a, b| [a, b.to_i] }
        end
    end
  end
end
