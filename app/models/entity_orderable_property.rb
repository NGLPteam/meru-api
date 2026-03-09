# frozen_string_literal: true

# Stores a parsed, database-sortable value for a {HasSchemaDefinition Schema Instance}.
#
# @see Schemas::Instances::ExtractOrderableProperties
class EntityOrderableProperty < ApplicationRecord
  include DenormalizedProperty
  include GenericAccessible
  include TimestampScopes

  # @api private
  SUPPORTED_PROPERTY_TYPES = %i[
    boolean
    date
    email
    float
    integer
    string
    timestamp
    variable_date
  ].freeze
end
