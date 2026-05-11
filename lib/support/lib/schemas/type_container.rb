# frozen_string_literal: true

module Support
  module Schemas
    class TypeContainer < Dry::Schema::TypeContainer
      include HandlesModelName

      NAMESPACES = %w[params json].freeze

      def initialize(...)
        super

        add! :bigdecimal, Support::Types::BigDecimal

        add! :safe_string, Types::SafeString

        add_model! "User"
      end

      def configure
        yield self

        return self
      end

      def add!(name, type)
        register(name, type)

        case name
        when String, Symbol
          NAMESPACES.each do |ns|
            register "#{ns}.#{name}", type
          end
        end
      end

      def add_enum!(enum_klass, single_key: nil, plural_key: nil)
        single_type = Types::EnumType[enum_klass].dry_type
        plural_type = Types::Array.of(single_type).gql_type(enum_klass)

        single_key ||= enum_klass.graphql_name.underscore
        plural_key ||= enum_klass.graphql_name.tableize

        add! single_key, single_type
        add! plural_key, plural_type
      end

      def add_model!(klass, as_type: "Types::#{klass}Type", model_name: model_name_from(klass), single_key: model_name.singular, plural_key: model_name.plural)
        # :nocov:
        raise TypeError, "must be string" unless klass.kind_of?(String)
        # :nocov:

        single_type = ::Support::Types::ModelInstanceNamed[klass].gql_loads(as_type).gql_description(<<~TEXT)
        Filter by a single #{klass}.
        TEXT

        plural_type = Types::Array.of(single_type).gql_loads(as_type).gql_description(<<~TEXT)
        Filter by an array of #{klass} records, matching one or more.
        TEXT

        add! single_key, single_type
        add! plural_key, plural_type

        return self
      end
    end
  end
end
