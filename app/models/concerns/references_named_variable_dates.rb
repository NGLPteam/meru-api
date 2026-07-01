# frozen_string_literal: true

# A concern for reading from a `has_many :named_variable_dates` association.
#
# @see ReferencesNamedVariableDates::ClassMethods#reads_named_variable_date!
# @see ReferencesNamedVariableDates::ClassMethods#with_sorted_variable_date
module ReferencesNamedVariableDates
  extend ActiveSupport::Concern

  included do
    delegate :named_variable_date_global_path_for, to: :class

    reads_named_variable_date! :published
  end

  # @param [String] name
  # @param [Boolean] create whether a named variable date record should be automatically initialized
  # @return [NamedVariableDate, nil]
  def named_variable_date_for(name)
    path = named_variable_date_global_path_for name

    named_variable_dates.detect do |variable_date|
      variable_date.path == path
    end
  end

  # Read the `actual` from a {NamedVariableDate}. If the value is nil,
  # fall back to a none-valued `VariablePrecisionDate`.
  #
  # @param [String] name
  # @return [VariablePrecisionDate]
  def named_variable_date_value_for(name)
    named_variable_date_for(name)&.actual || VariablePrecisionDate.none
  end

  module ClassMethods
    # Define methods and scopes for referencing a global named variable date.
    # @param [String] name
    # @return [void]
    # @!macro [attach] reads_named_variable_date!
    #   @!attribute [r] name
    #   @return [VariablePrecisionDate]
    def reads_named_variable_date!(name)
      include NamedVariableDates::Global::ReaderInstanceMethods.for name

      extend NamedVariableDates::Global::ReaderClassMethods.for name
    end

    # @!group Ordering Scopes

    # A wrapper around {.with_sorted_variable_date} that ensures that the provided `name
    # is {.named_variable_date_global_path_for formatted as a path}.
    #
    # @param [String] name
    # @param ["asc", "desc"] dir
    # @return [ActiveRecord::Relation<ReferencesNamedVariableDates>]
    def with_sorted_global_variable_date(name, dir = "asc")
      path = named_variable_date_global_path_for name

      with_sorted_variable_date path, dir
    end

    # Create a relation that idempotently joins against {NamedVariableDate}
    # based on the calling model's `:named_variable_dates` association.
    #
    # @see NamedVariableDate.sort_join_for
    # @see .named_variable_date_join_tuple
    # @param [String] path
    # @param ["asc", "desc"] dir
    # @return [ActiveRecord::Relation<ReferencesNamedVariableDates>]
    def with_sorted_variable_date(path, dir = "asc")
      join, *orderings = NamedVariableDate.sort_join_for self, path, dir

      joins(join).order(*orderings)
    end

    # Sorts a global named variable date in `ASC` order.
    #
    # @see #with_oldest_variable_date
    # @param [String] path
    # @return [ActiveRecord::Relation<ReferencesNamedVariableDates>]
    def with_oldest_global_variable_date(name)
      path = named_variable_date_global_path_for name

      with_oldest_variable_date(path)
    end

    # Sorts a named variable date path in `ASC` order.
    #
    # @see #with_sorted_variable_date
    # @param [String] path
    # @return [ActiveRecord::Relation<ReferencesNamedVariableDates>]
    def with_oldest_variable_date(path)
      with_sorted_variable_date(path, "asc")
    end

    # Sorts a global named variable date in `DESC` order.
    #
    # @see #with_recent_variable_date
    # @param [String] path
    # @return [ActiveRecord::Relation<ReferencesNamedVariableDates>]
    def with_recent_global_variable_date(name)
      path = named_variable_date_global_path_for name

      with_recent_variable_date(path)
    end

    # Sorts a named variable date path in `DESC` order.
    #
    # @see #with_sorted_variable_date
    # @param [String] path
    # @return [ActiveRecord::Relation<ReferencesNamedVariableDates>]
    def with_recent_variable_date(path)
      with_sorted_variable_date(path, "desc")
    end

    # @!endgroup

    # Format a provided `name` as a global path.
    #
    # @see NamedVariableDate.global_path_for
    # @param [String] name
    # @return [String]
    def named_variable_date_global_path_for(name)
      NamedVariableDate.global_path_for name
    end

    # @api private
    # @!attribute [r] named_variable_date_join_tuple
    # The computed tuple of quoted values or `Arel::Attribute` references
    # that can join this model against {NamedVariableDate}, based on this
    # model's `:named_variable_dates` association.
    #
    # It is consumed within {NamedVariableDate.sort_join_for}.
    #
    # @return [(Arel::Nodes::Node, Arel::Nodes::Node)]
    def named_variable_date_join_tuple
      @named_variable_date_join_tuple ||= calculate_nvd_join_tuple
    end

    private

    # @return [(Arel::Nodes::Node, Arel::Nodes::Node)]
    # rubocop:disable Metrics/AbcSize
    def calculate_nvd_join_tuple
      association = reflect_on_association(:named_variable_dates)

      join_fk = association.active_record_primary_key

      if association.type.present?
        # Likely an Item, Collection, polymorphic ownership
        [arel_quote(model_name.to_s), arel_table[association.join_foreign_key]]
      elsif join_fk.kind_of?(Array) && join_fk.size == 2
        # An Entity or other hierarchical support model

        mapping = association.join_primary_key.zip(association.join_foreign_key).to_h.with_indifferent_access

        type_column, id_column = %i[entity_type entity_id].map { |column| mapping.fetch(column) }

        [arel_table[type_column], arel_table[id_column]]
      else
        # simplecov:disable
        raise "Cannot compute named variable date primary key tuple"
        # simplecov:enable
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
