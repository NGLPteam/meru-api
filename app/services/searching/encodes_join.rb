# frozen_string_literal: true

module Searching
  # A thin wrapper around the join name encoder operation.
  module EncodesJoin
    # @param [String] path
    # @return [String]
    def encode_join(path)
      MeruAPI::Container["searching.compilation.encode_join_name"].(path)
    end
  end
end
