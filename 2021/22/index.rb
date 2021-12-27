# frozen_string_literal: true
require 'ostruct'

public

def puzzle_one
  # Does not perform well at all On^3
  Input.instructions.each_with_object({}) do |instruction, memo|
    instruction.x1.upto(instruction.x2).each do |x|
      instruction.y1.upto(instruction.y2).each do |y|
        instruction.z1.upto(instruction.z2).each do |z|
          memo[[x,y,z]] = instruction.state
        end
      end
    end
  end.count { |k, v| v }
end

def puzzle_two
end

private

module Input
  class << self
    PATTERN = /(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)/.freeze

    def instructions
      @@instructions ||= IO
        .readlines("#{__dir__}/sample.txt", chomp: true)
        .map do |line|
          state, x1, x2, y1, y2, z1, z2 = line.scan(PATTERN).first
          x1, x2, y1, y2, z1, z2 = [x1, x2, y1, y2, z1, z2].map { |n| adjust(n) }
          OpenStruct.new(state: state == 'on' ? true : false, x1: x1, x2: x2, y1: y1, y2: y2, z1: z1, z2: z2)
        end
    end

    def lowest_value
      @@lowest_value ||= IO.read("#{__dir__}/sample.txt").scan(/-?\d+/).min_by { |match| match.to_i }.to_i
    end

    def adjust(n)
      # if lowest_value.negative?
      if false
        n.to_i + lowest_value.abs
      else
        n.to_i
      end
    end
  end
end
