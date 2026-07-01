# frozen_string_literal: true

module Support
  module DryGQL
    # @abstract A container for iteratively building up a set of types that can be used
    #   interchangeably as both dry types and GraphQL types.
    class TypeContainer
      extend ActiveModel::Callbacks
      extend Dry::Core::ClassAttributes

      include Dry::Container::Mixin
      include Support::Typing

      defines :enum_types, type: Types::EnumTypes
      defines :model_names, type: Types::Array.of(Types::String)

      enum_types Dry::Core::Constants::EMPTY_ARRAY

      model_names Dry::Core::Constants::EMPTY_ARRAY

      define_model_callbacks :compile_types, :compile_models
      define_model_callbacks :initialize, only: %i[after]

      # @return [Boolean]
      attr_reader :compiled

      alias compiled? compiled

      # @return [ActiveSupport::HashWithIndifferentAccess{String, Symbol => Class(GraphQL::Schema::Enum)}]
      attr_reader :enum_types

      # @return [Boolean]
      attr_reader :has_compiled_models

      alias has_compiled_models? has_compiled_models

      # @return [ActiveSupport::HashWithIndifferentAccess{String, Symbol => ModelReference}]
      attr_reader :models

      def initialize(...)
        super

        merge Support::DryGQL::DefaultTypings

        @enum_types = {}.with_indifferent_access

        @models = {}.with_indifferent_access

        run_callbacks :initialize

        run_callbacks :compile_types do
          compile_models!

          realize_models!

          compile_enums!

          @compiled = true
        end

        freeze
      end

      # @param [String, Symbol] name
      # @param [Dry::Types::Type] type
      # @return [void]
      def add!(name, type)
        # simplecov:disable
        raise "must have gql typing" unless type.has_gql_typing?
        # simplecov:enable

        register(name, type)
      end

      # @param [String, Symbol] name
      # @yield a lazily-evaluated block that returns a `Dry::Types::Type`
      # @yieldreturn [Dry::Types::Type]
      # @return [void]
      def add_lazy!(name)
        register(name, memoize: true) do
          type = yield

          # simplecov:disable
          raise "must have gql typing" unless type.has_gql_typing?
          # simplecov:enable

          type
        end
      end

      # @param [Class(GraphQL::Schema::Enum)] enum_klass
      # @param [String, nil] single_key
      # @param [String, nil] plural_key
      # @return [void]
      def add_enum!(enum_klass, single_key: nil, plural_key: nil)
        single_type = Types::EnumType[enum_klass].dry_type
        plural_type = Types::Array.of(single_type).gql_type(enum_klass)

        single_key ||= enum_klass.graphql_name.underscore
        plural_key ||= enum_klass.graphql_name.tableize

        @enum_types[single_key] = enum_klass

        add! single_key, single_type
        add! plural_key, plural_type
      end

      # @param [String] klass_name
      # @param [Hash] options (@see Support::DryGQL::ModelReference)
      # @return [void]
      def add_model!(klass_name, **options)
        reference = ModelReference.new(klass_name, **options, container: self)

        @models[reference.reference_key] = reference

        add_lazy! reference.single_key do
          reference.single_type
        end

        add_lazy! reference.plural_key do
          reference.plural_type
        end

        return self
      end

      private

      # @return [void]
      def compile_enums!
        self.class.enum_types.each do |enum_klass|
          add_enum! enum_klass
        end
      end

      # @return [void]
      def compile_models!
        run_callbacks :compile_models do
          self.class.model_names.each do |model_name|
            add_model! model_name
          end

          @has_compiled_models = true
        end
      end

      # @return [void]
      def realize_models!
        models.each_value(&:realize!)
      end

      class << self
        # @param [<Class(GraphQL::Schema::Enum)>] enum_types
        # @return [void]
        def add_enum_types!(*enum_types)
          new_types = enum_types.flatten.compact_blank

          merged_types = (enum_types | new_types).sort_by(&:graphql_name).freeze

          enum_types merged_types
        end

        # @param [Class(GraphQL::Schema::Enum)] enum_type
        # @return [void]
        def add_enum_type!(enum_type)
          add_enum_types! enum_type
        end

        # @param [<String>] names
        # @return [void]
        def add_models!(*names)
          new_names = names.flatten.compact_blank

          merged_names = (model_names | new_names).sort.freeze

          model_names merged_names
        end

        # @param [String] name
        # @return [void]
        def add_model!(name)
          add_models! name
        end

        # @return [void]
        def compile!(...)
          before_compile_types(...)
        end
      end
    end
  end
end
