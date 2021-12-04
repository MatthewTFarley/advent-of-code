# frozen_string_literal: true

require 'thor'

class AdventCLI < Thor
  desc 'solve YEAR DAY ARGS', 'Solve the puzzle for the year and the day with provided args'
  def solve(year, day, *args)
    require_relative("#{year}/#{day}/index")
    pp(main(*args))
  end

  private

  def main(puzzle = '1')
    case puzzle
    when '1' then puzzle_one
    when '2' then puzzle_two
    else raise PuzzleError.new 'Invalid puzzle provided. Valid values are "1", and "2"'
    end

  rescue PuzzleError => error
    error
  end
end

class PuzzleError < StandardError; end

AdventCLI.start(ARGV)
