# frozen_string_literal: true

module Exid
  class Base62
    class DecodeError < Error; end

    CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    BASE = CHARS.length
    CHARS_HASH = CHARS.each_char.zip(0...BASE).to_h
    MAX_LENGTH = 22

    def self.encode(num)
      result =
        (1..).reduce("") do |acc, _|
          break acc unless num.positive?

          num, remainder = num.divmod(BASE)
          CHARS[remainder] + acc
        end

      result.rjust(MAX_LENGTH, "0")
    end

    def self.decode(str)
      max = str.length - 1
      str.each_char.zip(0..max).reduce(0) do |acc, (char, index)|
        character = CHARS_HASH[char]

        if character.nil?
          raise DecodeError, "Invalid character '#{char}' in string '#{str}'"
        end

        acc + (character * (BASE**(max - index)))
      end
    end
  end
end
