# frozen_string_literal: true

# A list of static properties that can be ordered by on {OrderingEntryCandidate} or a related model.
class StaticOrderableProperty < FrozenRecord::Base
  include ActiveModel::Validations
  include Dry::Core::Memoizable
  include TranslatedFrozenRecord

  SUPPORTED_TYPES = %w[string variable_date integer timestamp boolean select].freeze

  self.primary_key = "path"

  add_index :path, unique: true

  scope :visible, -> { where(hidden: [nil, false]) }

  has_translated! :label
  has_translated! :description

  validates :builder, :grouping, :type, :path, :name, :namespace, :identifier, presence: true
  validates :type, inclusion: { in: SUPPORTED_TYPES }

  validate :has_valid_path!

  def identifier
    path.tr(?., ?_)
  end

  def namespace
    path[/\A([^.]+)\./, 1]
  end

  def name
    path[/\A[^.]+?\.(.+)\z/, 1]
  end

  # @return [String]
  def default_label
    identifier.titleize
  end

  # @return [Schemas::Orderings::OrderBuilder::Base]
  def order_builder
    order_builder_klass.new(**order_builder_options)
  end

  def order_builder_klass
    validate!

    "::Schemas::Orderings::OrderBuilder::#{builder.camelize}".constantize
  end

  def order_builder_options
    {}.tap do |h|
      h[:columns] = columns if builder == "by_columns"
      h[:path] = variable_date_path if builder == "by_variable_date"
    end
  end

  # @return [String]
  def variable_date_path
    "$#{name}$" if builder == "by_variable_date"
  end

  private

  # @return [void]
  def has_valid_path!
    return if path.start_with? "#{grouping}."

    # simplecov:disable
    errors.add :path, :invalid, grouping:
    # simplecov:enable
  end

  def primary_key_for_i18n
    identifier
  end
end
