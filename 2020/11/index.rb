# frozen_string_literal: true

public

def main(puzzle_variant = '1')
  case puzzle_variant
  when '1' then variant_one
  when '2' then variant_two
  else raise PuzzleVariantError.new 'Invalid puzzle variant provided. Valid values are "1", and "2"'
  end

rescue PuzzleVariantError, Grid::InvalidStateError => error
  error
end

def variant_one
  get_final_occupied_seat_count_for(Grid.new(lines))
end

def variant_two
  get_final_occupied_seat_count_for(Grid.new(lines, 4, Float::INFINITY))
end

private

def get_final_occupied_seat_count_for(grid)
  next_grid = grid.next
  grid, next_grid = next_grid, next_grid.next until grid == next_grid
  grid.occupied_seat_count
end

def lines
  @lines ||= IO.readlines("#{__dir__}/input.txt", chomp: true)
end

class Grid
  SPACE_STATES = {
    floor: '.',
    vacant: 'L',
    occupied: '#'
  }.freeze

  DIRECTIONS = [
    [-1, -1], [-1, +0], [-1, +1],
    [+0, -1],           [+0, +1],
    [+1, -1], [+1, +0], [+1, +1],
  ].map(&:freeze).freeze

  attr_reader :lines, :occupied_seat_limit, :occupied_seat_distance

  def initialize(lines, occupied_seat_limit = 3, occupied_seat_distance = 1)
    @lines = lines
    @occupied_seat_limit = occupied_seat_limit
    @occupied_seat_distance = occupied_seat_distance
  end

  def rows
    @rows ||=
      lines.map.with_index do |line, x|
        line.split('').map.with_index do |value, y|
          Space.new(x, y, value, self)
        end
      end
  end

  def next
    next_lines = rows.map do |row|
      row.map do |space|
        space.dup.tap(&:sit_or_vacate!)
      end
    end.map { |row| row.map(&:to_s).join('') }

    Grid.new(next_lines, occupied_seat_limit, occupied_seat_distance)
  end

  def ==(other_grid)
    !(self != other_grid)
  end

  def !=(other_grid)
    spaces.zip(other_grid.spaces).any? { |space_a, space_b| space_a != space_b }
  end

  def spaces
    @spaces ||= rows.flatten
  end

  def space_at(x, y)
    [x, y].any?(&:negative?) || rows[x].nil? ? nil : rows[x][y]
  end

  def occupied_seat_count
    @occupied_seat_count ||= spaces.count(&:occupied?)
  end

  def to_s
    lines
  end

  class InvalidStateError < StandardError; end
end

class Space
  attr_reader :x, :y, :state, :grid

  def initialize(x, y, state, grid)
    @x = x
    @y = y
    @state = validate(state)
    @grid = grid
  end

  def !=(other_space)
    state != other_space.state || x != other_space.x || y != other_space.y
  end

  def sit_or_vacate!
    sit? && sit! || vacate? && vacate!
  end

  def seat?
    !floor?
  end

  def occupied?
    state == Grid::SPACE_STATES[:occupied]
  end

  def to_s
    state
  end

  private

  attr_writer :state

  def sit!
    self.state = Grid::SPACE_STATES[:occupied]
  end

  def vacate!
    self.state = Grid::SPACE_STATES[:vacant]
  end

  def floor?
    state == Grid::SPACE_STATES[:floor]
  end

  def vacant?
    state == Grid::SPACE_STATES[:vacant]
  end

  def sit?
    vacant? && all_nearest_visible_seats_vacant?
  end

  def all_nearest_visible_seats_vacant?
    !nearest_visible_seats.any?(&:occupied?)
  end

  def vacate?
    occupied? && exceeds_occupied_seat_limit?
  end

  def exceeds_occupied_seat_limit?
    nearest_visible_seats.count(&:occupied?) > grid.occupied_seat_limit
  end

  def nearest_visible_seats
    @nearest_visible_seats ||= Grid::DIRECTIONS.filter_map(&nearest_visible_seat)
  end

  def nearest_visible_seat
    lambda do |(x_dir, y_dir)|
      space, distance, next_x, next_y = nil, 0, x, y

      until distance == grid.occupied_seat_distance do
        distance = distance.next
        next_x += x_dir
        next_y += y_dir

        space = grid.space_at(next_x, next_y)

        break if space.nil? || space.seat?
      end

      space
    end
  end

  def validate(state)
    state.tap do
      raise Grid::InvalidStateError.new(
        "Invalid state #{state.inspect} provided for space (#{x},#{y}). " \
        "Valid states are #{Grid::SPACE_STATES.values.map(&:inspect).join(', ')}."
      ) unless Grid::SPACE_STATES.values.include?(state)
    end
  end
end

class PuzzleVariantError < StandardError; end
