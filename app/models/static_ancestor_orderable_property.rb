# frozen_string_literal: true

# A list of static properties that can be ordered by on {OrderingEntryCandidate} or a related model.
class StaticAncestorOrderableProperty < ::ApplicationFrozenRecord
  include ActiveModel::Validations
  include Dry::Core::Memoizable
  include TranslatedFrozenRecord

  schema!(types: ::Schemas::Orderings::TypeRegistry) do
    required(:base_path).filled(:string)
    required(:builder).filled(:order_builder_name)
    required(:grouping).filled(:string)
    required(:columns).array("coercible.symbol")
    required(:type).filled(:static_property_type)
  end

  default_attributes!(
    builder: "by_columns",
    columns: Dry::Core::Constants::EMPTY_ARRAY,
    grouping: "ancestor_static",
    type: "string"
  )

  self.primary_key = "base_path"

  add_index :base_path, unique: true

  has_translated! :label
  has_translated! :description

  # @return [String]
  def default_label
    base_path.titleize
  end

  klass_name_pair! :order_builder do
    "::Schemas::Orderings::OrderBuilder::#{builder.camelize}"
  end

  # @param [String] ancestor_name
  # @return [String]
  def path_for(ancestor_name)
    "ancestors.#{ancestor_name}.#{base_path}"
  end

  # @param [String] ancestor_name
  # @return [Schemas::Orderings::OrderBuilder::Base]
  def order_builder_for(ancestor_name)
    options = order_builder_options_for(ancestor_name)

    order_builder_klass.new(**options)
  end

  # @return [String]
  def variable_date_path
    "$#{base_path}$" if builder == "by_variable_date"
  end

  private

  def order_builder_options_for(ancestor_name)
    { ancestor_name:, }.tap do |h|
      h[:columns] = columns if builder == "by_columns"
      h[:path] = variable_date_path if builder == "by_variable_date"
    end
  end

  def primary_key_for_i18n
    base_path
  end
end
