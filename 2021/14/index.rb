# frozen_string_literal: true

public

def puzzle_one
  difference(10)
end

def puzzle_two
  difference(40)
end

private

def difference(n)
  Inserter.new.then do |i|
    n.times { i.insert! }
    i.letter_counts.values.minmax.then { |min, max| max - min }
  end
end

class Inserter
  attr_reader :template, :pairs, :pair_counts, :first_last

  def initialize
    @template = Input.template
    @pairs = Input.pairs
    @pair_counts =
      template
      .chars
      .each_cons(2)
      .each_with_object(Hash.new(0)) do |(left, right), pc|
        pc[[left, right].join] += 1
      end
    @first_last = [template[0], template[-1]]
  end

  def insert!
    self.pair_counts =
      pairs.each_with_object(pair_counts.dup) do |(pair, target), new_pair_counts|
        match_count = pair_counts[pair]
        if match_count.nonzero?
          new_pair_counts[pair] -= match_count
          left, right = pair.split('')
          [[left, target], [target, right]].each do |l, r|
            new_pair_counts[[l, r].join] += match_count
          end
        end
      end
  end

  def letter_counts
    @letter_counts ||=
      pair_counts
      .each_with_object(Hash.new(0)) do |(pair, count), memo|
        pair.split('').each { |letter| memo[letter] += count }
      end
      .tap { |hash| first_last.each { |letter| hash[letter] += 1 } }
      .tap { |hash| hash.each { |k, v| hash[k] /= 2 } }
  end

  private

  attr_writer :template, :pair_counts
end

module Input
  class << self
    def template
        @@template ||= IO.readlines("#{__dir__}/input.txt", chomp: true).first
    end

    def pairs
      @@pairs ||=
        IO
        .read("#{__dir__}/input.txt")
        .then { |file| file.scan(/(\w\w) -> (\w)/) }
        .each_with_object({}) { |(pair, target), memo| memo[pair] = target }
        .sort_by { |k, v| k }
    end
  end
end
