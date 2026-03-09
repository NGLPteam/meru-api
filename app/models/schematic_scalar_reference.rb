# frozen_string_literal: true

class SchematicScalarReference < ApplicationRecord
  include GenericAccessible
  include SchematicReference
  include TimestampScopes

  validates :path, presence: true, uniqueness: { scope: :referrer }

  class << self
    def valid_paths_column
      :scalar_reference_paths
    end
  end
end
