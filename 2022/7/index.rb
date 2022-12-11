# frozen_string_literal: true

require 'json'

# 1324537 too low

public

def puzzle_one
  explore_dir.values.sum do |dirsize|
    dirsize <= 100000 ? dirsize : 0
  end
end

def puzzle_two
end

private

def explore_dir(parent = '/', current = filesystem['/'], dirsizes = Hash.new(0))
  dirsizes.tap do
    current.each do |item_name, item_value|
      dirsizes[parent] +=
        if item_value.is_a?(Hash)
          explore_dir(item_name, item_value, dirsizes)
          dirsizes[item_name]
        else
          item_value
        end
    end
  end
end

def filesystem
  dirstack = []
  @filesystem ||= {}.tap do |hash|
    input.each_with_index do |line, i|
      parsed = line.split(' ')
      case parsed.first
      when 'dir', /\d+/ then next
      when '$'
        command = parsed.second
        case command
        when 'cd'
          dir = parsed.third
          if dir == '..'
            dirstack.pop
          else
            dirstack.push(dir)
            dirstack.reduce(hash) { |h, d| h[d] ||= {}; h[d] }
          end
        when 'ls'
          cwd = dirstack.last
          contents = input[i.next..].take_while { |line| line[0] != '$' }
          contents.each do |content|
            size_or_dir, name = content.split(' ')
            if size_or_dir === 'dir'
              hash.dig(*dirstack)[name] ||= {}
            else
              hash.dig(*dirstack)[name] ||= size_or_dir.to_i
            end
          end
        end
      end
    end
  end
end

def input
  @input ||= IO.readlines("#{__dir__}/input.txt", chomp: true)
end
