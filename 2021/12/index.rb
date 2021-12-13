# frozen_string_literal: true

public

def puzzle_one
  solve_with_small_cave_visit_limit_of(1)
end

def puzzle_two
  solve_with_small_cave_visit_limit_of(2)
end

private

def solve_with_small_cave_visit_limit_of(small_cave_visit_limit)
  Traversal.new(small_cave_visit_limit).successful_traversals.count
end

class Traversal
  attr_reader :sub_traversals, :success, :initial_traversal
  attr_accessor :current_cave, :cave_visits
  alias_method :success?, :success

  def initialize(small_cave_visit_limit)
    @current_cave = Input.caves.find(&:starting?)
    @initial_traversal = self
    @small_cave_visit_limit = small_cave_visit_limit
    @sub_traversals = []
    @success = false
  end

  def traverse
    cave_visits[current_cave.name] += 1
    self.small_cave_visit_limit = 1 if reached_small_cave_visit_limit_for?(current_cave)

    reachable_caves.each do |cave|
      initial_traversal.sub_traversals << self.dup.tap do |sub_traversal|
        sub_traversal.cave_visits = cave_visits.dup
        sub_traversal.current_cave = cave
        sub_traversal.traverse
      end
    end
    self.tap { self.success = true if current_cave.ending? }
  end

  def traversals
    @traversals ||= [self.traverse, *sub_traversals]
  end

  def successful_traversals
    traversals.select(&:success?)
  end

  def cave_visits
    @cave_visits ||= Hash.new(0)
  end

  private

  def reachable_caves
    return [] if current_cave.ending?

    current_cave.adjacent_caves.reject do |cave|
      cave.starting? || reached_small_cave_visit_limit_for?(cave)
    end
  end

  def reached_small_cave_visit_limit_for?(cave)
    cave.small? && cave_visits[cave.name] >= small_cave_visit_limit
  end

  attr_accessor :small_cave_visit_limit
  attr_writer :success
end

class Cave
  attr_reader :name, :adjacent_caves

  def initialize(name)
    @name = name
    @adjacent_caves = []
  end

  def small?
    /[a-z]+/.match?(name)
  end

  def starting?
    name == 'start'
  end

  def ending?
    name == 'end'
  end
end

module Input
  class << self
    def file
      @@lines = IO.read("#{__dir__}/input.txt")
    end

    def caves
      @@caves ||= begin
          file.scan(/^(\w+)-(\w+)$/).each_with_object({}) do |(name_a, name_b), caves|
          cave_a = caves[name_a] || Cave.new(name_a)
          cave_b = caves[name_b] || Cave.new(name_b)
          cave_a.adjacent_caves << cave_b
          cave_b.adjacent_caves << cave_a
          caves[name_a] ||= cave_a
          caves[name_b] ||= cave_b
        end
      end.values
    end
  end
end
