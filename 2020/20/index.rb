# frozen_string_literal: true

public

def puzzle_one
  ImageAssembler.new(tiles).corner_ids.reduce(1, &:*)
end

# incomplete
def puzzle_two
  ImageAssembler.new(tiles)
    .corresponding_index
    .then do |index|
      match_tally = index
        .keys
        .map(&:first)
        .tally

      {corners: 2, sides: 3, center: 4 }.each_with_object({}) do |(position, adj_sides), hash|
        tiles = match_tally.select { |k, v| v == adj_sides }
        hash[position] = index.select { |s, os| tiles.include? s[0] }
      end
    end
end

private

class ImageAssembler
  attr_reader :tile_index

  def initialize(tiles)
    @tile_index ||= tiles.each_with_object({}) do |tile, hash|
      t = Tile.new(tile.first.first, tile.slice(1..))
      hash[t.id] = t
    end
  end

  def corner_ids
    @corner_ids ||=
      corresponding_index
      .keys
      .map(&:first)
      .tally
      .select { |k, v| v == 2}
      .keys
  end

  def corresponding_index
    @corresponding_index ||=
      tiles.each_with_object({}) do |tile, hash|
        other_tiles = tiles.reject { |t| tile.id == t.id }
        [:top, :right, :bottom, :left].each do |side|
          [*other_tiles, *other_tiles.map(&:flip)].each do |ot|
            tile_side = tile.send(side)
            [:top, :right, :bottom, :left].each do |o_side|
              ot_side = ot.send(o_side)

              if tile_side == ot_side
                hash[[tile.id, side]] = [ot.id, o_side]
              end
            end
          end
        end
      end
  end

  def tiles
    tile_index.values
  end

  def inner_tiles
    tile_index.values.map(&:inner)
  end

  def unique_sides
    @unique_sides ||= tiles.map(&:all_sides).flatten(1).uniq
  end

  def duplicate_sides
    @duplicate_sides ||= sides_tally.select { |side, count| count > 1  }.map(&:first)
  end

  def sides_tally
    @sides_tally ||= tiles.map(&:all_sides).flatten(1).tally
  end
end

class Tile
  attr_reader :id, :tile

  def initialize(id, tile)
    @id = id
    @tile = tile
  end

  def all_sides
    [sides, flipped_sides].flatten(1)
  end

  def top
    tile.first
  end

  def right
    tile.map(&:last)
  end

  def bottom
    tile.last
  end

  def left
    tile.map(&:first)
  end

  def inner
    tile.slice(1..8).map do |rows|
      rows.slice(1..8)
    end
  end

  def sides
    top = tile.first
    right = tile.map(&:last)
    bottom = tile.last
    left = tile.map(&:first)
    [top, right, bottom, left]
  end

  def flipped_sides
    sides.map(&:reverse)
  end

  def rotate
    Tile.new(id, tile.transpose.map(&:reverse))
  end

  def rotate!
    tile.transpose!
  end

  def flip
    Tile.new(id, tile.transpose.map(&:reverse).transpose.map(&:reverse))
  end

  def flip!
    tile.rotate!.map!(&:reverse)
  end
end

def tiles
  @tiles ||=
    input
    .each_slice(12)
    .map { |tile| tile.take(11) }
    .map do |tile|
      tile.map.with_index { |row, i| i == 0 ? row.scan(/\d+/).map(&:to_i) : row.split('') }
    end
end

def input
  @input ||= IO.readlines("#{__dir__}/input.txt", chomp: true)
end
