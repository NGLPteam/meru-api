# frozen_string_literal: true

class SchematicCollectedReference < ApplicationRecord
  include GenericAccessible
  include SchematicReference
  include TimestampScopes

  scope :in_order, -> { order(path: :asc, position: :asc) }

  validates :path, presence: true, uniqueness: { scope: %i[referrer referent] }

  class << self
    def valid_paths_column
      :collected_reference_paths
    end
  end
end
