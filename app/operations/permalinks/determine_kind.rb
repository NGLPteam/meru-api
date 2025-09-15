# frozen_string_literal: true

module Permalinks
  class DetermineKind
    include Dry::Monads[:result]

    # @param [Permalinkable] permalinkable
    def call(permalinkable)
      case permalinkable
      in Community then Success("community")
      in Collection then Success("collection")
      in Item then Success("item")
      else
        raise TypeError, "Unknown permalinkable record: #{permalinkable.class.name}"
      end
    end
  end
end
