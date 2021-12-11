# frozen_string_literal: true

public

def puzzle_one
  Grid.new.run(100).flash_count
end

def puzzle_two
  Grid.new.run_until_synchronized
end

private

class Grid
  attr_reader :grid, :flash_count

  def initialize
    @grid = Input.grid
    @flash_count = 0
  end

  def run(n)
    self.tap { n.times { step! } }
  end

  def run_until_synchronized
    count = 0
    until values.all?(&:zero?)
      step!
      count += 1
    end
    count
  end

  def flashes
    @flashes ||= []
  end

  private

  attr_writer :flash_count

  def values
    octos.map(&:value)
  end

  def octos
    grid.flatten
  end

  def flashed
    octos.select(&:flashed?)
  end

  def step!
    increment!
    flash!
    reset_flashed!
  end

  def increment!
    octos.each(&:increment!)
  end

  def flash!
    loop do
      flashers = octos_to_flash
      break if flashers.count.zero?

      flashers.each(&:flash!)
      self.flash_count += flashers.count
      flashers.flat_map(&:adjacent).each(&:increment!)
    end
  end

  def reset_flashed!
    flashed.each(&:reset!)
  end

  def octos_to_flash
    octos.reject(&:flashed?).select { |octo| octo.value == 10 }
  end
end

class Octopus
  attr_reader :value, :y, :x

  def initialize(value, y, x)
    @value = value
    @y = y
    @x = x
    @flashed = false
  end

  def increment!
    self.value += 1 if value != 10
  end

  def reset!
    if value == 10
      self.value = 0
      self.flashed = false
    end
  end

  def flash!
    self.flashed = true
  end

  def flashed?
    flashed
  end

  def adjacent
    @adjacent ||= [
      top_left,    top,       top_right,
      left,                       right,
      bottom_left, bottom, bottom_right
    ].compact.sort_by { |octo| [octo.x, octo.y] }
  end

  def to_s
    "Octopus([#{x},#{y}] = #{value})"
  end

  private

  attr_accessor :flashed
  attr_writer :value

  def top_left
    @top_left ||= begin
      top_y = y - 1
      top_x = x - 1
      [top_y, top_x].all? { |coord| coord >= 0 } ? Input.grid[top_y][top_x] : nil
    end
  end

  def top
    @top ||= begin
      top_y = y - 1
      top_y >= 0 ? Input.grid[top_y][x] : nil
    end
  end

  def top_right
    @top_right ||= begin
      top_y = y - 1
      top_x = x + 1
      top_y >= 0 && top_x < Input.grid.length ? Input.grid[top_y][top_x] : nil
    end
  end

  def bottom_left
    @bottom_left ||= begin
      bottom_y = y + 1
      bottom_x = x - 1
      bottom_y < Input.grid.length && bottom_x >= 0 ? Input.grid[bottom_y][bottom_x] : nil
    end
  end

  def bottom
    @bottom ||= begin
      bottom_y = y + 1
      bottom_y < Input.grid.length ? Input.grid[bottom_y][x] : nil
    end
  end

  def bottom_right
    @bottom_right ||= begin
      bottom_y = y + 1
      bottom_x = x + 1
      [bottom_y, bottom_x].all? { |coord| coord < Input.grid.length } ? Input.grid[bottom_y][bottom_x] : nil
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
      right_x < Input.grid.length ? Input.grid[y][right_x] : nil
    end
  end
end

class Input
  class << self
    def grid
      @@grid ||=
        IO.readlines("#{__dir__}/input.txt", chomp: true)
        .map.with_index do |row, y|
          row.split('').map.with_index do |octo, x|
            Octopus.new(octo.to_i, y, x)
          end
        end
    end
  end
end
