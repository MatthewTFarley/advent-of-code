# frozen_string_literal: true

public

def puzzle_one
  get_count_for(80)
end

def puzzle_two
  get_count_for(256)
end

private

def get_count_for(iterations)
  input
  .tally
  .then { |fish_counts| handle_iteration(fish_counts, iterations) }
  .values
  .sum
end

def handle_iteration(fish_counts, iterations)
  return fish_counts if iterations.zero?

  fish_counts.each_with_object(Hash.new(0)) do |(timer, count), new_fish_counts|
    if timer.zero?
      new_fish_counts[6] += count
      new_fish_counts[8] = count
    else
      new_fish_counts[timer - 1] += count
    end
  end
  .then { |new_fish_counts| handle_iteration(new_fish_counts, iterations - 1) }
end

def input
  IO.readlines("#{__dir__}/input.txt", chomp: true).first.split(',').map(&:to_i)
end
