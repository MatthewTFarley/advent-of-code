# frozen_string_literal: true

public

def main(puzzle_variant = '1')
  case puzzle_variant
  when '1' then variant_one
  when '2' then variant_two
  else raise PuzzleVariantError.new 'Invalid puzzle variant provided. Valid values are "1", and "2"'
  end

rescue PuzzleVariantError, DecryptionError => error
  error
end

def variant_one
  XmasDecryption.new.target
end

def variant_two
  XmasDecryption.new.decrypt

end

private

class XmasDecryption
  OFFSET = 25

  def decrypt
    for starting in 0..input.length - 2 do
      for ending in starting + 1..input.length.pred do
        numbers = input[starting..ending]
        return numbers.min + numbers.max if numbers.sum == target
      end
    end

    raise DecryptionError.new "Unable to decrypt."
  end

  def target
    @target ||=
      input[offset..].find.with_index(offset) do |num, index|
        input[index - offset...index].combination(2).map(&:sum).none? { |sum| sum == num }
      end
  end

  private

  def offset
    OFFSET
  end

  def input
    @input ||= IO.readlines("#{__dir__}/input.txt").map(&:to_i)
  end
end

class DecryptionError < StandardError; end
class PuzzleVariantError < StandardError; end
