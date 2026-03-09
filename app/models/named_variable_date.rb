# frozen_string_literal: true

# A special reference to a variable date for an entity, by a specific property
# A reference to a variable date for some kind of {ChildEntity}, unique by a `path`.
#
# It stores both "global" named variable dates, which are treated as top-level attributes
# on the entity, and schema-derived named variable dates.
#
# @see ReferencesNamedVariableDates
# @see WritesNamedVariableDates
class NamedVariableDate < ApplicationRecord
  include GenericAccessible
  include TimestampScopes

  attr_readonly :actual_precision, :precision, :coverage, :normalized, :value

  belongs_to :entity, polymorphic: true, inverse_of: :named_variable_dates
  belongs_to :schema_version_property, optional: true, inverse_of: :named_variable_dates

  GLOBAL_FORMAT = /\A\$[a-z_]+\$\z/

  SCHEMA_FORMAT = /\A[a-z_]+(?:\.[a-z_]+)?\z/

  scope :by_path, ->(path) { where(path:) }

  scope :published, -> { by_path("$published$") }

  scope :for_latest, -> { where.not(precision: nil).reorder(value: :desc, precision: :desc) }
  scope :for_oldest, -> { where.not(precision: nil).reorder(value: :asc, precision: :desc) }

  validates :path, uniqueness: { scope: %i[entity_id entity_type] }

  class << self
    # We use a specific format for non-schema, aka global named variable dates
    # in order to differentiate them from variable dates provided by the schema.
    #
    # @param [String] name
    # @return [String] The formatted path
    def global_path_for(name)
      GLOBAL_FORMAT.match?(name) ? name.to_s : "$#{name}$"
    end

    # Build a sort join for a {ReferencesNamedVariableDates model that references this table}
    # that allows its rows to be sorted based on the specific path.
    #
    # It returns a tuple that contains a reference to the join and two ordering expressions
    # using said join that the calling query can include in its order statement.
    #
    # @param [Class] klass
    # @param [String] path
    # @param ["asc", "desc"] dir
    # @return [(Arel::Nodes::OuterJoin, Arel::Nodes::Ordering, Arel::Nodes::Ordering)]
    def sort_join_for(klass, path, dir = "asc")
      raise "#{klass} does not reference NamedVariableDate" unless klass < ReferencesNamedVariableDates

      reflect_on_association(:entity).polymorphic_inverse_of klass

      name = sort_join_name_for klass, path

      table = arel_table.alias name

      on_condition = sort_join_on_condition_for table, klass, path

      join = Arel::Nodes::OuterJoin.new table, on_condition

      orderings = %i[value precision].map do |column|
        arel_apply_order_to table[column], dir, nulls: :last
      end

      [join, *orderings]
    end

    private

    # Build an idempotent, guaranteed-unique name for joining against a named variable date
    # with a specific path in order to sort on it.
    #
    # @param [Class] klass
    # @param [String] path
    # @return [String]
    def sort_join_name_for(klass, path)
      salt = Time.current.to_i.to_s(36)

      Base64.urlsafe_encode64 "#{klass.name}##{path}##{salt}", padding: false
    end

    # Build the `ON` condition for a sort join.
    #
    # @see ReferencesNamedVariableDates::ClassMethods#named_variable_date_join_tuple
    # @param [Arel::Nodes::TableAlias] child_table
    # @param [Class] association
    # @param [String] path
    # @return [Arel::Nodes::On]
    def sort_join_on_condition_for(child_table, parent, path)
      path_matches = child_table[:path].eq(path)

      type, id = parent.named_variable_date_join_tuple

      type_matches = child_table[:entity_type].eq(type)

      id_matches = child_table[:entity_id].eq(id)

      condition = arel_and_expressions path_matches, type_matches, id_matches

      Arel::Nodes::On.new condition
    end
  end
end
