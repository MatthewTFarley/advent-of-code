# frozen_string_literal: true

public

def puzzle_one
  puts forest.to_s.tr("\n", "").chars.count { |el| el == 'T' }
  # puts '-' * 10
  # puts expected
  # puts '-' * 10
  # puts (raw_forest.map do |row|
  #   row.map { |cell| cell.to_s }.join
  # end.join("\n"))
  # puts '-' * 10
  # puts (raw_forest.transpose.map do |row|
  #   row.map { |cell| cell.to_s }.join
  # end.join("\n"))
end

def puzzle_two
  raw_forest.map.with_index do |row, y|
    row.map.with_index do |cell, x|
      top = raw_forest_t[y][0...x].reverse
      right = raw_forest[x][y.next...]
      bottom = raw_forest_t[y][x.next..]
      left = raw_forest[x][0...y].reverse
      if x == 0 && y == 1
        pp [
          raw_forest_t[y][x],
          top,
          right,
          bottom,
          left
        ]
      end
      [[top, 'top'],[right,'right'],[bottom, 'bottom'],[left, 'left']].map do |(row, dir)|
        # if row.empty?
        #   ["#{y},#{x}", cell, 0, dir]
        # else
        #   ["#{y},#{x}", cell, row.take_while { |tree| tree < cell }.count.next, dir]
        # end

        {[y,x,dir] => if row.empty?
          0
        else
          row.take_while { |tree| tree < cell }.count.next
        end
      }
      end
      # if x == 2 && y == 2
      #   pp top
      #   pp right
      #   pp bottom
      #   pp left
      # end
    end
  end
end

# 30373
# 25512
# 65332
# 33549
# 35390
# -----
# 32633
# 05535
# 35353
# 71349
# 32290



def raw_forest_t
  @raw_forest_t ||= raw_forest.transpose
end

private

def expected
  <<~HEREDOC
  TTTTT
  TTTFT
  TTFTT
  TFTFT
  TTTTT
  HEREDOC
end

class Forest
  attr_reader :value

  def initialize
    @value = input.map.with_index do |row, y|
      row.chars.map.with_index do |cell, x|
        Tree.new(cell.to_i, y, x)
      end
    end
  end

  def tree_at(x, y)
    [x, y].any?(&:negative?) ? nil : value[x]&.[](y)
  end

  def to_s
    value.map do |row|
      row.map { |cell| cell.to_s }.join
    end.join("\n")
  end
end

def forest
  @forest ||= Forest.new
end

class Tree
  attr_reader :value, :visible, :x, :y

  def initialize(value, x, y)
    @value = value
    @x = x
    @y = y
  end

  def first_or_last?
    first? || last?
  end

  def visible?
    @visible ||= begin
      if first_or_last?
        return true
      end

      # if value == 1
      #   pp [x, y]
      #   pp top
      #   pp right
      #   pp bottom
      #   pp left
      # end

      [top, right, bottom, left].any? do |trees|
        trees.none? do |tree|
          tree >= value
        end
      end
    end
  end

  def shorter?(tree)
    value > tree.value
  end

  def first?
    [x, y].any?(&:zero?)
  end

  def last?
    [x, y].any? { |el| el == raw_forest.length.pred }
  end

  def top
    raw_forest.transpose[y][0...x]
  end

  def right
    raw_forest[x][y.next...]
  end

  def bottom
    raw_forest.transpose[y][x.next..]
  end

  def left
    raw_forest[x][0...y]
  end

  def neighbors
    {top: top, right: right, bottom: bottom, left: left}
  end

  def to_s
    visible? ? 'T' : 'F'
  end
end

def raw_forest
  @raw_forest ||= input.map do |row|
    row.chars.map(&:to_i)
  end
end

def input
  @input ||= IO.readlines("#{__dir__}/sample.txt", chomp: true)
end
