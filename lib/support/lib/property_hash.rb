# frozen_string_literal: true

module Support
  # Extracted from an in-progress gem.
  class PropertyHash
    include Dry::Core::Equalizer.new(:inner)
    include Enumerable

    KEY_PATH = /\A[^.]+(?:\.[^.]+)+\z/
    DOT_PATH = /\./
    SINGLE_PATH = /\A[^.]+\z/
    DELETE = Object.new.freeze

    delegate :size, :length, to: :@inner

    # @return [<String>]
    attr_reader :paths

    def initialize(base_hash = {})
      @inner = {}

      @path_hash = {}.freeze

      @paths = [].freeze

      @batching = false

      with_batch do
        Hash(base_hash).deep_stringify_keys.each do |key, value|
          self[key] = value
        end
      end

      derive_paths!
    end

    def [](path)
      case path
      when KEY_PATH
        parts = path.to_s.split(?.)

        @inner.dig(*parts)
      when SINGLE_PATH
        @inner[path.to_s]
      when nil then nil
      when DOT_PATH
        # :nocov:
        raise InvalidPath, "Confusing key: #{path.inspect}"
        # :nocov:
      else
        # :nocov:
        raise InvalidPath, "Cannot get path from: #{path.inspect}"
        # :nocov:
      end
    end

    def []=(path, value)
      case path
      when KEY_PATH
        *parts, key = path.to_s.split(?.)

        incr_path = []

        target_hash = parts.reduce(@inner) do |h, k|
          incr_path << k

          inner_h = h[k] ||= {}

          next inner_h if inner_h.kind_of?(Hash)

          # :nocov:
          raise InvalidNesting.new inner_h, incr_path
          # :nocov:
        end

        if value == DELETE
          target_hash.delete key

          delete! parts.join(?.) if target_hash.blank? && parts.any?
        else
          target_hash[key] = value
        end
      when SINGLE_PATH
        if value == DELETE
          @inner.delete path.to_s
        else
          @inner[path.to_s] = value
        end
      when DOT_PATH
        # :nocov:
        raise InvalidPath, "Confusing key: #{path.inspect}"
        # :nocov:
      else
        # :nocov:
        raise InvalidPath, "Cannot get path from: #{path.inspect}"
        # :nocov:
      end
    ensure
      derive_paths! unless @batching
    end

    def batching? = @batching

    def blank? = @inner.blank?

    def delete!(path)
      self[path] = DELETE

      return self
    end

    def each
      return enum_for(__method__) unless block_given?

      derive_path_hash.each do |key, value|
        yield key, value
      end
    end

    # @param [#to_s] path
    # @raise [KeyError]
    # @return [Object]
    def fetch(path)
      raise KeyError, "Unable to fetch #{path.inspect}" unless key?(path)

      self[path]
    end

    # @param [#to_s] key
    def key?(key)
      path = key.to_s

      case path
      when KEY_PATH
        key.in?(paths)
      when SINGLE_PATH
        @inner.key? path
      else
        false
      end
    end

    # @param [Hash, PropertyHash] other
    # @return [Support::PropertyHash]
    def merge(other)
      other_hash = other.kind_of?(PropertyHash) ? other : PropertyHash.new(other)

      new_hash = PropertyHash.new

      new_hash.with_batch do
        each do |key, value|
          new_hash[key] = value
        end

        other_hash.each do |key, value|
          new_hash[key] = value
        end
      end

      return new_hash
    end

    alias | merge

    # @param [Hash, PropertyHash] other
    # @return [self]
    def merge!(other)
      other_hash = other.kind_of?(PropertyHash) ? other : PropertyHash.new(other)

      with_batch do
        other_hash.each do |key, value|
          self[key] = value
        end
      end

      return self
    end

    # @return [{ String => Object }]
    def to_flat_hash = @path_hash

    def to_h = export_inner_hash

    alias to_hash to_h

    def as_json(...) = to_h

    # @param [Support::PropertyHash] other
    # @return [void]
    def initialize_copy(original)
      super

      @inner = original.export_inner_hash
      @batching = false

      derive_paths!
    end

    # @return [void]
    def with_batch
      @batching = true

      yield
    ensure
      @batching = false

      derive_paths!
    end

    protected

    # @note We don't use deep_dup here because sometimes we want to preserve mutable values in the hash
    # @return [Hash] a semi-deep copy of the inner hash
    def export_inner_hash
      @inner.deep_transform_values do |value|
        case value
        when Array then value.map { _1 }
        else
          value
        end
      end
    end

    attr_reader :inner

    private

    def calculate_nested_paths(with:, on: {}, parent: [])
      with.each_with_object(on) do |(key, value), h|
        path = [*parent, key]

        case value
        when Hash
          calculate_nested_paths(with: value, on: h, parent: path)
        else
          full_path = path.join(?.)

          h[full_path] = value
        end
      end
    end

    def derive_path_hash
      calculate_nested_paths with: @inner
    end

    # @return [void]
    def derive_paths!
      @path_hash = derive_path_hash.freeze
      @paths = @path_hash.keys.freeze
    ensure
      @batching = false
    end

    class InvalidPath < KeyError; end

    class InvalidNesting < TypeError
      # @param [Object] found_object something that is not a hash
      # @param [<String>] path
      def initialize(found_object, path)
        @found_object = found_object
        @path = path.join(?.)

        super("Got #{@found_object.inspect} at #{@path}, expected a hash")
      end
    end
  end
end
