# Exid

**!! Warning: Documentation is not complete yet. Work in progress**

This gem offers helper methods for implementing external, prefixed identifiers for records. Core `Exid::Coder.encode` method accepts a string prefix with a UUID and 
returns an "external ID," composed of prefix and a zero-padded **Base62-encoded UUID**.

For example: `prg, 018977bb-02f0-729c-8c00-2f384eccb763` => `prg_02TOxMzOS0VaLzYiS3NPd9`

See more:
  - https://dev.to/stripe/designing-apis-for-humans-object-ids-3o5a
  - https://danschultzer.com/posts/prefixed-base62-uuidv7-object-ids-with-ecto
  - https://dev.to/drnic/friendly-ids-for-ruby-on-rails-1c8p
  - https://github.com/excid3/prefixed_ids
  - https://github.com/sprql/uuid7-ruby
  - https://github.com/steventen/base62-rb

## Usage

Add a UUID or (preferably) UUIDv7 field to your model and include a helper module. Pass a
prefix (String) and a field name (Symbol) to the `Exid::Record.new` method.

```ruby
class User < ApplicationRecord
  include Exid::Record.new("user", :uuid)

  # Optional, but recommended. Use the external ID value as the primary object
  # identier.

  def to_param = exid_value
end
```
That's all. This will add certain class and instance methods to your models / classes.

```ruby
user = User.create!(uuid: "018977bb-02f0-729c-8c00-2f384eccb763")
```
Following methods are now available on the instance class.

```ruby
user.exid_value # => "user_02TOxMzOS0VaLzYiS3NPd9"
user.exid_prefix_name # => "user"
user.exid_field # => :uuid
```

The `exid_handle` instance method simply returns last 10 characters of
identifier. This might be useful for displaying in the UI as distinguishing
identifier.  If the UUID7 is used as the identifier, the first few characters
are not random. They come from the timestamp, so they will be the same for most
objects created at the same time. Pass integer as the argument to get the last
N characters.

```ruby
user.exid_handle # => "OBtqZqRhLm"
user.exid_handle(6) # => "ZqRhLm"
```

Use the class method `exid_loader`, for example `User.exid_loader`, to load the record
using external ID. This method will raise `ActiveRecord::RecordNotFound` if the record
not found. Warning: The method will raise `NoMatchingPatternError` if the provided
identifier is not valid.

The `Exid::Record` also offers couple of class methods designed load
records. This is another way to mimic Rails `GlobalID`. Warning: Steer
away from using this as default way to load records using user supplied
identifiers. User might replace the identifier with other record which might
lead to unexpected results and security issues.

The `fetch` class method will return the record or nil if not found. The
`fetch!` variant will use Rails 7.1+ `sole` under the hood and raise an
exception if the record is not found (or if more than one record is found).

```ruby
Exid::Record.fetch!("pref_02WoeojY8dqVYcAhs321rm")
Exid::Record.fetch("pref_02WoeojY8dqVYcAhs321rm")
```

Note: When using this gem in Rails with Development (with `eager_load` set to `false`), the
class has to be referenced before calling `.fetch` or `.fetch!`. Prefix needs to be
added to the global registry, so the loader can identify which class is tied to
the prefix.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
