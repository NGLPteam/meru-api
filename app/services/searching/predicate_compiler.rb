# frozen_string_literal: true

module Searching
  # @see Entity.apply_search_predicates
  # @api private
  class PredicateCompiler
    include Dry::Effects::Handler.State(:joins)
    include Dry::Initializer[undefined: false].define -> do
      param :predicates, Searching::Operator::List.optional, default: proc { [] }

      option :scope, Searching::Types::Interface(:all), default: proc { Entity.all }
    end

    # @return [Hash]
    attr_reader :joins

    # @return [ActiveRecord::Relation<::Entity>, nil]
    def call
      return nil if predicates.blank?

      @joins ||= {}

      compiled = compile

      return nil if compiled[:conditions].blank?

      query = scope.select(:id)

      query.where! compiled[:conditions]

      query.joins!(*joins.values) if joins.any?

      return query.apply_order_to_exclude_duplicate_links
    end

    private

    def compile
      wrap_predicate_compilation do |compiled|
        compiled[:conditions] = predicates.map { _1.call(joins:) }.compact.reduce(nil) do |expr, pred|
          expr.present? ? expr.and(pred) : pred
        end
      end
    end

    def wrap_predicate_compilation
      compiled = {}

      yield compiled

      return compiled
    end
  end
end
