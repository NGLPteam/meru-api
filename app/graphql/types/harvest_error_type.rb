# frozen_string_literal: true

module Types
  # @see HarvestError
  class HarvestErrorType < Types::BaseModel
    description <<~TEXT
    An error that may occur during the harvesting process.
    TEXT

    field :code, String, null: true do
      description <<~TEXT
      A machine code that identifies the error for reprocessing and debugging.
      TEXT
    end

    field :message, String, null: true do
      description <<~TEXT
      A more descriptive issue of the message, if available.
      TEXT
    end

    field :metadata, GraphQL::Types::JSON, null: false do
      description <<~TEXT
      Raw metadata for the error. Should be displayed as inspectable JSON.
      TEXT
    end
  end
end
