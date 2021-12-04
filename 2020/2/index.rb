# frozen_string_literal: true

public

def puzzle_one
  destructured_lines.count do |(num1, num2, char1, char2, target_char, password)|
    password.count(target_char).between?(num1, num2)
  end
end

def puzzle_two
  destructured_lines.count do |(num1, num2, char1, char2, target_char, password)|
    [char1, char2].one?(target_char)
  end
end

def destructure(line)
  num1, num2, target_char, password = line.tr('-:', ' ').split("\s")
  num1, num2 = [num1, num2].map(&:to_i)
  [num1, num2, password[num1 - 1], password[num2 - 1], target_char, password]
end

def destructured_lines
  @destructured_lines ||= input.map { |line| destructure(line) }
end

def input
  @input ||= File.open("#{__dir__}/input.txt", &:readlines)
end
