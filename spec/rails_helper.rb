# frozen_string_literal: true

require 'active_record'

# Configure in-memory SQLite database
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

# Define a minimal Application class
class DummyApplication < Rails::Application
  config.eager_load = false
  config.active_support.deprecation = :stderr
end

# Initialize the Rails application
Rails.application.initialize! unless Rails.application.initialized?

# Load database schema
ActiveRecord::Schema.define do
  create_table :test_models, force: true do |t|
    t.string :exid
    t.timestamps
  end
end

# Require spec_helper
require_relative 'spec_helper'
