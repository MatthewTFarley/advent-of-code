# frozen_string_literal: true

public

def main
  File
    .open("#{__dir__}/input.txt", &:read)
    .split("\n\n")
    .each_with_object({ count: 0 }) do |passport, memo|
      fields = passport.split("\s").map { |field| field.split(':') }.to_h
      required_fields = fields.reject { |field,| field == 'cid' }
      next if !required_fields.count == 7
      next if !byr_valid?(required_fields['byr'])
      next if !ecl_valid?(required_fields['ecl'])
      next if !eyr_valid?(required_fields['eyr'])
      next if !hgt_valid?(required_fields['hgt'])
      next if !hcl_valid?(required_fields['hcl'])
      next if !iyr_valid?(required_fields['iyr'])
      next if !pid_valid?(required_fields['pid'])
      memo[:count] = memo[:count].next
    end[:count]
end

private

def byr_valid?(byr)
  byr.to_i.between? 1920, 2002
end

def ecl_valid?(ecl)
  %w(amb blu brn gry grn hzl oth).include? ecl
end

def eyr_valid?(eyr)
  eyr.to_i.between? 2020, 2030
end

def hgt_valid?(hgt)
  return false if hgt.nil?

  value, unit = [hgt[0..-2].to_i, hgt[-2..-1]]

  case unit
  when 'cm' then value.between? 150, 193
  when 'in' then value.between? 59, 76
  else false
  end
end

def hcl_valid?(hcl)
  /^#[0-9a-f]{6}$/.match hcl
end

def iyr_valid?(iyr)
  iyr.to_i.between? 2010, 2020
end

def pid_valid?(pid)
  /^[\d]{9}$/.match pid
end
