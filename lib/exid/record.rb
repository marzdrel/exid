module Exid
  class Record < Module
    MUTEX = Mutex.new

    Entry =
      Data.define(:prefix, :field, :klass) do
        def ==(other) = prefix == other.prefix
        def hash = prefix.hash

        alias_method :eql?, :==
      end

    @registered_modules = Set.new

    def included(base)
      base.send(:include, @module_value)
      base.send(:include, @module_shared)
      base.send(:extend, @module_shared)
      base.send(:extend, @module_static)

      self.class.register_module(
        Entry.new(
          prefix: base.prefix_eid_prefix_name,
          field: base.prefix_eid_field,
          klass: base,
        ),
      )
    end

    def initialize(prefix, field)
      raise Error, "Prefix cannot be longer than 4 characters" if prefix.length > 4

      @module_static = build_module_static(prefix, field)
      @module_value = build_module_value(prefix, field)
      @module_shared = build_module_shared(prefix, field)

      super()
    end

    # When app is eager loaded in production, all models are loaded and
    # registered. This logic with delte and readd is for development purpose,
    # to make sure we can make changes to the app and have this logic working
    # at the same time. We only use prefix as identify for the set elements.

    def self.register_module(entry)
      MUTEX.synchronize do
        @registered_modules.delete(entry)
        @registered_modules.add(entry)
      end
    end

    def self.unload
      MUTEX.synchronize do
        @registered_modules = Set.new
      end
    end

    def self.registered_modules
      MUTEX.synchronize do
        @registered_modules.dup
      end
    end

    def self.find_module(prefix)
      registered_modules.detect { it.prefix == prefix } or
        raise Error, "Model for \"#{prefix}\" not found"
    end

    def self.finder(eid)
      Coder.decode(eid) => prefix, value

      mod = find_module(prefix)
      mod.klass.where(mod.field => value)
    end

    def self.fetch(eid) = finder(eid).first
    def self.fetch!(eid) = finder(eid).sole

    private

    def build_module_value(prefix, field)
      Module.new do
        define_method :prefix_eid_value do
          Coder.encode(prefix, send(field))
        end

        # This is used to visually distingquish records on index pages. First
        # bits of UUID7 are date, so they are shared among many records. Using
        # last bytes of encoded of UUID7 is more likely to be unique. This for
        # display only, do not use this to fetch records, etc.

        define_method :prefix_eid_handle do |amount = 10|
          prefix_eid_value.split("_").last[-amount..-1]
        end
      end
    end

    def build_module_shared(prefix, field)
      Module.new do
        define_method :prefix_eid_prefix_name do
          prefix
        end

        define_method :prefix_eid_field do
          field
        end
      end
    end

    def build_module_static(prefix, field)
      Module.new do
        define_method :prefix_eid_loader do |eid|
          Coder.decode(eid) => ^prefix, value
          find_sole_by(field => value)
        end
      end
    end
  end
end
