# frozen_string_literal: true

module Exid
  class Configuration
    attr_accessor :prefix_validator

    def initialize
      @prefix_validator = default_validator
    end

    def validate_prefix(prefix)
      return if prefix_validator.call(prefix)

      raise Error, "Prefix validation failed for: #{prefix}"
    end

    private

    def default_validator
      proc { it.length <= 4 }
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @_configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
