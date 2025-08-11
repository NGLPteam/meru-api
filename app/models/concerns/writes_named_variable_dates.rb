# frozen_string_literal: true

# A concern for writing to a `has_many :named_variable_dates` association.
#
# Owning to the fact that we essentially treat this as a hash, we have to
# use a {#named_variable_date_cache caching approach} to mark writes as
# pending until we actually persist the entity.
#
# @see ReferencesNamedVariableDates::ClassMethods#writes_named_variable_date!
module WritesNamedVariableDates
  extend ActiveSupport::Concern

  include ReferencesNamedVariableDates

  included do
    writes_named_variable_date! :published

    before_create :create_shared_named_variable_date_records!

    after_save :persist_named_variable_dates!
  end

  # @note Overrides {ReferencesNamedVariableDates#named_variable_date_value_for}
  #   to check the {#named_variable_date_cache cache} for a pending value before
  #   grabbing the actual value from the {NamedVariableDate model}.
  def named_variable_date_value_for(name)
    named_variable_date_cache.fetch name do
      super(name)
    end
  end

  # Write a value to the cache. Until the record is saved or reloaded, any attempt
  # to {#named_variable_date_value_for read the value} will defer to the cache
  #
  # @param [String] name
  # @param [String, VariablePrecisionDate, Date] value (@see VariablePrecision::ParseDate)
  # @return [void]
  def write_named_variable_date!(name, value)
    parsed = MeruAPI::Container["variable_precision.parse_date"].call(value).value!

    named_variable_date_cache[name] = parsed
  end

  # @api private
  # @return [void]
  def persist_named_variable_dates!
    return if named_variable_date_cache.blank?

    base = named_variable_dates.scope_for_create

    attributes = named_variable_date_cache.each_pair.map do |name, raw|
      path = named_variable_date_global_path_for name

      actual = ::VariablePrecisionDate.parse(raw).to_sql

      base.merge(path:, actual:)
    end

    NamedVariableDate.upsert_all(
      attributes,
      unique_by: %i[entity_type entity_id path],
      returning: nil
    )

    named_variable_dates.reload

    named_variable_date_cache.clear
  end

  # @api private
  # @!attribute [r] named_variable_date_cache
  # Stores a cache of pending values for an entity's named variable dates.
  # It is cleared on a valid save, as well as if the entity is reloaded.
  # @return [Concurrent::Map]
  def named_variable_date_cache
    @named_variable_date_cache ||= Concurrent::Map.new
  end

  # On creating an entity, ensure that a record is created for each known variable date type.
  # @api private
  # @return [void]
  def create_shared_named_variable_date_records!
    NamedVariableDates.each_shared do |name|
      named_variable_date_cache.put_if_absent name, VariablePrecisionDate.none
    end
  end

  # @note We hook the reload method to clear our pending writes
  #   in case the model needs be reset.
  def reload(...)
    named_variable_date_cache.clear

    super
  end

  module ClassMethods
    # Define methods for writing to a global named variable date.
    # @param [String] name
    # @return [void]
    # @!macro [attach] writes_named_variable_date!
    #   @!attribute [w] name
    #   @return [VariablePrecisionDate]
    def writes_named_variable_date!(name)
      include NamedVariableDates::Global::WriterInstanceMethods.for name
    end
  end
end
