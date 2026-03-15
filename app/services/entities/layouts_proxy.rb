# frozen_string_literal: true

module Entities
  # Used when rendering entities.
  #
  # @see Entities::CheckLayouts
  # @see Entities::LayoutsChecker
  class LayoutsProxy < Support::FlexibleStruct
    attribute :entity, Entities::Types::Entity

    attribute :rendered, Entities::Types::Bool.default(false)

    delegate_missing_to :entity

    # Unwraps the record for use in GraphQL association loading.
    #
    # @return [HierarchicalEntity]
    def unwrap_record = entity
  end
end
