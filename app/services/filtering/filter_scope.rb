# frozen_string_literal: true

module Filtering
  # @abstract
  class FilterScope < Support::QueryResolver::Base
    extend Dry::Initializer

    define_model_callbacks :ranking, only: %i[before after]

    include HasArguments

    defines :model_klass, type: Support::Models::Types::ModelClass

    model_klass ApplicationRecord

    defines :input_object_name, type: Filtering::Types::String

    input_object_name ""

    defines :input_object_default_value, type: Filtering::Types::Hash.fallback { {} }

    # @see Filtering::Applicator#call
    # @param [ActiveRecord::Relation] top_level_scope
    # @return [ActiveRecord::Relation]
    def apply_to(top_level_scope)
      applicator.(top_level_scope)
    end

    def initialize_scope
      self.class.model_klass.all
    end

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
      new_scope = yield @ranking_scope

      @ranking_scope = new_scope unless new_scope.nil?
    end

    def filter_inputs
      @filter_inputs ||= self.class.arguments.keys.to_h do |key|
        [key.to_sym, public_send(key)]
      end.compact
    end

    private

    def applicator
      @applicator ||= Filtering::Applicator.new(self)
    end

    class << self
      def [](klass)
        Class.new(self).tap do |filter_scope|
          filter_scope.model_klass klass

          filter_scope.input_object_name "#{klass.model_name}FilterInput"

          filter_scope.extension

          filter_scope.input_object
        end
      end

      def argument!(...)
        super
      ensure
        @extension = build_extension
        @input_object = build_input_object
      end

      def extension
        @extension ||= build_extension
      end

      def input_object
        @input_object ||= build_input_object
      end

      def options_for_resolver
        {
          type: input_object,
          default: input_object_default_value,
          argument_options: {
            replace_null_with_default: true,
          },
          description: <<~TEXT
          Filters that **must** match.
          TEXT
        }
      end

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

      private

      def build_extension
        Class.new(GraphQL::Schema::FieldExtension).tap do |ext|
          arguments.each do |key, dry_type|
            typing = dry_type.gql_typing

            opts = typing.argument_options

            type = opts.delete :type

            ext.default_argument key, type, **opts
          end
        end
      end

      def build_input_object
        Class.new(::Types::FilterInputObject).tap do |io|
          io.inherit_from! self
        end.tap do |klass|
          ::Types::Filtering.accept! klass
        end
      end
    end
  end
end
