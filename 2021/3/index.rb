# frozen_string_literal: true

public

def puzzle_one
  power_consumption
end

def puzzle_two
  life_support_rating
end

private

def power_consumption
  num_chars.transpose.each_with_object([[], []]) do |chars, g_e|
    partition_by_zero(chars).then do |zeros, ones|
      g_e.zip(most_least(zeros, ones)).each { |arr, val| arr << val }
    end
  end.then { |g_e| get_rating(*g_e) }
end

def life_support_rating
  get_rating oxy_co2(0), oxy_co2(1)
end

def get_rating(*args)
  args.map { |chars| chars.join.to_i(2) }.reduce(1, &:*)
end

def oxy_co2(type_index)
  num_chars.dup.tap do |kept|
    mld_index = 0
    until kept.length == 1 do
      mld = most_least_digits(kept)
      kept.select! do |num|
        current_keep = mld[mld_index][type_index]
        num[mld_index] == current_keep
      end
      mld_index = mld_index.next
    end
  end
end

def most_least_digits(nums)
  nums.transpose.each.with_object([]) do |chars, mld|
    partition_by_zero(chars).then do |zeros, ones|
      mld << most_least(zeros, ones)
    end
  end
end

ZERO_ONE = ['0', '1'].freeze
ONE_ZERO = ZERO_ONE.reverse.freeze

def most_least(zeros, ones)
  zeros.count > ones.count ? ZERO_ONE : ONE_ZERO
end

def partition_by_zero(chars)
  chars.partition { |char| char.to_i.zero? }
end

def num_chars
  @num_chars ||= input.map { |str| str.split('') }
end

def input
  IO.readlines("#{__dir__}/input.txt", chomp: true)
end
