# frozen_string_literal: true

require "spec_helper"

module Exid
  RSpec.describe Coder do
    describe ".encode" do
      it "encodes EID" do
        eid =
          described_class
            .encode("vhr", "018977bb-02f0-729c-8c00-2f384eccb763")

        expect(eid)
          .to eq "vhr_02TOxMzOS0VaLzYiS3NPd9"
      end
    end

    describe ".decode" do
      context "with valid data" do
        it "decodes EID" do
          values = described_class.decode("vhr_02TOxMzOS0VaLzYiS3NPd9")

          expect(values.prefix).to eq "vhr"
          expect(values.uuid).to eq "018977bb-02f0-729c-8c00-2f384eccb763"
        end
      end

      context "with invalid data: string" do
        it "raises an error" do
          expect { described_class.decode("error") }
            .to raise_error %(Invalid EID "error")
        end
      end

      context "with invalid data: empty" do
        it "raises an error" do
          expect { described_class.decode("") }
            .to raise_error %(Invalid EID "")
        end
      end

      context "with invalid data: nil" do
        it "raises an error" do
          expect { described_class.decode(nil) }
            .to raise_error "Invalid EID nil"
        end
      end
    end
  end
end
