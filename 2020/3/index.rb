# frozen_string_literal: true

public

def main
  lines.slice(1..).each.with_index(1) do |line, line_number|
    slopes_to_tree_counts.each do |slope, tree_count|
      rise, run = slope
      next if (line_number % rise).nonzero?

      extended_line = extend_line(rise, run, line.strip, line_number)
      coord = (line_number / rise) * run
      slopes_to_tree_counts[slope] = tree_count.next if extended_line[coord] == '#'
    end
  end

  slopes_to_tree_counts.values.reduce(1, :*)
end

private

def lines
  @lines ||= File.open("#{__dir__}/input.txt", &:readlines)
end

def extend_line(rise, run, line, line_number)
  line_extension_factor = (line_number / rise.to_f).ceil * (line.length / run.to_f).ceil
  line * line_extension_factor
end

def slopes_to_tree_counts
  @slopes_to_tree_counts ||= {
    [1, 1] => 0,
    [1, 3] => 0,
    [1, 5] => 0,
    [1, 7] => 0,
    [2, 1] => 0
  }
end
