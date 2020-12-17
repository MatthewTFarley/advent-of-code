# frozen_string_literal: true

public

def main(puzzle_variant = '1')
  case puzzle_variant
  when '1' then variant_one
  when '2' then variant_two
  else raise PuzzleVariantError.new 'Invalid puzzle variant provided. Valid values are "1", and "2"'
  end

rescue PuzzleVariantError => error
  error
end

def variant_one
  active_cube_count_for(Matrix.new(lines))
end

def variant_two
  active_cube_count_for(HyperMatrix.new(lines))
end

private

def active_cube_count_for(matrix)
  6.times.reduce(matrix) do |m|
    m.prime_cache!
    m.cycle!
  end.active_cubes.count
end

def lines
  @lines ||= IO.readlines("#{__dir__}/input.txt", chomp: true)
end

class Matrix
  CUBE_STATES = {
    inactive: '.',
    active: '#'
  }.freeze

  DIRECTIONS = [
  # lower plane (z = -1)
    [-1, -1, -1], [-1, +0, -1], [-1, +1, -1],
    [+0, -1, -1], [+0, +0, -1], [+0, +1, -1],
    [+1, -1, -1], [+1, +0, -1], [+1, +1, -1],
  # current plane (z = 0)
    [-1, -1, +0], [-1, +0, +0], [-1, +1, +0],
    [+0, -1, +0],               [+0, +1, +0],
    [+1, -1, +0], [+1, +0, +0], [+1, +1, +0],
  # upper plane (z = 1)
    [-1, -1, +1], [-1, +0, +1], [-1, +1, +1],
    [+0, -1, +1], [+0, +0, +1], [+0, +1, +1],
    [+1, -1, +1], [+1, +0, +1], [+1, +1, +1],
  ]

  attr_reader :lines
  attr_writer :cube_cache

  def initialize(lines)
    @lines = lines
    cube_cache
  end

  def cycle!
    copy.tap do |cp|
      cp.cubes.each do |cp_cube|
        cube = cube_cache[cp_cube.coords]
        if cube.active?
          cp_cube.flip! unless [2, 3].include?(cube.active_neighbors.count)
        else
          cp_cube.flip! if cube.active_neighbors.count == 3
        end
      end
    end
  end

  def prime_cache!
    cubes.map(&:neighbors)
  end

  def cube_cache
    @cube_cache ||=
      {}.tap do |lookup|
        lines.each_with_index do |line, x|
          line.split('').each_with_index do |char, y|
            lookup[[x, y, 0]] = Cube.new(x, y, 0, char, self)
          end
        end
      end
  end

  def active_cubes
    cubes.select(&:active?)
  end

  private

  def copy
    Matrix.new(self.lines).tap do |matrix|
      cube_cache.values.each do |cube|
        matrix.cube_cache[cube.coords] = Cube.new(*cube.attrs, matrix)
      end
    end
  end

  def cubes
    cube_cache.values
  end

  def to_s
    cubes.map(&:to_s).join
  end
end

class HyperMatrix < Matrix
  DIRECTIONS =
    [
      [0, 0, 0, -1],
      [0, 0, 0, +1],
      *[-1, 0, 1].flat_map { |w| Matrix::DIRECTIONS.map { |coord| [*coord, w] } }
    ]

  def cube_cache
    @cube_cache ||=
      {}.tap do |lookup|
        lines.each_with_index do |line, x|
          line.split('').each_with_index do |char, y|
            coords = [x, y, 0, 0]
            lookup[coords] = HyperCube.new(*coords, char, self)
          end
        end
      end
  end

  private

  def copy
    HyperMatrix.new(self.lines).tap do |matrix|
      cube_cache.values.each do |cube|
        matrix.cube_cache[cube.coords] = HyperCube.new(*cube.attrs, matrix)
      end
    end
  end
end

class Cube
  ACTIVE = Matrix::CUBE_STATES[:active]
  INACTIVE = Matrix::CUBE_STATES[:inactive]

  FLIP = {
    ACTIVE   => INACTIVE,
    INACTIVE => ACTIVE,
  }.freeze

  attr_accessor :state

  attr_reader :x, :y, :z, :state, :matrix

  def initialize(x, y, z, state, matrix)
    @x = x
    @y = y
    @z = z
    @state = state
    @matrix = matrix
  end

  def coords
    [x, y, z]
  end

  def attrs
    [*coords, state]
  end

  def flip!
    self.state = FLIP[state]
  end

  def active?
    state == '#'
  end

  def neighbors
    @neighbors ||=
      Matrix::DIRECTIONS.map do |(x_dir, y_dir, z_dir)|
        neighbor_coords = [x + x_dir, y + y_dir, z + z_dir]
        matrix.cube_cache[neighbor_coords] ||= Cube.new(*neighbor_coords, INACTIVE, matrix)
      end
  end

  def active_neighbors
    neighbors.select(&:active?)
  end

  def to_s
    state
  end

  def inspect
    "<#{self.class.name}: #{{ coords => state }}>"
  end
end

class HyperCube < Cube
  attr_reader :x, :y, :z, :w, :state, :matrix

  def initialize(x, y, z, w, state, matrix)
    @x = x
    @y = y
    @z = z
    @w = w
    @state = state
    @matrix = matrix
  end

  def coords
    [x, y, z, w]
  end

  def neighbors
    @neighbors ||=
      HyperMatrix::DIRECTIONS.map do |(x_dir, y_dir, z_dir, w_dir)|
        neighbor_coords = [x + x_dir, y + y_dir, z + z_dir, w + w_dir]
        matrix.cube_cache[neighbor_coords] ||= HyperCube.new(*neighbor_coords, INACTIVE, matrix)
      end
  end

end

class PuzzleVariantError < StandardError; end
