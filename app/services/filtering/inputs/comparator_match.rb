# frozen_string_literal: true

module Filtering
  module Inputs
    # @abstract
    class ComparatorMatch < ::Support::FlexibleStruct
      include Dry::Core::Memoizable

      BASE_TYPES = Support::DryGQL::TypeContainer.new

      COMPARATORS = %i[eq lt lteq gt gteq not_eq].freeze

      delegate :blank?, to: :comparators

      # @param [Arel::Attribute] attribute
      # @return [Arel::Expressions]
      def call(attribute)
        return if blank?

        expressions = comparators.map do |(cmp, value)|
          attribute.public_send(cmp, value)
        end

        arel_andify expressions
      end

      # @param [Symbol] cmp
      def has?(cmp)
        comparators.key? cmp
      end

      # @api private
      # @return [{ Symbol => Object }]
      memoize def comparators
        attributes.compact
      end

      private

      def arel_andify(expressions)
        return block_given? ? yield(expressions[0]) : expressions[0] if expressions.one?

        expressions.reduce do |grouping, expression|
          expression = yield expression if block_given?

          next grouping if expression.blank?

          if grouping.kind_of?(Arel::Nodes::Grouping)
            grouping.expr.and(expression)
          else
            # First expression
            grouping = yield grouping if block_given?

            grouping.and(expression)
          end
        end
      end

      class << self
        attr_reader :input_object

        # @param [#to_s] type_key
        # @return [Class]
        def of(type_key)
          type = BASE_TYPES.resolve type_key

          Class.new(self).tap do |klass|
            klass.define_comparator_attributes_for! type
          end.with_gql_type
        end

        protected

        def define_comparator_attributes_for!(type)
          COMPARATORS.each do |comparator|
            attribute? comparator, type.optional
          end

          @input_object = build_input_object_for type
        end

        def build_input_object_for(type)
          struct_klass = self

          gql_type = type.gql_type

          Class.new(::Types::BaseInputObject).tap do |klass|
            klass.graphql_name "#{type.name}FilterMatch"

            klass.description <<~TEXT
            Filter a value with various constraints. If no values are provided to any
            operator, this filter will be ignored.

            **Note**: The server will _not_ try to check for logical impossibilities,
            e.g. `{ lt: 5, gteq: 10 }`: such input will simply not find anything.
            TEXT

            COMPARATORS.each do |comparator|
              klass.argument comparator, gql_type, required: false
            end

            klass.define_method(:prepare) do
              struct_klass.new(to_h).presence
            end
          end
        end

        def with_gql_type
          gql_type(input_object)
        end
      end
    end
  end
end
