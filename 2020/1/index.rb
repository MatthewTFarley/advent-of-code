# frozen_string_literal: true

public

def main(combo_size = 2)
  File
    .open("#{__dir__}/input.txt", &:readlines)
    .map(&:to_i)
    .combination(combo_size.to_i)
    .detect(&->(combo) { Array(combo).sum.eql?(2020) })
    .reduce(1, :*)
rescue StandardError
  'Could not find a combination that sums to 2020'
end
