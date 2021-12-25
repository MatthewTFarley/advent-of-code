# frozen_string_literal: true

public

def puzzle_one
  pf = Pathfinder.new
  pf.lowest_total_risk
end

def puzzle_two
  Input.five_times
  pf = Pathfinder.new
  pf.lowest_total_risk
end

private

class Pathfinder
  attr_accessor :y, :x, :node_visited_symbol

  def initialize
    @y = 0
    @x = 0
    @node_visited_symbol = 'A'
  end

  def node_visited_index
    @node_visited_index ||= {}
  end

  def lowest_total_risk
    node_visited_index[current_node] = node_visited_symbol
    self.node_visited_symbol = node_visited_symbol.next
    until current_node.ending?
      unvisited_adjacent.each do |node|
        new_distance = (current_node.distance || current_node.weight) + (node.distance || node.weight)
        if node.distance.nil? || new_distance < node.distance
          node.distance = new_distance
          node.parent = current_node
        end
      end

      current_node.mark_visited!
      next_node = shortest_distance
      self.y, self.x = next_node.coords
      node_visited_index[current_node] = node_visited_symbol
      self.node_visited_symbol = node_visited_symbol.next
    end

    path = []
    while current_node.parent
      path << current_node
      self.y, self.x = current_node.parent.coords
    end

    path.take(path.length).sum(&:weight)
  rescue StandardError => e
    raise e
  end

  def pretty_weight
    nodes.map { |row| row.map(&:weight) }
  end

  def pretty_distance
    nodes.map { |row| row.map(&:distance) }
  end

  def pretty_combined
    nodes.map do |row|
      row.map do |node|
        "#{node.weight},#{(node.distance).to_s.rjust(2, ' ')},#{(node.visited? ? node_visited_index[node] : '.').rjust(2, ' ')}"
      end
    end
  end

  def visited_path
    nodes.map { |row| row.map { |node| node.visited? ? 'x' : '.'} }
  end

  private

  def nodes
    Input.nodes
  end

  def node_index
    @node_index ||=
      nodes.flatten.each_with_object({}) do |node, hash|
        hash[node.coords] = node
      end
  end

  def current_node
    node_index[[y,x]]
  end

  def adjacent
    [bottom, right, top,left].compact
  end

  def unvisited_adjacent
    adjacent.select(&:unvisited?)
  end

  def unvisited_nodes_with_distance
    nodes.flatten.select(&:distance).select(&:unvisited?)
  end

  def shortest_distance
    unvisited_nodes_with_distance.min_by(&:distance)
  end

  def top
    y == lower_bound ? nil: nodes[y-1][x]
  end

  def bottom
    y == upper_bound ? nil : nodes[y+1][x]
  end

  def left
    x == lower_bound ? nil : nodes[y][x-1]
  end

  def right
    x == upper_bound ? nil : nodes[y][x+1]
  end

  def lower_bound
    0
  end

  def upper_bound
    nodes.length.pred
  end
end

class Node
  attr_accessor :y, :x, :distance, :visited, :weight, :parent
  alias_method :visited?, :visited

  def initialize(y, x, weight)
    @y = y
    @x = x
    @weight = weight
    @distance = nil
    @visited = false
    @parent = nil
  end

  def coords
    [y, x]
  end

  def mark_visited!
    self.visited = true
  end

  def unvisited?
    !visited?
  end

  def starting?
    y.zero? && x.zero?
  end

  def ending?
    y == nodes.length.pred && x == nodes.last.length.pred
  end

  def to_s
    "X: #{x}; Y: #{y}; Weight: #{weight}; Distance: #{distance}; Visited: #{visited}"
  end

  private

  def nodes
    Input.nodes
  end
end

module Input
  class << self
    def raw
      @@raw ||=IO.readlines("#{__dir__}/input.txt", chomp: true).map { |row| row.split('').map(&:to_i) }
    end

    def nodes
      @@nodes ||= IO.readlines("#{__dir__}/input.txt", chomp: true)
        .map.with_index do |row, y|
          row.split('').map.with_index { |cell, x| Node.new(y, x, cell.to_i) }
        end
    end

    def five_times
      @@nodes ||=
        5.times.map do |i|
          raw.map do |row|
            row.map do |cell|
              new_value = cell + i
              if new_value >= 10
                new_value - 10 + 1
              else
                new_value
              end
            end
          end
        end
        .flatten(1)
        .map do |row|
          5.times.each_with_object([]) do |i, new_array|
            new_array << row.map do |cell|
              new_value = cell + i
              if new_value >= 10
                new_value - 10 + 1
              else
                new_value
              end
            end
          end.reduce(&:concat)
        end
        .map.with_index do |row, y|
          row.map.with_index { |cell, x| Node.new(y, x, cell.to_i) }
        end
    end
  end
end
