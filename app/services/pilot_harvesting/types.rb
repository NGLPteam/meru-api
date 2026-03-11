# frozen_string_literal: true

module PilotHarvesting
  # Types related to pilot
  module Types
    extend ::Support::Typespace

    SeedList = Types::Array.of(Types::String).default { [] }

    SourceURL = Types::String.constrained(http_uri: true)
  end
end
