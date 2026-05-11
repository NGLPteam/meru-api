# frozen_string_literal: true

module Support
  module Filtering
    # The base class for building filter scopes. It has a fluent DSL for defining filtering
    # arguments, and methods for applying those filters to an ActiveRecord scope.
    #
    # @abstract
    class AbstractScope < Support::QueryResolver::Base
      extend Dry::Initializer

      include ::Support::Typing

      Subclass = ::Support::Filtering::Types.Inherits(self)

      defines :required_scopes, type: ::Support::Filtering::Types::ScopeNames

      required_scopes Dry::Core::Constants::EMPTY_ARRAY

      define_model_callbacks :ranking, only: %i[before after]

      defines :model_klass, type: ::Support::Models::Types::ModelClass

      model_klass Support::NullRecord

      defines :input_object_name, type: Support::Filtering::Types::String

      input_object_name ""

      def initialize(...)
        super

        @filter_inputs = build_filter_inputs
      end

      # @see Filtering::Applicator#call
      # @param [ActiveRecord::Relation] top_level_scope
      # @return [ActiveRecord::Relation]
      def apply_to(top_level_scope)
        applicator.(top_level_scope)
      end

      # @return [ActiveRecord::Relation]
      def initialize_scope
        self.class.model_klass.all
      end

      # Finalize the scope by reselecting only the primary key and removing any ordering.
      #
      # @return [void]
      def finalize!
        augment_scope! do |sc|
          sc.reselect(sc.primary_key).reorder(nil)
        end
      end

      # @param [ActiveRecord::Relation] base
      # @return [ActiveRecord::Relation]
      def apply_ranking_to(base)
        @ranking_scope = base

        run_callbacks :ranking

        return @ranking_scope
      ensure
        @ranking_scope = nil
      end

      # @yieldparam [ActiveRecord::Relation] ranking_scope
      # @yieldreturn [ActiveRecord::Relation]
      # @return [void]
      def augment_ranking!
        # :nocov:
        new_scope = yield @ranking_scope

        @ranking_scope = new_scope unless new_scope.nil?
        # :nocov:
      end

      def has_admin_access? = current_user.try(:has_admin_access?)

      private

      # @!attribute [r] applicator
      # @return [Filtering::Applicator]
      def applicator
        @applicator ||= Filtering::Applicator.new(self)
      end

      # @return [void]
      def apply_all_tags!
        augment_scope! do |scope|
          external_tags&.call(scope, on: :external_tags)
        end

        augment_scope! do |scope|
          next unless internal_tags.present?
          next scope.none unless has_admin_access?

          internal_tags.call(scope, on: :internal_tags)
        end
      end

      # @return [Hash]
      def build_filter_inputs
        self.class.arguments.keys.to_h do |key|
          [key.to_sym, public_send(key)]
        end.compact
      end

      class << self
        # Create a subclass of {Filtering::FilterScope} for the given model class
        # to inherit from.
        #
        # @param [Class<ActiveRecord::Base>] klass the model class to wrap around
        # @return [Class<Filtering::FilterScope>]
        def [](klass)
          Class.new(self).tap do |filter_scope|
            filter_scope.model_klass klass

            filter_scope.input_object_name "#{klass.model_name}FilterInput"
          end
        end

        # @!attribute [r] input_object
        # @return [Class<GraphQL::Schema::InputObject>]
        def input_object
          @input_object ||= "::Types::Filtering::#{model_klass.name}FilterInputType".safe_constantize
        end

        # @see Resolvers::AbstractResolver.filters_with!
        # @return [Hash] options for the `filters` resolver argument
        def options_for_resolver
          {
            type: input_object,
            default: arguments.default_value,
            argument_options: {
              replace_null_with_default: true,
            },
            description: <<~TEXT
            Filters that **must** match.
            TEXT
          }
        end

        # @see Resolvers::AbstractResolver.filters_with!
        # @return [Hash] options for the `orFilters` resolver argument
        def options_for_or_resolver
          {
            type: [input_object, { null: false }],
            default: [],
            argument_options: {
              replace_null_with_default: true,
            },
            description: <<~TEXT
            An array of filters, at least one of which must match. This is intended more for debugging and introspection in the API,
            though a UI could be built.

            **Note**: If `filters` is also specified, at least one set of filters in `orFilters` must match, along with `filters`.
            TEXT
          }
        end

        # @param [Symbol] scope_name
        # @return [void]
        def uses_scope!(scope_name)
          uses_scopes! scope_name
        end

        # @param [<Symbol>] scope_names
        # @return [void]
        def uses_scopes!(*scope_names)
          new_scopes = scope_names.flatten.compact_blank.map { _1.to_sym }

          # :nocov:
          return if new_scopes.blank?
          # :nocov:

          merged_scopes = (required_scopes | new_scopes).sort

          required_scopes merged_scopes.freeze
        end
      end
    end
  end
end
