# frozen_string_literal: true

public

def variant_one
  groups.map(&count_any_unique_yes).sum
end

def variant_two
  groups.map(&count_all_yes).sum
end

private

def groups
  @groups ||= File.open("#{__dir__}/input.txt", &:read).split("\n\n")
end

def count_any_unique_yes
  ->(group) { group.tr("\n", '').split('').uniq.count }
end

def count_all_yes
  ->(group) { group.split("\n").map(&split_chars).reduce(&:&).count }
end

def split_chars
  ->(str) { str.split('') }
end
