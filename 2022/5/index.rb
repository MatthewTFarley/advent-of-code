# frozen_string_literal: true

public

def puzzle_one
  process_intructions do |from_stack, to_stack, count|
    count.times do
      to_stack.push(from_stack.pop)
    end
  end
end

def puzzle_two
  process_intructions do |from_stack, to_stack, count|
    to_stack.concat(from_stack.slice!((-count)..))
  end
end

private

def process_intructions
  instructions.each do |count, from, to|
    from_stack = stacks[from.pred]
    to_stack = stacks[to.pred]
    yield from_stack, to_stack, count
  end

  stacks.map(&:last).join
end

def format(stacks)
  stacks.map(&:join).join("\n")
end

def stacks
  @stacks ||=
    Array
    .new(stack_count) { [] }
    .each.with_index do |stack, index|
      stack_rows[0..-2].each do |stack_row|
        val = stack_row[value_indices[index]]
        stack.unshift val if val != ' '
      end
    end
end

def stack_count
  stack_rows.last[-2].to_i
end

def stack_rows
  @stack_rows ||= input.take_while(&:present?)
end

def value_indices
  @value_indices ||= 0.upto(stack_rows.last.length).reject do |index|
    stack_rows.last[index].blank?
  end
end

def instructions
  input
  .reverse
  .take_while(&:present?)
  .map { |line| line.scan(/\d+/).map(&:to_i) }
  .reverse
end


def input
  @input ||= IO.readlines("#{__dir__}/input.txt", chomp: true)
end
