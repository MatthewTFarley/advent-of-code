# frozen_string_literal: true

public

def main(puzzle_variant = '1', i = '')
  case puzzle_variant
  when '1' then variant_one(i)
  when '2' then variant_two(i)
  else raise PuzzleVariantError.new 'Invalid puzzle variant provided. Valid values are "1", and "2"'
  end

rescue PuzzleVariantError => error
  error
end

def variant_one(i)
  lines(i).sum { |line| evaluate(line) }
end

def variant_two(i)
  lines_alt(i).sum { |line| eval(line.join) }
end

private

def evaluate(line, depth = 0)
  cursor = 0
  a = b = operation = nil

  while cursor < line.length
    token = line[cursor]
    log("cursor: #{cursor}, token: #{token}, line #{line.join}, a: #{a}, op: #{operation}, b: #{b}", depth)
    case token
    when /\d+/
      if a.nil?
        a = token
      else
        b = token
      end
    when OPERATIONS
      operation = token
    when '('
      sublist = sublist_for(line[cursor..])
      sub_result = evaluate(sublist, depth.next)
      line_before = cursor.pred < 0 ? [] : line[0..cursor.pred]
      line_after = line[cursor + (sublist.length + 2)..-1]
      new_line = [*line_before, sub_result, *line_after]
      line = new_line

      if a.nil?
        a = sub_result
      else
        b = sub_result
      end
    end


    if a && b && operation
      a = a.to_i.public_send(operation, b.to_i)
      b = nil
    end


    cursor = cursor.next
  end

  if a && b && operation
    a.to_i.public_send(operation, b.to_i)
  end
  a
end

def file(i)
  @file ||= File.read("#{__dir__}/input#{i}.txt").gsub('(', '( ').gsub(')', ' )')
end

def file_alt(i)
  @file_alt ||= File.read("#{__dir__}/input#{i}.txt").gsub('(', '( ').gsub(')', ' )').gsub('+', '/').gsub('*', '-')
end

def lines(i)
  @lines ||= file(i).split("\n").map { |line| line.split(' ') }
end

def lines_alt(i)
  @lines ||= file_alt(i).split("\n").map { |line| line.split(' ') }
end

def sublist_for(list)
  sublist = []
  paren_count = 0

  list.each do |char|
    case char
    when '('
      sublist << char if paren_count.positive?
      paren_count = paren_count.next
    when ')'
      sublist << char
      paren_count = paren_count.pred
      return sublist[0..-2] if paren_count == 0
    else sublist << char
    end
  end
end

def log(message, depth = 0, log_depth = 1)
  return
  if log_depth
    if depth == log_depth
      pp message
    end
  else
    pp "#{'    ' * depth}#{message}"
  end
end

class Integer
  def /(other)
    self + other
  end

  def -(other)
    self * other
  end
end

OPERATIONS = /[+*]/

class PuzzleVariantError < StandardError; end
