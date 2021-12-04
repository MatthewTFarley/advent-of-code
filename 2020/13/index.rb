# frozen_string_literal: true

public

def variant_one
  next_bus_to_arrive.id * time_to_wait
end

def variant_two
  first_staggered_occurrence
end

private

def lines
  @lines ||= IO.readlines("#{__dir__}/input.txt", chomp: true)
end

def earliest_arrival
  @earliest_arrival ||= lines.first.to_i
end

Bus = Struct.new :id, :index, :next_arrival_at do
  def <=>(other_bus)
    other_bus.next_arrival_at <=> next_arrival_at
  end

  def increment!
    self.next_arrival_at += id
  end

  def to_s
    "id: #{id}, index: #{index}, next_arrival_at: #{next_arrival_at}"
  end
end

def buses
  @buses ||=
    lines
    .last
    .split(',')
    .filter_map
    .with_index { |id, i| id != 'x' && Bus.new(id.to_i, i, 0) }
end

def time_to_wait
  @time_to_wait ||= next_bus_to_arrive.next_arrival_at - earliest_arrival
end

def next_bus_to_arrive
  @next_bus_to_arrive ||= begin
    buses.reduce(Bus.new(-1, -1, Float::INFINITY)) do |next_bus, bus|
      bus.increment! until bus.next_arrival_at >= earliest_arrival
      [bus, next_bus].max
    end
  end
end

def first_staggered_occurrence
  first_occurence, running_product = 0, 1

  buses.each do |bus|
    first_occurence += running_product until ((first_occurence + bus.index) % bus.id).zero?
    running_product *= bus.id
  end
  first_occurence
end
