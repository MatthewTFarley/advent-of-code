# frozen_string_literal: true

public

def puzzle_one
  find(:winner)
end

def puzzle_two
  find(:last_place)
end

private

def find(target)
  BingoGame.new(bingo_boards, numbers_to_call)
    .public_send(target)
    .reduce(1, &:*)
end

class BingoGame
  def initialize(bingo_boards, numbers_to_call)
    @bingo_boards = bingo_boards
    @numbers_to_call = numbers_to_call
  end

  def winner
    call_numbers do |board, number|
      if board.winning?
        return [board.unmarked_sum, number]
      end
    end
  end

  def last_place
    call_numbers do |bingo_board, number|
      if non_winning_bingo_boards.empty?
        return [bingo_board.unmarked_sum, number]
      end
    end
  end

  private

  attr_reader :bingo_boards, :numbers_to_call

  def call_numbers
    numbers_to_call.each do |number|
      bingo_boards.each do |bingo_board|
        if bingo_board.has?(number)
          bingo_board.mark(number)
          yield bingo_board, number if block_given?
        end
      end
    end
  end

  def non_winning_bingo_boards
    bingo_boards.reject(&:winning?)
  end
end

class BingoBoard
  attr_reader :board

  def initialize(board)
    @board = board
  end

  def has?(number)
    !marked_lookup[number].nil?
  end

  def mark(number)
    marked_lookup[number] = true
  end

  def unmarked_sum
    marked_lookup.sum { |number, is_marked| is_marked ? 0 : number }
  end

  def winning?
    [winning_row?, winning_column?].any?
  end

  private

  def marked_lookup
    @marked_lookup ||=
      board.each_with_object({}) do |row, lookup|
        row.each { |number| lookup[number] = false }
      end
  end

  def winning_row?
    any_line_marked?(board)
  end

  def winning_column?
    any_line_marked?(board.transpose)
  end

  def any_line_marked?(board)
    0.upto(4).any? { |index| all_marked?(board[index]) }
  end

  def all_marked?(line)
    line.all? { |number| marked?(number) }
  end

  def marked?(number)
    marked_lookup[number]
  end
end

def bingo_boards
  @bingo_boards ||=
    input
    .slice(2..)
    .each_slice(6)
    .map { |row| row.take(5) }
    .map { |row| row.map { |numbers| numbers.split(' ').map(&:to_i) } }
    .map { |board| BingoBoard.new(board) }
end

def numbers_to_call
  @numbers_to_call ||= input.first.split(',').map(&:to_i)
end

def input
  IO.readlines("#{__dir__}/input.txt", chomp: true)
end
