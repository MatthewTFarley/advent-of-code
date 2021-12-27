# frozen_string_literal: true

public

def puzzle_one
  play_game.then { |game| game.loser.points * game.die.times_rolled }
end

def puzzle_two
end

private

def play_game
  Game.new(
    Gameboard.new,
    DeterministicDie.new,
    Player.new(one),
    Player.new(two)
  ).tap { |game| game.play_turn! until game.winner? }
end

def one
  Input.starting.first
end

def two
  Input.starting.last
end

class DeterministicDie
  attr_accessor :number, :times_rolled

  def initialize(number = 0)
    @number = number
    @times_rolled = 0
  end

  def roll!
    self.number = number == 100 ? 1 : number.next
    self.times_rolled += 1
  end
end

class Game
  WINNING_SCORE = 1000

  attr_reader :board, :die, :player_one, :player_two
  attr_accessor :player_to_move

  def initialize(board, die, player_one, player_two, player_to_move = player_one)
    @board = board
    @die = die
    @player_one = player_one
    @player_two = player_two
    @player_to_move = player_to_move
  end

  def play_turn!
    3.times { die.roll!.times { move! } }
    score_points!
    switch_player_to_move!
  end

  def winner?
    !winner.nil?
  end

  def winner
    [player_one, player_two].detect { |player| player.points >= WINNING_SCORE }
  end

  def loser
    [player_one, player_two].detect { |player| player != winner }
  end

  private

  def move!
    player_to_move.space = board.next(player_to_move.space)
  end

  def score_points!
    player_to_move.score_points!
  end

  def switch_player_to_move!
    self.player_to_move = player_to_wait
  end

  def player_to_wait
    [player_one, player_two].find { |player| player != player_to_move }
  end
end

class Gameboard
  def next(space)
    space == 10 ? 1 : space.next
  end
end

class Player
  attr_accessor :points, :space

  def initialize(space)
    @points = 0
    @space = space
  end

  def score_points!
    self.points += space
  end
end

module Input
  class << self
    def starting
      @@starting ||= IO
        .readlines("#{__dir__}/sample.txt", chomp: true)
        .flat_map { |line| line.scan(/Player \d starting position: (\d+)/).first }
        .map(&:to_i)
    end
  end
end
