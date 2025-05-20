# frozen_string_literal: true

RSpec.describe Exid do
  it "has a version number" do
    expect(Exid::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
