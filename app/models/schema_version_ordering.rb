# frozen_string_literal: true

# A view that expands the {Schemas::Versions::Configuration#orderings} array into
# discrete records for introspection in the database.
class SchemaVersionOrdering < ApplicationRecord
  include GenericAccessible
  include View

  self.primary_key = %i[schema_version_id identifier]

  belongs_to :schema_version, inverse_of: :schema_version_orderings
end
