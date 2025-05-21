# frozen_string_literal: true

require "spec_helper"

module Exid
  RSpec.describe Record do
    after do
      # Record keeps track of all registered modules. In order to properly
      # test the module, we need to clear the registered modules atter each
      # test. Make sure the state does not leak into other tests ouside of this
      # context.

      Record.unload
    end

    it "generates helper methods for a record" do

      stub_const(
        "Klass",
        Class.new do
          include Exid::Record.new("pref", :uuid)

          def uuid = "0196eef2-ba84-7105-bd1a-a36e0eaf1714"
        end,
      )

      model = Klass.new

      expect(model.exid_value)
        .to eq("pref_02ZY58Nm39UWOBtqZqRhLm")

      expect(model.exid_prefix_name)
        .to eq("pref")

      expect(model.exid_field)
        .to eq(:uuid)

      expect(model.exid_handle)
        .to eq("OBtqZqRhLm")
    end

    it "generates a loader method for a record" do
      stub_const(
        "Klass",
        Class.new do
          include Exid::Record.new("pref", :uuid)

          def uuid
            "0196eef2-ba84-7105-bd1a-a36e0eaf1714"
          end

          def self.find_sole_by(_field)
            :record
          end
        end,
      )

      instance = Klass.exid_loader("pref_02WoeojY8dqVYcAhs321rm")

      expect(instance).to eq(:record)
    end

    it "raises on invalid prefix" do
      stub_const(
        "Klass",
        Class.new do
          include Exid::Record.new("pref", :uuid)

          def uuid = "0196eef2-ba84-7105-bd1a-a36e0eaf1714"
        end,
      )

      code = proc do
        Klass.exid_loader("unkn_02WoeojY8dqVYcAhs321rm")
      end

      expect { code.call }
        .to raise_error(NoMatchingPatternError)
    end

    it "adds the model to the register" do
      stub_const(
        "Klass",
        Class.new do
          include Exid::Record.new("pref", :uuid)

          def uuid = "018f1a83-81c3-7d82-9989-cf2cefba6a84"
        end,
      )

      entry =
        described_class
        .registered_modules
        .detect { _1.klass == Klass }

      expect(entry.prefix).to eq("pref")
    end

    describe ".fetch" do
      it "loads the record" do
        stub_const(
          "Klass",
          Class.new do
            include Exid::Record.new("pref", :uuid)

            def uuid = "018f1a83-81c3-7d82-9989-cf2cefba6a84"
          end,
        )

        allow(Klass)
          .to receive(:where)
          .and_return(spy(url: "https://example.com/1234"))

        log = described_class.fetch!("pref_02WoeojY8dqVYcAhs321rm")

        expect(log.url)
          .to eq("https://example.com/1234")
      end

      it "allows failure" do
        stub_const(
          "Klass",
          Class.new do
            include Exid::Record.new("pref", :uuid)

            def self.where(...) = []
          end,
        )

        value = described_class.fetch("pref_02WoeojY8dqVYcAhs321rm")

        expect(value)
          .to be_nil
      end

      it "replaces registered element by prefix" do
        stub_const("KlassA", Class.new)
        stub_const("KlassB", Class.new)

        KlassA.include(described_class.new("test", :field1))
        KlassB.include(described_class.new("test", :field2))

        entries =
          described_class.registered_modules.select do |entry|
            entry.prefix == "test"
          end

        expect(entries.last.field).to eq(:field2)
      end
    end
  end
end
