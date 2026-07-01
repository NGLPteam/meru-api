# frozen_string_literal: true

module Support
  module QueryResolver
    # @abstract
    class Unionized < Support::QueryResolver::Base
      after_prepare :add_forks!

      # @api private
      # @return [void]
      def add_forks!
        @forks = {}
      end

      # @param [Symbol] name
      # @yield [base]
      # @yieldparam [ActiveRecord::Relation] base
      # @yieldreturn [ActiveRecord::Relation, nil]
      # @return [void]
      def fork_scope!(name)
        new_fork = yield @base_scope

        @forks[Support::Types::Symbol[name]] = new_fork
      end

      def finalize!
        @current_scope = unionize
      end

      def calculate_total_count!
        @forks.each_value do |query|
          increment_total_count! query.merge(@current_scope).count
        end
      end

      private

      # @abstract
      # @param [Symbol] name
      # @param [ActiveRecord::Relation] query
      # @param [Boolean] single
      # @return [void]
      def finalize_fork(name, query, single: false)
        query.merge(@current_scope)
      end

      # @abstract
      # @param [ActiveRecord::Relation] query
      # @return [ActiveRecord::Relation]
      def finalize_union(query)
        query
      end

      def unionize
        if @forks.one?
          only_name, single_query = @forks.first

          finalize_fork only_name, single_query, single: true
        elsif @forks.none?
          # simplecov:disable
          @base_scope.none
          # simplecov:enable
        else
          finalized_scopes = @forks.map do |(name, query)|
            finalized_fork = finalize_fork(name, query)

            quoted = Arel.sql finalized_fork.to_sql

            Arel::Nodes::Grouping.new quoted
          end

          unionized = finalized_scopes.reduce do |final, query|
            Arel::Nodes::UnionAll.new(final, query)
          end

          grouped = Arel::Nodes::Grouping.new(unionized)

          source = Arel::Nodes::TableAlias.new(grouped, Arel.sql(model.quoted_table_name))

          finalize_union model.from(source)
        end
      end
    end
  end
end
