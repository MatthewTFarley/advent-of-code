# frozen_string_literal: true

public

def puzzle_one
  input.each_with_object(Renderer.new) do |line, renderer|
    type, num = line.split(' ')
    if type == 'addx'
      renderer.execute_cycle
      renderer.execute_cycle
      renderer.update_register(num)
    else
      renderer.execute_cycle
    end
  end.signal_sum
end

def puzzle_two
  input.each_with_object(Renderer.new) do |line, renderer|
    type, num = line.split(' ')
    if type == 'addx'
      renderer.render_cycle
      renderer.render_cycle
      renderer.update_register(num)
    else
      renderer.render_cycle
    end
  end
  nil
end

private

class Renderer
  attr_accessor :cycle, :register, :signal_sum

  def initialize
    @cycle = 0
    @register = 1
    @signal_sum = 0
  end

  def is_target_cycle?
    cycle == 20 || ((cycle - 20) % 40).zero?
  end

  def render_pixel
    pixel = should_render_sprite? ? '#' : '.'
    print pixel
  end

  def render_newline_and_reset_cycle
    print "\n"
    self.cycle = 0
  end

  def should_render_sprite?
    (register.pred..register.next).include?(cycle)
  end

  def should_render_newline?
    cycle % 40 == 0
  end

  def update_signal_sum
    self.signal_sum += cycle * register
  end

  def update_register(num)
    self.register += num.to_i
  end

  def execute_cycle
    inc_cycle
    update_signal_sum if is_target_cycle?
  end

  def render_cycle
    render_pixel
    inc_cycle
    render_newline_and_reset_cycle if should_render_newline?
  end

  def inc_cycle
    self.cycle += 1
  end
end

def input
  @input ||= IO.readlines("#{__dir__}/input.txt", chomp: true)
end
