# frozen_string_literal: true

public

def variant_one
  require_relative './integer_monkey_patch_1.rb'
  lines.sum { |line| eval(line) }
end

def variant_two
  require_relative './integer_monkey_patch_2.rb'
  lines.sum { |line| eval(line) }
end

def lines
  @lines ||= file.split("\n")
end
