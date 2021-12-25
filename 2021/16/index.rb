# frozen_string_literal: true

public

def puzzle_one
  packets.sum(&:version)
end

def puzzle_two
  packet.perform_operation
end

private

def packet
  OperatorPacket.new(Input.bits).decode!
end

def packets
  flatten(packet)
end

def flatten(packet, packets = [])
  packet.sub_packets.flat_map { |sub_packet| flatten(sub_packet, packets) }
  packets.tap { packets << packet }
end

class BasePacket
  HEADER_LENGTH = 6

  attr_reader :bits, :version, :type

  def initialize(bits)
    @bits = bits
    @version = bits[0, 3].to_i(2)
    @type = bits[3, 3].to_i(2)
  end

  def decode!
    tap { sub_packets.map(&:decode!) }
  end
end

class OperatorPacket < BasePacket
  LENGTH_TYPE_ID_INDEX = 6
  CONTENT_START_INDEX = 7
  LENGTH_TYPE_ID_LENGTH = 1

  def perform_operation
    case type
    when 0 then value.sum
    when 1 then value.reduce(1, &:*)
    when 2 then value.min
    when 3 then value.max
    when 5 then value[0] >  value[1] ? 1 : 0
    when 6 then value[0] <  value[1] ? 1 : 0
    when 7 then value[0] == value[1] ? 1 : 0
    else raise StandardError
    end
  end

  def sub_packets
    @sub_packets ||= length_parser.sub_packets
  end

  def length
    HEADER_LENGTH + LENGTH_TYPE_ID_LENGTH + length_bits_length + sub_packets.sum(&:length)
  end

  private

  def length_parser
    @length_parser ||= length_parser_class.new(bit_content)
  end

  def length_parser_class
    LENGTH_PARSER_BY_TYPE[length_type]
  end

  def length_bits_length
    length_parser_class::LENGTH
  end

  def length_type
    @length_type ||= bits[LENGTH_TYPE_ID_INDEX].to_i
  end

  def bit_content
    @bit_content ||= bits[CONTENT_START_INDEX, bits.length - CONTENT_START_INDEX]
  end

  def value
    @value ||= sub_packets.map(&:perform_operation)
  end

  class LengthParser
    HEADER_LENGTH = BasePacket::HEADER_LENGTH

    attr_reader :bits

    def initialize(bits)
      @bits = bits
    end

    protected

    def parse_next_packet(remaining_bits, sub_packets)
      this_packet_bits = literal_type?(remaining_bits) ?
        create_new_literal_packet(remaining_bits, sub_packets) :
        create_new_operator_packet(remaining_bits, sub_packets)

      remaining_bits[this_packet_bits.length, remaining_bits.length - this_packet_bits.length]
    end

    def literal_type?(remaining_bits)
      remaining_bits[3, 3].to_i(2) == 4
    end

    def bits_left?(remaining_bits)
      remaining_bits.chars.any? { |char| char != '0' }
    end

    private

    def create_new_operator_packet(remaining_bits, packets)
      new_packet = OperatorPacket.new(remaining_bits)
      remaining_bits[0, new_packet.length].tap { packets << new_packet }
    end

    def create_new_literal_packet(remaining_bits, packets)
      # slice into substrings of 5 chars
      assumed_packet_length = remaining_bits.length - HEADER_LENGTH
      slices = remaining_bits[HEADER_LENGTH, assumed_packet_length]
        .chars.each_slice(5).map(&:join)
      # take all the slices that have a 1 in the first char position
      # then take the slice after the last 1-slice to get the final 0-slice
      kept_slices = slices
        .take_while { |slice| slice[0] == '1' }
        .tap { |kept| kept << slices[kept.length] }
      packet_length = HEADER_LENGTH + kept_slices.sum(&:length)
      remaining_bits[0, packet_length].tap do |next_packet_bits|
        packets << LiteralPacket.new(next_packet_bits)
      end
    end
  end

  class BitLengthParser < LengthParser
    LENGTH = 15

    def bit_length
      @bit_length ||= bits[0, LENGTH].to_i(2)
    end

    def sub_packet_bits
      @sub_packet_bits ||= bits[LENGTH, bit_length]
    end

    def sub_packets
      [].tap do |sub_packets|
        remaining_bits = sub_packet_bits

        while bits_left?(remaining_bits)
          remaining_bits = parse_next_packet(remaining_bits, sub_packets)
        end
      end
    end
  end

  class PacketLengthParser < LengthParser
    LENGTH = 11

    def packet_count
      @packet_count ||= bits[0, LENGTH].to_i(2)
    end

    def sub_packet_bits
      @sub_packet_bits ||= bits[LENGTH, bits.length - LENGTH]
    end

    def sub_packets
      [].tap do |sub_packets|
        remaining_packet_count = packet_count
        remaining_bits = sub_packet_bits

        while remaining_packet_count.positive?
          remaining_bits = parse_next_packet(remaining_bits, sub_packets)
          remaining_packet_count -= 1
        end
      end
    end
  end

  LENGTH_PARSER_BY_TYPE = {
    0 => BitLengthParser,
    1 => PacketLengthParser,
  }.freeze
end

class LiteralPacket < BasePacket
  def length
    bits.length
  end

  def sub_packets
    []
  end

  def perform_operation
    value
  end

  private

  def value
    @value ||=
      value_bits
      .chars
      .each_slice(5)
      .map(&:join)
      .take_while { |slice| slice.length == 5 }
      .map { |slice| slice[1,4] }
      .join
      .to_i(2)
  end

  def value_bits
    bits[6, bits.length - 6]
  end
end

HEX_TO_BINARY_MAP = {
  '0' => '0000',
  '1' => '0001',
  '2' => '0010',
  '3' => '0011',
  '4' => '0100',
  '5' => '0101',
  '6' => '0110',
  '7' => '0111',
  '8' => '1000',
  '9' => '1001',
  'A' => '1010',
  'B' => '1011',
  'C' => '1100',
  'D' => '1101',
  'E' => '1110',
  'F' => '1111'
}.freeze

module Input
  class << self
    def message
      @@message ||= IO.readlines("#{__dir__}/input.txt", chomp: true).first
    end

    def bits
      @@bits ||= message.chars.map do |char|
        HEX_TO_BINARY_MAP[char]
      end.join
    end
  end
end
