# frozen_string_literal: true

module SchematicPathValidity
  extend ActiveSupport::Concern

  included do
    scope :with_valid_path, -> { path_valid_with valid_paths_column }
    scope :sans_valid_path, -> { path_invalid_with valid_paths_column }
    scope :sans_global_path, -> { where(arel_table[:path].does_not_match("$%$")) }
  end

  module ClassMethods
    # @abstract
    # @return [Symbol]
    def valid_paths_column
      # simplecov:disable
      raise "Must define"
      # simplecov:enable
    end

    # @return [ActiveRecord::Relation]
    def path_valid_with(path_column)
      joins(:schema_version).where(arel_table[:path].eq(arel_any_schema_column(path_column)))
    end

    # @return [ActiveRecord::Relation]
    def path_invalid_with(path_column)
      paths = arel_any_schema_column(path_column)

      at_least_one_path = arel_named_fn("cardinality", SchemaVersion.arel_table[path_column]).gt(0)

      no_path_matches = arel_table[:path].not_eq paths

      expr = Arel::Nodes::Case.new.tap do |stmt|
        stmt.when(at_least_one_path).then(no_path_matches)
        stmt.else(true)
      end

      joins(:schema_version).where(expr).sans_global_path
    end

    private

    def arel_any_schema_column(name)
      arel_named_fn("ANY", SchemaVersion.arel_table[name])
    end
  end
end
