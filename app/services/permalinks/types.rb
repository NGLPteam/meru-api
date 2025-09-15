# frozen_string_literal: true

module Permalinks
  module Types
    include Dry.Types

    extend Support::EnhancedTypes

    Permalink = ModelInstance("Permalink")

    Permalinkable = Instance(::Permalinkable)
  end
end
