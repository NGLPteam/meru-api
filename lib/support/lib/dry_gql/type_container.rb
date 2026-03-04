# frozen_string_literal: true

module Support
  module DryGQL
    class TypeContainer
      include Dry::Container::Mixin

      def initialize(...)
        super

        merge Support::DryGQL::DefaultTypings

        add_model! ::User
      end

      def configure
        yield self

        return self
      end

      def add!(name, type)
        # :nocov:
        raise "must have gql typing" unless type.has_gql_typing?
        # :nocov:

        register(name, type)
      end

      # @param [#to_s] key
      # @param
      def add_enum!(enum_klass, single_key: nil, plural_key: nil)
        single_type = Types::EnumClass[enum_klass].dry_type
        plural_type = Types::Array.of(single_type).gql_type(enum_klass)

        single_key ||= enum_klass.graphql_name.underscore
        plural_key ||= enum_klass.graphql_name.tableize

        add! single_key, single_type
        add! plural_key, plural_type
      end

      def add_model!(klass, as_type: klass.graphql_node_type_name, single_key: klass.model_name.singular, plural_key: klass.model_name.plural)
        single_type = Types.Instance(klass).gql_loads(as_type).gql_description(<<~TEXT)
        Filter by a single #{klass}.
        TEXT

        plural_type = Types::Array.of(single_type).gql_loads(as_type).gql_description(<<~TEXT)
        Filter by an array of #{klass} records, matching one or more.
        TEXT

        add! single_key, single_type
        add! plural_key, plural_type
        add! klass, single_type
        add! [klass], plural_type

        return self
      end
    end
  end
end
