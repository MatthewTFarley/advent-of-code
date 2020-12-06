# frozen_string_literal: true

public

def main(puzzle_variant = '1')
  File.open("#{__dir__}/input.txt", &:readlines).select do |line|
    num1, num2, char1, char2, target_char, password = destructure(line)

    case puzzle_variant
    when '1' then password.count(target_char).between?(num1, num2)
    when '2' then [char1, char2].one?(target_char)
    end
  end.count
end

def destructure(line)
  num1, num2, target_char, password = line.tr('-:', ' ').split("\s")
  num1, num2 = [num1, num2].map(&:to_i)
  [num1, num2, password[num1 - 1], password[num2 - 1], target_char, password]
end
