# frozen_string_literal: true

public

def puzzle_one
  BearingShip.new(instructions).execute_instructions!.manhattan_distance
end

def puzzle_two
  WaypointShip.new(instructions).execute_instructions!.manhattan_distance
end

private

NORTH = 'N'
SOUTH = 'S'
EAST = 'E'
WEST = 'W'
FORWARD = 'F'
LEFT = 'L'
RIGHT = 'R'

DIRECTION = {
  NORTH => NORTH,
  EAST => EAST,
  SOUTH => SOUTH,
  WEST => WEST,
}.freeze

ROTATE = {
  LEFT => LEFT,
  RIGHT => RIGHT,
}.freeze

NEXT = {
  DIRECTION[NORTH] => DIRECTION[EAST],
  DIRECTION[EAST] => DIRECTION[SOUTH],
  DIRECTION[SOUTH] => DIRECTION[WEST],
  DIRECTION[WEST] => DIRECTION[NORTH],
}.freeze

PRED = NEXT.invert.freeze

FLIP = {
  DIRECTION[NORTH] => DIRECTION[SOUTH],
  DIRECTION[EAST] => DIRECTION[WEST],
  DIRECTION[SOUTH] => DIRECTION[NORTH],
  DIRECTION[WEST] => DIRECTION[EAST],
}.freeze

def instructions
  @instructions ||=
    IO
    .readlines("#{__dir__}/input.txt", chomp: true)
    .map { |instruction| Instruction.new instruction }
end

class Ship
  attr_accessor :instructions, :x, :y

  def initialize(instructions, x = 0, y = 0)
    @instructions = instructions
    @x = x
    @y = y
  end

  def location
    [x, y]
  end

  def manhattan_distance
    location.map(&:abs).sum
  end

  def location_as_direction
    x_as_direction = (x.negative? ? WEST : EAST) + x.abs.to_s
    y_as_direction = (y.negative? ? SOUTH : NORTH) + y.abs.to_s
    [x_as_direction, y_as_direction]
  end

  private

  def execute!(instruction, adjunct = nil)
    a, m = instruction.action, instruction.magnitude

    case a
    when *DIRECTION.values then move!(self, a, m)
    when ROTATE[LEFT] then (m / 90).times { adjunct.pred! }
    when ROTATE[RIGHT] then (m / 90).times { adjunct.next! }
    else raise ActionError.new "Action #{a.inspect} cannot be handled."
    end
  end

  def move!(obj, direction, magnitude)
    case direction
    when DIRECTION[NORTH] then obj.y += magnitude
    when DIRECTION[EAST] then obj.x += magnitude
    when DIRECTION[SOUTH] then obj.y -= magnitude
    when DIRECTION[WEST] then obj.x -= magnitude
    end
  end

  def to_s
    "xdir: #{location_as_direction.join(', ydir: ')}, " \
    "x: #{location.join(' y: ')}"
  end

  class ActionError < StandardError; end
end

class BearingShip < Ship
  attr_accessor :bearing

  def initialize(instructions, x = 0, y = 0, bearing = Bearing.new)
    super instructions, x, y
    @bearing = bearing
  end

  def execute_instructions!
    self.tap do
      instructions.each do |i|

        if i.action == FORWARD
          move!(self, bearing.direction, i.magnitude)
        else
          execute!(i, bearing)
        end
      end
    end
  end

  def to_s
    "#{super}, bearing: #{bearing}"
  end
end

class WaypointShip < Ship
  attr_reader :waypoint

  def initialize(instructions, x = 0, y = 0, waypoint = Waypoint.new)
    super instructions, x, y
    @waypoint = waypoint
  end

  def execute_instructions!
    self.tap do
      instructions.each do |i|
        a, m = i.action, i.magnitude

        case a
        when *DIRECTION.values then move!(waypoint, a, m)
        when FORWARD then m.times { waypoint.instructions.each { |wp| execute!(wp) } }
        else execute!(i, waypoint)
        end

        waypoint.sync!
      end
    end
  end

  def to_s
    "#{super}, waypoint: #{waypoint}"
  end
end

class Waypoint
  attr_accessor :x_bearing, :x, :y_bearing, :y

  def initialize(x_bearing = Bearing.new, x = 10, y_bearing = Bearing.new(DIRECTION[NORTH]), y = 1)
    @x_bearing = x_bearing
    @x = x.to_i
    @y_bearing = y_bearing
    @y = y.to_i
  end

  def next!
    self.x, self.y = y, -self.x
  end

  def pred!
    self.x, self.y = -self.y, x
  end

  def sync!
    x_bearing.flip! if x_bearing.east? && x.negative? || x_bearing.west? && x > -1
    y_bearing.flip! if y_bearing.north? && y.negative? || y_bearing.south? && y > -1
  end

  def instructions
    [x_instruction, y_instruction]
  end

  def to_s
    "#{x_bearing}#{x.abs}, #{y_bearing}#{y.abs}"
  end

  private

  def x_instruction
    Instruction.new "#{x_bearing}#{x.abs}"
  end

  def y_instruction
    Instruction.new "#{y_bearing}#{y.abs}"
  end
end

class Bearing
  attr_accessor :direction

  def initialize(direction = DIRECTION[EAST])
    @direction = direction
  end

  def next!
    self.direction = NEXT[direction]
  end

  def pred!
    self.direction = PRED[direction]
  end

  def flip!
    self.direction = FLIP[direction]
  end

  def north?
    direction == DIRECTION[NORTH]
  end

  def east?
    direction == DIRECTION[EAST]
  end

  def south?
    direction == DIRECTION[SOUTH]
  end

  def west?
    direction == DIRECTION[WEST]
  end

  def to_s
    direction
  end
end

class Instruction
  attr_reader :instruction, :action, :magnitude

  def initialize(instruction)
    @instruction = instruction
    @action = instruction[0]
    @magnitude = instruction[1..].to_i
  end

  def to_s
    instruction
  end
end
