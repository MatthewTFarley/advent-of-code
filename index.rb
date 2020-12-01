# frozen_string_literal: true

require 'thor'

class AdventCLI < Thor
  desc 'solve YEAR DAY ARGS', 'Solve the puzzle for the year and the day with provided args'
  def solve(year, day, *args)
    require_relative("#{year}/#{day}/index")
    p(main(*args))
  end
end

AdventCLI.start(ARGV)
