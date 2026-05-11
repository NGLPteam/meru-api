# frozen_string_literal: true

module Types
  module Filtering
    # @see ::Filtering::Scopes::HarvestMessages
    class HarvestMessageFilterInputType < ::Support::GQL::BaseFilterScopeInputObject
      description <<~TEXT
      Filtering options for `HarvestMessage` records.
      TEXT

      inherit_from!(::Filtering::Scopes::HarvestMessages)

      argument :severity, ::Types::HarvestMessageLevelType, required: false, default_value: "info", replace_null_with_default: true do
        description <<~TEXT
        Filter by severity.
        TEXT
      end
    end
  end
end
