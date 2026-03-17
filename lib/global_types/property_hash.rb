# frozen_string_literal: true

module GlobalTypes
  # Wrapper around a JSONB column that always provides an indifferent hash.
  #
  # It is available as `:indifferent_hash` through the type map.
  class PropertyHash < ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Jsonb
    # Type cast a value from user input (e.g. from a setter).
    #
    # @param [Hash, #to_h] value
    # @return [::Support::PropertyHash]
    def cast(value)
      Dry::Types["coercible.hash"].try(value).to_monad.value_or({}).then do |v|
        ::Support::PropertyHash.new v
      end
    end

    # Casts a value from database input to appropriate ruby type.
    #
    # @note Normal `ActiveRecord::Type` behavior is to pass nils through, but we *always* want a hash.
    # @param [Hash, #to_h] value
    # @return [::Support::PropertyHash]
    def deserialize(value)
      cast(super)
    end

    # @return [Hash]
    def serialize_for_store_model(value) = cast(value).to_h

    # @api private
    # @note Compatibility method for ActiveRecord::Type
    # @return [Class]
    def accessor
      ActiveRecord::Store::IndifferentHashAccessor
    end
  end
end
