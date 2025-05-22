# frozen_string_literal: true

require 'rails_helper'
require 'securerandom' # For UUID generation

# Define a minimal ActiveRecord model for testing
class TestModel < ActiveRecord::Base
  # The Exid::Record mixin requires a prefix and the name of the field 
  # that stores the raw ID.
  include Exid::Record.new("test", :exid)

  before_create :generate_exid_if_not_set

  private

  def generate_exid_if_not_set
    self.exid ||= SecureRandom.uuid
  end
end

RSpec.describe Exid::Record, type: :model do
  let(:model) { TestModel.create! } # exid (UUID) will be generated before_create

  describe 'when included in an ActiveRecord model' do
    it 'generates a UUID for the designated field before creation' do
      new_model = TestModel.new
      expect(new_model.exid).to be_nil # Not yet generated
      new_model.save!
      expect(new_model.exid).to be_a(String)
      expect(new_model.exid.length).to eq(36) # Standard UUID length
    end

    it 'provides an exid_value after creation' do
      expect(model.exid_value).to match(/^test_[a-zA-Z0-9]{22}$/)
    end

    it 'saves and retrieves the record, keeping the same exid_value' do
      retrieved_model = TestModel.find(model.id)
      expect(retrieved_model.exid_value).to eq(model.exid_value)
    end

    describe '.exid_loader' do
      it 'can be found by its exid_value using the model-specific loader' do
        found_model = TestModel.exid_loader(model.exid_value)
        expect(found_model).to eq(model)
      end

      it 'raises ActiveRecord::RecordNotFound when not found by exid_value with correct prefix' do
        # Generate a valid exid format but for a non-existent UUID
        non_existent_uuid = SecureRandom.uuid
        non_existent_exid_value = Exid::Coder.encode("test", non_existent_uuid)
        expect {
          TestModel.exid_loader(non_existent_exid_value) 
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises Exid::DecodeError for a malformed exid_value (e.g. wrong prefix structure)' do
        expect {
          TestModel.exid_loader('wrongprefix_and_value') # This format would fail Coder.decode's split
        }.to raise_error(Exid::DecodeError)
      end

      it 'raises RuntimeError for a mismatched prefix after successful decode' do
        # This tests the `^prefix` check in `build_module_static`
        mismatched_exid_value = Exid::Coder.encode("othr", SecureRandom.uuid)
        expect {
          TestModel.exid_loader(mismatched_exid_value)
        }.to raise_error(RuntimeError, /Coder.decode\(eid\) => \^prefix, value failed/)
      end
    end

    describe '#exid_handle' do
      it 'returns the last 10 characters of the encoded part by default' do
        expected_suffix = model.exid_value.split('_').last[-10..]
        expect(model.exid_handle).to eq(expected_suffix)
      end

      it 'returns the last N characters of the encoded part when specified' do
        expected_suffix = model.exid_value.split('_').last[-5..]
        expect(model.exid_handle(5)).to eq(expected_suffix)
      end
    end
  end

  describe 'Exid::Record static methods' do
    # `model` is available here due to `let(:model) { TestModel.create! }`
    # The TestModel class including Exid::Record is defined, so it's registered.

    describe '.fetch' do
      it 'fetches a record by its exid_value' do
        fetched_model = Exid::Record.fetch(model.exid_value)
        expect(fetched_model).to eq(model)
      end

      it 'returns nil if no record matches the exid_value (correct prefix, non-existent id)' do
        non_existent_uuid = SecureRandom.uuid
        non_existent_exid_value = Exid::Coder.encode("test", non_existent_uuid)
        expect(Exid::Record.fetch(non_existent_exid_value)).to be_nil
      end
      
      it 'returns nil if prefix is not registered' do
        expect(Exid::Record.fetch('unknownprefix_somenonsense')).to be_nil
      end

      it 'raises Exid::DecodeError for a malformed exid_value' do
        expect { Exid::Record.fetch('test_malformedvalue!!') }.to raise_error(Exid::DecodeError)
      end
    end

    describe '.fetch!' do
      it 'fetches a record by its exid_value' do
        fetched_model = Exid::Record.fetch!(model.exid_value)
        expect(fetched_model).to eq(model)
      end

      it 'raises ActiveRecord::RecordNotFound if no record matches (correct prefix, non-existent id)' do
        non_existent_uuid = SecureRandom.uuid
        non_existent_exid_value = Exid::Coder.encode("test", non_existent_uuid)
        expect {
          Exid::Record.fetch!(non_existent_exid_value)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
      
      it 'raises Exid::Error if prefix is not registered' do
         expect {
          Exid::Record.fetch!('unknownprefix_somenonsense')
        }.to raise_error(Exid::Error, 'Model for "unknownprefix" not found')
      end

      it 'raises Exid::DecodeError for a malformed exid_value' do
        expect { Exid::Record.fetch!('test_malformedvalue!!') }.to raise_error(Exid::DecodeError)
      end
    end

    describe '.find_module' do
      it 'finds the registered module entry for a known prefix' do
        entry = Exid::Record.find_module("test")
        expect(entry.prefix).to eq("test")
        expect(entry.field).to eq(:exid)
        expect(entry.klass).to eq(TestModel)
      end

      it 'raises Exid::Error for an unknown prefix' do
        expect {
          Exid::Record.find_module("unknown")
        }.to raise_error(Exid::Error, 'Model for "unknown" not found')
      end
    end
  end
end
```
