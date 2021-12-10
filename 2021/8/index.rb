# frozen_string_literal: true

public

def puzzle_one
  signal_decoders.sum do |signal_decoder|
    signal_decoder.display_to_numbers.count do |num|
      [1,4,7,8].include?(num)
    end
  end
end

def puzzle_two
  signal_decoders.sum do |signal_decoder|
    signal_decoder.display_to_numbers.map(&:to_s).join('').to_i
  end
end

private

class SignalDecoder
  SIGNAL_TO_NUMBER = {
    'abcefg' => 0,
    'cf' => 1,
    'acdeg' => 2,
    'acdfg' => 3,
    'bcdf' => 4,
    'abdfg' => 5,
    'abdefg' => 6,
    'acf' => 7,
    'abcdefg' => 8,
    'abcdfg' => 9,
  }.freeze

  def initialize(signals, display)
    @signals = signals
    @display = display
  end

  def display_to_numbers
    corrected_display.map { |d| SIGNAL_TO_NUMBER[d.join] }
  end

  private

  attr_reader :signals, :display

  # For all 10 signals, tally the number of times one of the 7 segments appears
  def segment_occurrences
    @segment_occurrences ||=
      signals.each_with_object(Hash.new(0)) do |signal, memo|
        signal.each { |char| memo[char] += 1 }
      end
  end

  def corrected_segment_map
    @corrected_segment_map ||=
      segment_occurrences.each_with_object({}) do |(segment, count), memo|
        memo[segment] = case count
          when 4 then 'e'
          when 6 then 'b'
          when 9 then 'f'
          when 7
            known_signals[4].include?(segment) ? 'd' : 'g'
          when 8
            [known_signals[7] ,known_signals[1]]
            .reduce(&:-)
            .first == segment ? 'a' : 'c'
        end
      end
  end

  def corrected_display
    @corrected_display ||= display.map do |d|
      d.map { |segment| corrected_segment_map[segment] }.sort
    end
  end

  def known_signals
    @known_signals ||=
      signals.each_with_object({}) do |signal, memo|
        key =
          case signal.length
          when 2 then 1
          when 3 then 7
          when 4 then 4
          when 7 then 8
          end
        memo[key] = signal
      end
  end
end

def signal_decoders
  @signal_decoders ||= input.map do |line|
    SignalDecoder.new(
      *line
      .split(' | ')
      .map do |line_part|
        line_part
        .split(' ')
        .map { |signal| signal.split('').sort }
      end
    )
  end
end

def input
  IO.readlines("#{__dir__}/input.txt", chomp: true)
end
