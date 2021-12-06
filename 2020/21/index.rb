# frozen_string_literal: true

public

def puzzle_one
  ingredient_finder.possible_ingredient_lookup
end

def puzzle_two
end

private

class IngredientFinder
  require 'set'

  attr_reader :ingredient_lists

  def initialize(ingredient_lists)
    @ingredient_lists = ingredient_lists
  end

  def possible_allergy_lookup
    @possible_allergy_lookup ||=
      ingredient_lists.each_with_object(Hash.new) do |list, lookup|
        list.ingredients.each do |i|
          lookup[i] ||= []
          lookup[i] = [*lookup[i], *list.allergies]
        end
      end.each_with_object({}) { |(k, v), lookup| lookup[k] = v.tally }
  end

  def possible_ingredient_lookup
    @possible_ingredient_lookup ||=
      ingredient_lists.each_with_object(Hash.new) do |list, lookup|
        list.allergies.each do |i|
          lookup[i] ||= []
          lookup[i] = [*lookup[i], *list.ingredients]
        end
      end.each_with_object({}) { |(k, v), lookup| lookup[k] = v.tally }
  end

  def distinct_allergies
    @distinct_allergies ||= ingredient_lists.each_with_object(Set.new) do |list, set|
      set.merge(list.allergies)
    end.to_a
  end

  def distinct_ingredients
    @distinct_ingredients ||= ingredient_lists.each_with_object(Set.new) do |list, set|
      set.merge(list.ingredients)
    end.to_a
  end
end

class IngredientList
  attr_reader :allergies, :ingredients

  def initialize(allergies, ingredients)
    @allergies = allergies
    @ingredients = ingredients
  end
end

def ingredient_finder
  @ingredient_finder ||= IngredientFinder.new(ingredient_lists)
end

def ingredient_lists
  @ingredient_lists ||=
    input
    .map { |line| line.split(' (') }
    .map do |(ing, all)|
      allergies = all.slice((all.index(' ') + 1)..(all.length - 2)).split(', ')
      ingredients = ing.split(' ')
      IngredientList.new(allergies, ingredients)
    end
end

def input
  IO.readlines("#{__dir__}/sample.txt", chomp: true)
end
