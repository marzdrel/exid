# frozen_string_literal: true

require_relative "exid/version"

module Exid
  class Error < StandardError; end
end

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.eager_load
