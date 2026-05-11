# frozen_string_literal: true

module Support
  module Filtering
    # @abstract A further refined abstract scope that includes common argument helpers.
    #   This is the scope that the application's filter scope implementation should inherit from.
    class DefaultScope < AbstractScope
      include CommonArguments
    end
  end
end
