# frozen_string_literal: true

public

def variant_one
  invalid = []
  other.each do |ticket|
    ticket.each do |field|
      any = rules.any? do |name, ranges|
        a_start, a_end, b_start, b_end = ranges
        valid = field.between?(a_start, a_end) || field.between?(b_start, b_end)
        field.between?(a_start, a_end) || field.between?(b_start, b_end)
      end
      invalid << field unless any
    end
  end
  invalid.sum
end

def variant_two
  invalid_indexes = []

  other.each_with_index do |ticket, i|
    ticket.each do |field|
      any = rules.any? do |name, ranges|
        a_start, a_end, b_start, b_end = ranges
        valid = field.between?(a_start, a_end) || field.between?(b_start, b_end)
      end

      invalid_indexes << i unless any
    end
  end

  valid_tickets = [*other, my].reject.with_index { |_, i| invalid_indexes.include? i }
  invalids = {}
  valid_tickets.each do |ticket|
    ticket.each_with_index do |field, i|
      rules.each do |name, ranges|
        a_start, a_end, b_start, b_end = ranges
        valid = field.between?(a_start, a_end) || field.between?(b_start, b_end)
        unless valid
          invalids[name] ||= []
          invalids[name] << i
        end
      end
    end
  end

  possible_indices = (0...my.length).to_a

  valids = invalids.each_with_object({}) { |(name, indices), memo| memo[name] = possible_indices - indices }
  determined_indices = []
  index_lookup = {}

  until determined_indices.length == my.length - 1 do
    valids.each do |k,v|
      unrecorded_determined_indices = v - determined_indices
      if unrecorded_determined_indices.count == 1
        determined_indices = determined_indices | unrecorded_determined_indices
        index_lookup[k] = unrecorded_determined_indices.first
      end

    end
  end

  index_lookup[(rules.keys - index_lookup.keys).first] = possible_indices.sum - index_lookup.values.sum
  rules.filter_map { |(name)| my[index_lookup[name]] if /^departure/.match? name }.reduce(1, :*)
end

private

def text
  @text ||= File.read("#{__dir__}/input.txt").gsub("your ticket:\n", '').gsub("nearby tickets:\n", '')
end

def sections
  @sections ||= text.split("\n\n").map { |section| section.split("\n") }
end

def rules
  @rules ||= sections.first.each_with_object({}) do |line, memo|
    field = line.split(': ').first
    memo[field] = /(\d+)-(\d+) or (\d+)-(\d+)/.match(line)[1..].map(&:to_i)
  end
end

def my
  @my ||= sections[1].first.split(',').map(&:to_i)
end

def other
  @other ||= sections[2].map { |line| line.split(',').map(&:to_i) }
end
