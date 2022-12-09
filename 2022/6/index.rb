# frozen_string_literal: true

public

def puzzle_one
  find_start_of_packet(4)
end

def puzzle_two
  find_start_of_packet(14)
end

private

def find_start_of_packet(packet_marker_size)
  input.chars.each_cons(packet_marker_size).with_index.find do |chars, index|
    chars.uniq.size === packet_marker_size
  end.last + packet_marker_size
end

def input
  @input ||= IO.read("#{__dir__}/input.txt").strip
end
