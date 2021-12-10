# frozen_string_literal: true

public

def puzzle_one
  invalid_brackets.sum { |invalid_bracket| INVALID_POINT_MAP[invalid_bracket] }
end

def puzzle_two
  incomplete_stacks.map do |stack|
    stack.reverse.each_with_object([]) { |bracket, ending| ending << BRACKET_PAIR[bracket] }
  end.map do |ending|
    ending.reduce(0) do |score, bracket|
      score * 5 + AUTOCOMPLETE_POINT_MAP[bracket]
    end
  end.sort.then { |scores| scores[scores.length / 2] }
end

private

def invalid_brackets
  @invalid_brackets ||=
    Input.rows.each_with_object([]) do |row, memo|
      row.each_with_object([]) do |bracket, stack|
        if BRACKET_PAIR.keys.include?(bracket)
          stack << bracket
        elsif BRACKET_PAIR[stack.pop] != bracket
          memo << bracket
          break
        end
      end
    end
end

def incomplete_stacks
  @incomplete_stacks ||= Input.rows.each_with_object([]) do |row, incomplete|
    stack = row.each_with_object([]) do |bracket, stack|
      if opening?(bracket)
        stack << bracket
      elsif invalid?(stack.pop, bracket)
        break
      end
    end

    incomplete << stack if stack&.any?
  end
end

def opening?(bracket)
  BRACKET_PAIR.keys.include?(bracket)
end

def invalid?(prev, bracket)
  BRACKET_PAIR[prev] != bracket
end

BRACKET_PAIR = {
  '(' => ')',
  '[' => ']',
  '{' => '}',
  '<' => '>',
}.freeze

INVALID_POINT_MAP = {
  ')' => 3,
  ']' => 57,
  '}' => 1197,
  '>' => 25137,
}.freeze

AUTOCOMPLETE_POINT_MAP = {
  ')' => 1,
  ']' => 2,
  '}' => 3,
  '>' => 4,
}.freeze


class Input
  class << self
    def rows
      @@rows ||= IO.readlines("#{__dir__}/input.txt", chomp: true)
      .map { |row| row.split('') }
    end
  end
end
