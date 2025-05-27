# frozen_string_literal: true

require "spec_helper"

module Exid
  RSpec.describe Error do
    it "is an error" do
      expect(described_class).to be < StandardError
    end
  end
end
