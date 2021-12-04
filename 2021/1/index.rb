# frozen_string_literal: true

public

def variant_one
  previous_number = input.first

  input.slice(1..).count do |number|
    (number > previous_number).tap { previous_number = number }
  end
end

def variant_two
  previous_sum = nil
  input.each_index.to_a.count do |starting|
    window = input.slice(starting..starting.next.next)
    next false if window.length != 3

    window_sum = window.sum

    if starting.zero?
      previous_sum = window_sum
      next false
    end

    (window_sum > previous_sum).tap { previous_sum = window_sum }
  end
end

private

def input
  @input ||= IO.readlines("#{__dir__}/input.txt").map(&:to_i)
end
