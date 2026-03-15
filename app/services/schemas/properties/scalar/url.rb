# frozen_string_literal: true

module Schemas
  module Properties
    module Scalar
      # A schema property that wraps a URL with label and an optional title.
      #
      # @see Schemas::Properties::Types::NormalizedURL
      # @see Schemas::Properties::Types::URLShape
      class URL < Base
        schema_type! :url

        graphql_value_key :url
      end
    end
  end
end
