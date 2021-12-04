# frozen_string_literal: true

require 'thor'

class AdventCLI < Thor
  desc 'solve YEAR DAY ARGS', 'Solve the puzzle for the year and the day with provided args'
  def solve(year, day, *args)
    require_relative("#{year}/#{day}/index")
    pp(main(*args))
  end

  private

  def main(puzzle_variant = '1')
    case puzzle_variant
    when '1' then variant_one
    when '2' then variant_two
    else raise PuzzleVariantError.new 'Invalid puzzle variant provided. Valid values are "1", and "2"'
    end

  rescue PuzzleVariantError => error
    error
  end
end

class PuzzleVariantError < StandardError; end

AdventCLI.start(ARGV)
