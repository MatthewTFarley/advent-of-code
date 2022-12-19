# frozen_string_literal: true

public

def puzzle_one
  process(20, 3)
end

def puzzle_two
  process(10000, nil)
end

private

def process(round_count, worry_decrement = nil)
  MonkeyProcessor.new(input, worry_decrement).then do |monkey_processor|
    round_count.times { monkey_processor.process }
    monkey_processor
    .monkeys
    .sort_by(&:inspect_count)
    .slice(-2..)
    .reduce(1) { |acc, monkey| acc * monkey.inspect_count }
  end
end

class MonkeyProcessor
  attr_reader :monkeys, :worry_decrementer

  def initialize(input, worry_decrement = nil)
    @monkeys = parse_input
    @worry_decrementer = begin
      devisor = worry_decrement.presence || monkeys.map(&:divisor).reduce(1, &:*)
      operation = worry_decrement.present? ? '/' : '%'
      ->(dividend) { dividend.public_send(operation, devisor) }
    end
  end

  def process
    monkeys.each do |monkey|
      while monkey.items.any?
        monkey.inspect_next_item(worry_decrementer) do |target, updated|
          monkeys[target].items.push(updated)
        end
      end
    end
  end

  private

  def parse_input
    @monkeys = begin
      groups = input.split("\n\n")
      groups.map do |group|
        group.split("\n").map.with_index do |line, index|
            case index
            when 0 then line.scan(/\d+/).first.to_i
            when 1 then line.scan(/\d+/).map(&:to_i)
            when 2 then line.split('= ').last.gsub('old', 'item')
            when 3,4,5 then line.scan(/\d+/).first.to_i
            else raise StandardError.new('Invalid input format')
            end
        end.then { |props| Monkey.new(*props) }
      end
    end
  end
end

class Monkey
  attr_reader :inspect_count, :number, :items, :operation, :divisor, :a, :b

  def initialize(number, items, operation, divisor, a, b)
    @inspect_count = 0
    @number = number
    @items = items
    @operation = operation
    @divisor = divisor
    @a = a
    @b = b
  end

  def inspect_next_item(worry_decrementer, &block)
    self.inspect_count = inspect_count.next
    items
    .shift
    .then { |item| eval(operation) }
    .then { |applied| worry_decrementer.call(applied) }
    .then { |decreased| [decreased.remainder(divisor).zero? ? a : b, decreased] }
    .then &block
  end

  private

  attr_writer :inspect_count
end

def input
  IO.read("#{__dir__}/input.txt")
end
