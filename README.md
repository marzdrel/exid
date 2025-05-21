# Exid ![CI](https://github.com/marzdrel/exid/actions/workflows/ci.yml/badge.svg)

A Ruby gem for implementing human-friendly, prefixed identifiers for records using Base62-encoded UUIDs.

## Overview

Exid provides helper methods to create external, prefixed identifiers for your records, following the pattern popularized by Stripe's API.

Similar to Stripe's IDs (like `cus_12345` for customers or `prod_67890` for products), Exid generates readable, prefixed identifiers that:

- Are human-friendly and can be safely exposed in URLs
- Contain semantic prefixes that indicate resource type
- Hide internal database IDs
- Maintain global uniqueness
- Are collision-resistant
- Have constant length for a consistent user experience

The core `Exid::Coder.encode` method accepts a string prefix with a UUID and returns an "external ID" composed of the prefix and a zero-padded **Base62-encoded UUID**.

For example:
```
prg, 018977bb-02f0-729c-8c00-2f384eccb763 => prg_02TOxMzOS0VaLzYiS3NPd9
```

### Resources

For more information on this approach:
- [Designing APIs for Humans: Object IDs](https://dev.to/stripe/designing-apis-for-humans-object-ids-3o5a)
- [Prefixed Base62 UUIDv7 Object IDs with Ecto](https://danschultzer.com/posts/prefixed-base62-uuidv7-object-ids-with-ecto)
- [Friendly IDs for Ruby on Rails](https://dev.to/drnic/friendly-ids-for-ruby-on-rails-1c8p)
- [Prefixed IDs](https://github.com/excid3/prefixed_ids)
- [UUID7 Ruby](https://github.com/sprql/uuid7-ruby)
- [Base62 Ruby](https://github.com/steventen/base62-rb)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "exid"
```

Then execute:

```
$ bundle install
```

## Usage

### Basic Setup

Add a UUID or (preferably) UUIDv7 field to your model and include the helper module. Pass a prefix (String) and a field name (Symbol) to the `Exid::Record.new` method:

```ruby
class User < ApplicationRecord
  include Exid::Record.new("user", :uuid)

  # Optional, but recommended: Use the external ID as the primary object identifier
  def to_param = exid_value
end
```

That's all! This adds several helper methods to your model.

### Example

```ruby
# Create a record with a UUID
user = User.create!(uuid: "018977bb-02f0-729c-8c00-2f384eccb763")

# Access the methods
user.exid_value        # => "user_02TOxMzOS0VaLzYiS3NPd9"
user.exid_prefix_name  # => "user"
user.exid_field        # => :uuid
```

The `exid_handle` instance method returns the last 10 characters of the identifier. This is useful for displaying a distinguishing identifier in the UI. When using UUID7, the first few characters derive from timestamps and will be similar for objects created at the same time. You can pass an integer argument to get a specific number of trailing characters.

```ruby
user.exid_handle # => "OBtqZqRhLm"
user.exid_handle(6) # => "ZqRhLm"
```

### Loading Records by External ID

Use the class method `exid_loader` to load a record using its external ID:

```ruby
User.exid_loader("user_02TOxMzOS0VaLzYiS3NPd9")
# Raises ActiveRecord::RecordNotFound if not found
# Raises NoMatchingPatternError if ID format is invalid
```

The `Exid::Record` module also provides global loading methods that mimic Rails `GlobalID` functionality:

```ruby
Exid::Record.fetch!("pref_02WoeojY8dqVYcAhs321rm") # Raises exception if not found
Exid::Record.fetch("pref_02WoeojY8dqVYcAhs321rm")   # Returns nil if not found
```

> **⚠️ Security Warning**: Exercise caution when using global loading methods with user-supplied identifiers, as this could lead to unexpected results or security issues if users substitute identifiers.

**Note**: When using this gem in Rails development mode (with `eager_load` set to `false`), ensure the model class is referenced before calling `.fetch` or `.fetch!`. This ensures the prefix is added to the global registry so the loader can identify which class is associated with the prefix.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).