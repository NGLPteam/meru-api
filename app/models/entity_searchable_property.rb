# frozen_string_literal: true

# Stores a parsed, database-searchable value for a {HasSchemaDefinition Schema Instance}.
#
# @see Schemas::Instances::ExtractSearchableProperties
class EntitySearchableProperty < ApplicationRecord
  include DenormalizedProperty
  include GenericInaccessible
  include TimestampScopes

  # @api private
  SUPPORTED_PROPERTY_TYPES = %w[
    boolean
    date
    float
    full_text
    integer
    markdown
    multiselect
    select
    string
    timestamp
    variable_date
  ].freeze
end
