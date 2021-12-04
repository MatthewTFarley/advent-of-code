# frozen_string_literal: true

public

def puzzle_one
  write_to_memory(get_lines) do |memory, mask, address, value|
    memory[address] = masked_value(mask, value)
  end.values.sum
end

def puzzle_two
  write_to_memory(get_lines) do |memory, mask, address, value|
    save(memory, value, masked_address(mask, address))
  end.values.sum
end

private

class String
  def to_binary(length = 36)
    ['%b', self].reduce(:%).rjust(length, '0')
  end

  def to_a
    self.split('')
  end

  def to_binary_a
    self.to_binary.to_a
  end
end

def write_to_memory(lines, &block)
  mask = nil
  lines.each_with_object({}) do |line, memory|
    next mask = to_mask(line).to_a if /^mask/.match?(line)
    yield memory, mask, *address_and_value_from(line)
  end
end

def save(memory, value, address)
  address.partition('X').then do |before_x, x, after_x|
    return memory[address] = value.to_i if x.empty?
    %w(0 1).each { |bit| save(memory, value, "#{before_x}#{bit}#{after_x}") }
  end
end

def get_lines
  IO.readlines("#{__dir__}/input.txt", chomp: true)
end

def to_mask(line)
  line[-36..]
end

def address_and_value_from(line)
  /mem\[(\d+)\] = (\d+)/.match(line)[1..]
end

def masked_value(mask, value)
  mask.zip(value.to_binary_a).reduce('') do |acc, (mask_bit, value_bit)|
    acc += mask_bit == 'X' ? value_bit : mask_bit
  end.to_i(2)
end

def masked_address(mask, address)
  mask.zip(address.to_binary_a).reduce('') do |acc, (mask_bit, address_bit)|
    acc += mask_bit == 'X' ? mask_bit : bitwise_or(mask_bit, address_bit)
  end
end

def bitwise_or(b1, b2)
  [b1, b2].map(&:to_i).reduce(:|).to_s(2)
end
