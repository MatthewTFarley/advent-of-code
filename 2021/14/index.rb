# frozen_string_literal: true

public

def puzzle_one
  i = Inserter.new
  4.times do
    pp i.pair_counts
    i.old_insert
    i.insert
  end
  [i.pair_counts, i.template]
  # 10.times { |index| puts "Starting insert #{index}"; i.insert }
  # i.minmax.values.then { |min, max| max - min }
end

def puzzle_two
  # i = Inserter.new
  # 40.times { |index| puts "Starting insert #{index}"; i.insert }
  # i.minmax.values.then { |min, max| max - min }
  i = Inserter.new
  40.times do
    # pp i.pair_counts
    # i.old_insert
    i.insert
  end
  i.pair_counts
end

private

class Inserter
  attr_reader :template, :pairs, :pair_counts

  def initialize
    @template = Input.template
    @pairs = Input.pairs
    @pair_counts = Hash.new(0).tap do |pc|
      template.chars.each_cons(2) do |left, right|
        current_pair = [left, right].join
        pc[current_pair] += 1
      end
    end
  end

  def insert
    self.pair_counts = pairs.each_with_object(pair_counts.dup) do |(pair, target), new_pair_counts|
      match_count = pair_counts[pair]
      # pp [pair, target, match_count]
      # new_pair_counts[pair] = match_count
      if match_count.nonzero?
        new_pair_counts[pair] = 0
        new_left_pair = [pair[0], target].join
        new_right_pair = [target, pair[1]].join
        new_pair_counts[new_left_pair] += match_count
        new_pair_counts[new_right_pair] += match_count
      end
    end
  end

  def old_insert
    self.template = pairs.each_with_object({}) do |(pair, target), new_segments|
      template.chars.each_cons(2).with_index do |(left, right), i|
        if [left, right].join == pair
          new_segments[i] = [left, target, right]
        end
      end
    end.tap do |new_segments|
      new_segments.each do |match_index, match|
        adjacent_left_match = new_segments[match_index - 1]
        if adjacent_left_match
          left, target, right = match
          new_segments[match_index] = [target, right]
        end
      end
    end.sort.to_h.values.join
  end

  def tally
    @tally ||= template.chars.tally.sort_by { |k, v| v }
  end

  def minmax
    [tally.first, tally.last].to_h
  end

  private

  attr_writer :template, :pair_counts
end

module Input
  class << self
    def template
        @@template ||= IO.readlines("#{__dir__}/sample.txt", chomp: true).first
    end

    def pairs
      @@pairs ||=
        IO.read("#{__dir__}/sample.txt")
        .then { |file| file.scan(/(\w\w) -> (\w)/) }
        .each_with_object({}) do |(pair, target), memo|
          memo[pair] = target
        end
    end
  end
end
