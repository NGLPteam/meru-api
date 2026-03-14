# frozen_string_literal: true

module Types
  # @see HasHarvestErrors
  module HasHarvestErrorsType
    include Types::BaseInterface

    ERRORS_DEPRECATED = <<~TEXT
    Harvest errors are no longer returned nor generated. Check the harvest messages instead.
    TEXT

    field :harvest_errors, [::Types::HarvestErrorType, { null: false }], null: false, deprecation_reason: ERRORS_DEPRECATED do
      description <<~TEXT
      A list of errors that are associated with this harvesting type.
      TEXT
    end

    def harvest_errors = Dry::Core::Constants::EMPTY_ARRAY
  end
end
