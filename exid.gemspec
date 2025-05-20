# frozen_string_literal: true

require_relative "lib/exid/version"

Gem::Specification.new do |spec|
  spec.name = "exid"
  spec.version = Exid::VERSION
  spec.authors = ["John Doe"]
  spec.email = ["test@example.com"]

  spec.summary = "Easy External identifier management for models"
  spec.description = "This is a gem for managing external identifiers in Ruby programs."
  # spec.summary = "TODO: Write a short summary or delete this line."
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/marzdrel/exid"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage

  # spec.metadata["source_code_uri"] = "https://github.com/marzdrel/exid"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "zeitwerk", "~> 2.6"
end
