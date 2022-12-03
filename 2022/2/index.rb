# frozen_string_literal: true

public

def puzzle_one
  symbol_pairs.sum do |symbol_pair|
    round_result(*symbol_pair).player_two.round_score
  end
end

def puzzle_two
  target_result_pairs.sum do |symbol_pair|
    round_result(*symbol_pair).player_two.round_score
  end
end

private

SYMBOL_TO_NAME = {
  'A' => 'rock',
  'B' => 'paper',
  'C' => 'scissors',
}.freeze

SYMBOL_CONVERT = {
  'X' => 'A',
  'Y' => 'B',
  'Z' => 'C',
}.freeze

TARGET_RESULT_SYMBOL_TO_NAME = {
  'X' => 'lose',
  'Y' => 'draw',
  'Z' => 'win',
}

SELECTION_VALUE = {
  'rock' => 1,
  'paper' => 2,
  'scissors' => 3,
}.freeze

RESULT = {
  'rock' => {
    'rock' => 3,
    'paper' => 0,
    'scissors' => 6,
  }.freeze,
  'paper' => {
    'rock' => 6,
    'paper' => 3,
    'scissors' => 0,
  }.freeze,
  'scissors' => {
    'rock' => 0,
    'paper' => 6,
    'scissors' => 3,
  }.freeze,
}.freeze

TARGET_RESULT = {
  'rock' => {
    'lose' => 'scissors',
    'draw' => 'rock',
    'win' => 'paper',
  }.freeze,
  'paper' => {
    'lose' => 'rock',
    'draw' => 'paper',
    'win' => 'scissors',
  }.freeze,
  'scissors' => {
    'lose' => 'paper',
    'draw' => 'scissors',
    'win' => 'rock',
  }.freeze,
}.freeze

RoundResult = Struct.new(:player_one, :player_two)
PlayerResult = Struct.new(:result_value, :selection_value) do
  def round_score
    result_value + selection_value
  end
end

def round_result(symbolA, symbolB)
  RoundResult.new(
    player_result(symbolA, symbolB),
    player_result(symbolB, symbolA)
  )
end

def player_result(symbolA, symbolB)
  PlayerResult.new(
    RESULT[symbolA][symbolB],
    SELECTION_VALUE[symbolA],
  )
end

def symbol_pairs
  format_input do |line|
    line.split(' ').map do |letter|
      SYMBOL_TO_NAME[SYMBOL_CONVERT[letter] || letter]
    end
  end
end

def target_result_pairs
  format_input do |line|
    line.split(' ').then do |(symbolA, symbolB)|
      a = SYMBOL_TO_NAME[symbolA]
      [
        a,
        TARGET_RESULT[a][TARGET_RESULT_SYMBOL_TO_NAME[symbolB]]
      ]
    end
  end
end

def format_input
  input.map { |line| yield line }
end

def input
  IO.readlines("#{__dir__}/input.txt", chomp: true)
end
