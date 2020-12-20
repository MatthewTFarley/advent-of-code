# frozen_string_literal: trueclass Integer

public

class Integer
  def /(other)
    self + other
  end
end

private

def file
  @file ||= File.read("#{__dir__}/input.txt").gsub('+', '/')
end
