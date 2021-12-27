# frozen_string_literal: true
require 'ostruct'

public

def puzzle_one
  moves = 0
  last_moves = nil
  grid = Input.grid
  OpenStruct.new(count: 0).tap do |step|
    until moves == last_moves
      step[:count] += 1
      last_moves = moves
      grid.map(&:dup).tap do |previous_grid|
        previous_grid.each_with_index do |row, y|
          row.each_with_index do |cell, x|
            x1 = (x + 1 == row.length)  ? 0 : x + 1
            y1 = (y + 1 == grid.length) ? 0 : y + 1

            if cell == '>' && previous_grid[y][x1] == '.'
              grid[y][x] = '.' if grid[y][x] == previous_grid[y][x]
              grid[y][x1] = '>'
              moves += 1
            end

            if cell == 'v' &&
                (
                  (previous_grid[y1][x] == '.' && previous_grid[y1][x - 1] != '>') ||
                  (previous_grid[y1][x] == '>' && previous_grid[y1][x1] == '.')
                )
              grid[y][x] = '.' if grid[y][x] == previous_grid[y][x]
              grid[y1][x] = 'v'
              moves += 1
            end
          end
        end
      end
    end
  end.count
end

def puzzle_two
  puts 'There is no puzzle two for this day'
end

def pretty(grid)
  grid.map(&:join)
end

private

module Input
  class << self
    def grid
      @@grid ||= IO.readlines("#{__dir__}/input.txt", chomp: true).map do |row|
        row.split('')
      end
    end
  end
end
