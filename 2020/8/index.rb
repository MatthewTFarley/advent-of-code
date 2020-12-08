# frozen_string_literal: true

public

def main(puzzle_variant = '1')
  case puzzle_variant
  when '1' then variant_one
  when '2' then variant_two
  else raise PuzzleVariantError.new 'Invalid puzzle variant provided. Valid values are "1", and "2"'
  end

rescue PuzzleVariantError, InvalidOperationError => error
  error
end

def variant_one
  Program.new(boot_code).execute.first
end

def variant_two
  Program.new(boot_code).repair
end

private

def boot_code
  @boot_code ||= IO.readlines("#{__dir__}/input.txt", chomp: true)
end

class Program
  Instruction = Struct.new(:id, :operation, :sign, :value)

  REPAIR_MAP = {
    'nop' => 'jmp',
    'jmp' => 'nop'
  }

  attr_reader :boot_code
  attr_accessor :seen_instruction

  def initialize(boot_code)
    @boot_code = boot_code
  end

  def execute(repaired_instruction = nil)
    cursor = 0
    acc = 0
    seen_instructions = []
    next_instruction = instructions_index[0]
    infinite_loop = false
    next_instruction = repaired_instruction if next_instruction.id == repaired_instruction&.id

    while next_instruction do
      next_instruction = repaired_instruction if next_instruction.id == repaired_instruction&.id

      if seen_instructions.include? next_instruction.id
        infinite_loop = true
        break
      end

      seen_instructions << next_instruction.id

      case next_instruction.operation
      when 'nop'
        cursor += 1
      when 'acc'
        acc = acc.public_send(next_instruction.sign, next_instruction.value)
        cursor += 1
      when 'jmp'
        cursor = cursor.public_send(next_instruction.sign, next_instruction.value)
      else
        raise InvalidOperationError.new next_instruction
      end
      next_instruction = instructions_index[cursor]
    end

    [acc, infinite_loop]
  end

  def repair
    instructions_index
    .select { |id, instruction| %w('nop jmp).include? instruction.operation }
    .reduce do |memo, (id, instruction)|
      repaired_instruction = instruction.dup.tap do |instr|
        instr.operation = REPAIR_MAP[instr.operation]
      end

      acc, infinite_loop = execute(repaired_instruction)
      break acc if !infinite_loop
      memo
    end
  end

  def instructions_index
    @instructions_index ||=
      boot_code.each_with_object({}).with_index do |(line, lookup), index|
        lookup[index] = line.scan(/(\w{3}) ([+-]{1})(\d+)/).flatten.then do |(operation, sign, value)|
          Instruction.new index, operation, sign, value.to_i
        end
      end
  end

  private

end

class PuzzleVariantError < StandardError; end
class InvalidOperationError < StandardError; end
