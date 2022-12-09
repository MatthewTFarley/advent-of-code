# frozen_string_literal: true

require 'json'

# 1324537 too low

public

def puzzle_one
  # filesystem
  dirsizes = Hash.new(0)
  cwd = '/'
  prev = '/'
  dir = filesystem[cwd]
  explore_dir(dir, dirsizes, prev)
  # puts JSON.pretty_generate(filesystem)
  pp dirsizes.sort_by { |k, v| v }
  pp dirsizes.values.count { |dirsize| dirsize <= 100000 }
  dirsizes.values.sum { |dirsize| dirsize <= 100000 ? dirsize : 0 }
end

def puzzle_two
end

private

def explore_dir(dir, dirsizes, prev)
  dir.each do |k, v|
    if v.is_a? Hash
      explore_dir(dir[k], dirsizes, k)
      dirsizes[prev] += dirsizes[k]
    else
      dirsizes[prev] += v
    end
  end
end

# def filesystem
#   @filesystem ||= {
#     '/' => {
#       'a' => {
#         'e' => {
#           'i' => 584,
#         },
#         'f' => 29116,
#         'g' => 2557,
#         'h.lst' => 62596,
#       },
#       'd' => {
#         'j' => 4060174,
#         'd.log' => 8033020,
#         'd.ext' => 5626152,
#         'k' => 7214296,
#       },
#       'b.txt' => 14848514,
#       'c.dat' => 8504156,
#     }
#   }
# end

def filesystem
  dirstack = []
  @filesystem ||= {}.tap do |hash|
    input.each_with_index do |line, i|
      parsed = line.split(' ')
      case parsed.first
      when 'dir', /\d+/ then next
      when '$'
        case parsed.second
        when 'cd'
          if parsed.third == '..'
            dirstack.pop
          else
            hash[parsed.third] ||= {}
            dirstack.push(parsed.third)
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
