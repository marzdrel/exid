# frozen_string_literal: true

# This class gets a string prefix and an UUID and returns an "external ID",
# composed of this prefix and zero-padded Base62-encoded UUID. For example:
# prg, 018977bb-02f0-729c-8c00-2f384eccb763 => prg_02TOxMzOS0VaLzYiS3NPd9

# FIXME: 2025-05-20 - This is not very efficient, as the performance was
# not a concern when this was written. There is lots of string operations
# while encoding/decoding, which could be replaced by number operations.
# At this point it is not worth the effort, as the performance is not
# critical. It can encode around 100k/s and decode 50k/s on my laptop.

# This could be a value objet, which could return various representations,
# including the timestamp, the UUID, the prefix, or the object itself. For now
# this is just a quick experiment to see where we go from here.
#
# See more:
#   - https://dev.to/stripe/designing-apis-for-humans-object-ids-3o5a
#   - https://danschultzer.com/posts/prefixed-base62-uuidv7-object-ids-with-ecto
#   - https://dev.to/drnic/friendly-ids-for-ruby-on-rails-1c8p
#   - https://github.com/excid3/prefixed_ids
#   - https://github.com/sprql/uuid7-ruby
#   - https://github.com/steventen/base62-rb

module Exid
  class DecodeError < StandardError; end

  Result = Data.define(:prefix, :uuid) do
    def deconstruct = [prefix, uuid]
  end

  module Coder
    def self.encode(prefix, uuid)
      [
        prefix.to_s,
        Base62.encode(uuid.delete("-").hex),
      ].join("_")
    end

    def self.decode(eid)
      prefix, base62 = eid.to_s.split("_", 2)

      if prefix.nil? || base62.nil?
        raise DecodeError, "Invalid EID #{eid.inspect}"
      end

      hex = Base62.decode(base62).to_s(16).rjust(32, "0")

      Result.new(
        prefix,
        [hex[0..7], hex[8..11], hex[12..15], hex[16..19], hex[20..31]].join("-"),
      )
    end
  end
end
