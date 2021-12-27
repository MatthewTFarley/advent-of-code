# frozen_string_literal: true

require 'ostruct'

public

def puzzle_one
  11111111111111.upto(11111111112111).each_with_object([]) do |model_number, valid_numbers|
    # pp model_number
    digits = model_number.to_s.split('').map(&:to_i).reverse
    vars = {
      'w' => 0,
      'x' => 0,
      'y' => 0,
      'z' => 0,
    }
    instructions.each do |instruction|
      a, b = [instruction.a, instruction.b].map do |var|
        var.is_a?(Numeric) ? var : vars[var]
      end

      case instruction.operation
      when 'inp'
        vars[instruction.a] = digits.pop
      when 'add'
        vars[instruction.a] = a + b
      when 'mul'
        vars[instruction.a] = a * b
      when 'div'
        vars[instruction.a] = a / b
      when 'mod'
        vars[instruction.a] = a % b
      when 'eql'
        vars[instruction.a] = a == b ? 1 : 0
      end
    end
    vars['z'].zero? && valid_numbers << model_number
  end
end

def puzzle_two
end

private

def execute(instruction, digits)
  a, b = [instruction.a, instruction.b].map do |var|
    var.is_a?(Numeric) ? var : vars[var]
  end

  case instruction.operation
  when 'inp'
    vars[instruction.a] = 0
  when 'add'
    vars[instruction.a] = a + b
  when 'mul'
    vars[instruction.a] = a * b
  when 'div'
    vars[instruction.a] = a / b
  when 'mod'
    vars[instruction.a] = a % b
  when 'eql'
    vars[instruction.a] = a == b ? 1 : 0
  end
end

def instructions
  Input.instructions
end

module Input
  class << self
    def instructions
      @@instructions ||= IO.readlines("#{__dir__}/input.txt", chomp: true).map do |instruction|
        operation, a, b = instruction.split(' ')
        b = b&.match?(/-?\d+/) ? b.to_i : b
        OpenStruct.new(operation: operation, a: a, b: b)
      end
    end
  end
end
