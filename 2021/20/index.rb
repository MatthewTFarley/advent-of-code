# frozen_string_literal: true

public

def puzzle_one
  light_count(2)
end

def puzzle_two
  light_count(50)
end

private

def light_count(n)
  enhance(n).sum { |row| row.count { |pixel| pixel == '1' } }
end

def enhance(n = 1)
  light_or_dark = '0'

  n.times.reduce(Input.image) do |image, iter|
    new_image = image.map.with_index do |row, y|
      row.map.with_index do |_, x|
        index = ADJACENT.map do |x1, y1|
          # When accessing a pixel outside the represented image
          if (x.zero? && x1.negative?) ||
            (x == row.length - 1 && x1.positive?) ||
            (y.zero? && y1.negative?) ||
            (y == image.length - 1 && y1.positive?)
            light_or_dark
          else # Access the adjacent pixel
            image[y + y1][x + x1]
          end
        end.join.to_i(2)
        Input.algorithm[index]
      end
    end
    new_image.tap do
      # If all dark adjacent pixels convert to a light pixel, and vice versa,
      # then update the current light/dark variable to represent the infinte
      # space pixels switching from light to dark or dark to light.
      if Input.algorithm['000000000'.to_i(2)] === '1' && Input.algorithm['111111111'.to_i(2)] == '0' # 0 and 511
        light_or_dark = INVERT_LIGHT_DARK[light_or_dark]
      end
    end
  end
end

INVERT_LIGHT_DARK = {
  '0' => '1',
  '1' => '0',
}

ADJACENT = [
  [-1, -1], [0, -1], [ 1, -1],
  [-1,  0], [0,  0], [ 1,  0],
  [-1,  1], [0,  1], [ 1,  1],
].freeze

module Input
  class << self
    def algorithm
      @@algorithm ||= IO.readlines("#{__dir__}/input.txt", chomp: true)
        .first.chars.map { |pixel| pixel == '#' ? '1' : '0' }.join
    end

    def image
      @@image ||= IO.read("#{__dir__}/input.txt").split("\n\n").last.split("\n").map do |row|
        row.split('').map { |pixel| pixel == '#' ? '1' : '0' }
      end
    end
  end
end
