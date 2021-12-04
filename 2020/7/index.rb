# frozen_string_literal: true

public

def variant_one(color)
  get_ancestors_of(color).uniq.count
end

def variant_two(color)
  get_descendants_count_for(color)
end

private

def get_ancestors_of(color, memo = [])
  ancestors = ancestors_index[color]

  return memo if ancestors.count.zero?

  ancestors.flat_map { |colour| get_ancestors_of(colour, memo + ancestors) }
end

def get_descendants_count_for(color)
  rule_children = rules_index[color].children

  return 0 if rule_children.empty?

  rule_children.sum do |child|
    child_count = child.count
    child_count + child_count * get_descendants_count_for(child.color)
  end
end

def rule_lines
  @rule_lines ||= IO.readlines("#{__dir__}/input.txt", chomp: true)
end

def ancestors_index
  @ancestors_index ||=
    rule_lines.each_with_object({}) do |rule_line, lookup|
      color = Rule.extract_color_from(rule_line)
      lookup[color] = ancestors_of(color)
    end
end

def rules_index
  @rules_index ||=
    rule_lines.each_with_object({}) do |rule_line, lookup|
      rule = Rule.new(rule_line)
      lookup[rule.color] = rule
    end
end

def ancestors_of(color)
  rule_lines.each_with_object([]) do |rule_line, ancestors|
    ancestors << Rule.extract_color_from(rule_line) if Rule.is_ancestor(rule_line, color)
  end
end

class Rule
  RuleChild = Struct.new(:count, :color)

  class << self
    def split(rl)
      rl.split(' bags contain ')
    end

    def extract_color_from(rl)
      split(rl).first
    end

    def is_ancestor(rl, color)
      /^#{Regexp.quote(color)}/ !~ rl && /#{Regexp.quote(color)}/ =~ rl
    end
  end

  attr_reader :rule_line

  def initialize(rule_line)
    @rule_line = rule_line
  end

  def color
    @color ||= Rule.split(rule_line).first
  end

  def children
    @children ||=
      Rule
      .split(rule_line).last
      .scan(/(\d)+ ([a-z ]+) bags?/)
      .map { |(count, color)| RuleChild.new count.to_i, color }
  end
end
