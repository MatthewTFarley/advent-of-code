# frozen_string_literal: true

public

class Integer
  def /(other)
    self + other
  end

  def -(other)
    self * other
  end
end

private

def file
  @file ||= File.read("#{__dir__}/input.txt").gsub('+', '/').gsub('*', '-')
end
