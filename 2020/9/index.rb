# frozen_string_literal: true

public

def puzzle_one
  XmasDecryption.new.target
end

def puzzle_two
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
