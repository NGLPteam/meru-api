# frozen_string_literal: true

module Support
  module FullTextSearching
    # @api private
    # @see ::Support::FullTextSearching::Context
    class ScopeModule < Module
      # @return [::Support::FullTextSearching::Context]
      attr_reader :context

      # @param [::Support::FullTextSearching::Context] context
      def initialize(context)
        @context = context

        define_base_scope!
      end

      # @param [Class] base
      # @return [void]
      def extended(base)
        ctx = context

        base.scope context.exact_scope, ->(needle) do
          expressions = arel_or_expressions ctx.columns do |column|
            arel_table[column].eq(needle)
          end

          where(arel_grouping(expressions))
        end

        base.pg_search_scope(context.fuzzy_scope, context.fuzzy_options)
        base.pg_search_scope(context.prefix_scope, context.prefix_options)
      end

      private

      def define_base_scope!
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
        # @param [String, ::Support::FullTextSearching::Query] raw_query the search query to match against the `name` attribute
        # @param ["fuzzy", "prefix"] strategy the default search strategy to use, either "prefix" for prefix matching or "fuzzy" for websearch-style FTS matching
        # @return [ActiveRecord::Relation] a relation of records matching the search query
        def #{context.base_scope}(raw_query, strategy: #{context.default_strategy.inspect})
          query = ::Support::FullTextSearching::Query.from(raw_query, strategy:)

          query.apply do |m|
            m.exact { |needle| #{context.exact_scope}(needle) }
            m.fuzzy { |needle| #{context.fuzzy_scope}(needle) }
            m.prefix { |needle| #{context.prefix_scope}(needle) }
            m.empty { all }
          end
        end
        RUBY
      end
    end
  end
end
