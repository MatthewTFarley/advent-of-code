# frozen_string_literal: true

require 'set'

public

def puzzle_one
  steps.each do |dir, dist|
    prop, method = case dir
    when 'U'
      ['y', '-']
    when 'R'
      ['x', '+']
    when 'D'
      ['y', '+']
    when 'L'
      ['x', '-']
    else
      raise StandardError
    end

    old = head.send(prop)
    new_head = head.send(prop).send(method, dist)
    behind_new_head = nil

    dist.times do |i|
      head.send(prop + '=', head.send(prop).send(method, 1))
      if i == dist.pred
        behind_new_head = [head.x, head.y]
      end
    end

    head.send(prop + '=', new_head)
    if (tail.x - head.x).abs > 2
      tail.x = behind_new_head.first
    end

    if (tail.y - head.y).abs > 2
      tail.y = behind_new_head.second
    end
    cache.add([tail.x, tail.y])
  end
  pp cache
  cache.size
end

def puzzle_two
end

Coord = Struct.new(:x, :y)

def head
  @head ||= Coord.new(0, 0)
end

def tail
  @tail ||= Coord.new(0, 0)
end

def cache
  @cache ||= Set[[0,0]]
end

def state
  @state ||= {
    head: coord.new(0, 0),
    tail: coord.new(0, 0),
    positions: Set[[0,0]]
  }
end

private

def steps
  @steps ||= input.map { |row| dir, dist = row.split(' '); [dir, dist.to_i] }
end

def input
  @input ||= IO.readlines("#{__dir__}/sample.txt", chomp: true)
end
