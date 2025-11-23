# frozen_string_literal: true

require "spec_helper"

module Exid
  RSpec.describe Configuration do
    around do |example|
      Exid.reset_configuration!

      example.run

      Exid.reset_configuration!
      Record.unload
    end

    describe "default configuration" do
      it "validates prefix length by default" do
        expect { Exid.configuration.validate_prefix("toolong") }
          .to raise_error(Error, "Prefix validation failed for: toolong")
      end

      it "allows prefixes within default length" do
        expect { Exid.configuration.validate_prefix("pref") }
          .not_to raise_error
      end
    end

    describe "configuring custom prefix_validator" do
      it "uses custom validator returning true when valid" do
        Exid.configure do |config|
          config.prefix_validator = ->(prefix) { prefix.match?(/\A[a-z]{2,4}\z/) }
        end

        expect { Exid.configuration.validate_prefix("test") }
          .not_to raise_error
      end

      it "raises error when custom validator returns false" do
        Exid.configure do |config|
          config.prefix_validator = ->(prefix) { prefix.match?(/\A[a-z]{2,4}\z/) }
        end

        expect { Exid.configuration.validate_prefix("TEST") }
          .to raise_error(Error, "Prefix validation failed for: TEST")
      end

      it "allows longer prefixes when validator returns true" do
        Exid.configure do |config|
          config.prefix_validator = ->(prefix) { prefix.length <= 10 }
        end

        expect { Exid.configuration.validate_prefix("verylongprefix") }
          .to raise_error(Error, "Prefix validation failed for: verylongprefix")

        expect { Exid.configuration.validate_prefix("shortone") }
          .not_to raise_error
      end

      it "uses custom validator in Record validation" do
        Exid.configure do |config|
          config.prefix_validator = ->(prefix) { %w[usr org].include?(prefix) }
        end

        expect {
          stub_const(
            "Klass",
            Class.new do
              include Exid::Record.new("usr", :uuid)
            end
          )
        }.not_to raise_error

        expect {
          stub_const(
            "BadKlass",
            Class.new do
              include Exid::Record.new("bad", :uuid)
            end
          )
        }.to raise_error(Error, "Prefix validation failed for: bad")
      end

      it "supports complex validation logic" do
        Exid.configure do |config|
          config.prefix_validator = lambda do |prefix|
            prefix.match?(/\A[a-z]+\z/) && prefix.length.between?(2, 6)
          end
        end

        expect { Exid.configuration.validate_prefix("valid") }
          .not_to raise_error

        expect { Exid.configuration.validate_prefix("a") }
          .to raise_error(Error, "Prefix validation failed for: a")

        expect { Exid.configuration.validate_prefix("toolong") }
          .to raise_error(Error, "Prefix validation failed for: toolong")
      end
    end

    describe ".configure" do
      it "yields the configuration object" do
        expect { |b| Exid.configure(&b) }
          .to yield_with_args(Exid.configuration)
      end

      it "allows setting validator" do
        Exid.configure do |config|
          config.prefix_validator = ->(prefix) { prefix.length <= 5 }
        end

        expect(Exid.configuration.prefix_validator).not_to be_nil
      end
    end
  end
end
