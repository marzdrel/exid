# frozen_string_literal: true

require "spec_helper"

# rubocop:disable Naming/VariableNumber
# rubocop:disable Style/NumericLiterals
module Exid
  RSpec.describe Base62 do
    describe "#encode" do
      it "encodes 128-bit number" do
        base_62 = described_class.encode(340282366920938463463374607431768211455)

        expect(base_62).to eq("7N42dgm5tFLK9N8MT7fHC7")
        expect(base_62.length).to eq 22
      end

      it "encodes 128-bit number with leading zeros" do
        base_62 = described_class.encode(282366920938463463374607431768211455)

        expect(base_62).to eq("00oQRmV6gPS6YogzgNltP9")
        expect(base_62.length).to eq 22
      end
    end

    describe "#decode" do
      it "decodes 128-bit number" do
        number = described_class.decode("7N42dgm5tFLK9N8MT7fHC7")

        expect(number).to eq(340282366920938463463374607431768211455)
      end

      it "decodes 128-bit number with leading zeros" do
        number = described_class.decode("00oQRmV6gPS6YogzgNltP9")

        expect(number).to eq(282366920938463463374607431768211455)
      end
    end
  end
end
# rubocop:enable Naming/VariableNumber
# rubocop:enable Style/NumericLiterals
