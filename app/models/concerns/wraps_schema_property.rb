# frozen_string_literal: true

module WrapsSchemaProperty
  extend ActiveSupport::Concern

  include FiltersBySchemaDefinition

  included do
    self.inheritance_column = :_type_disabled

    attr_readonly :default_value

    pg_enum! :kind, as: "schema_property_kind", prefix: :with, suffix: :kind
    pg_enum! :type, as: "schema_property_type", prefix: :with, suffix: :type

    scope :by_schema_definition, ->(definition) { where(schema_definition: definition) }

    scope :by_path, ->(path) { where(path:) }

    scope :orderable, -> { where(orderable: true) }

    scope :searchable, -> { where(searchable: true) }

    scope :sans_paths, ->(paths) { where.not(path: paths) }
  end

  def citextual? = with_email_type?

  def textual? = with_email_type? || with_select_type? || with_string_type?
end
