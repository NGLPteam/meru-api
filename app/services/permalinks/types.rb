# frozen_string_literal: true

module Permalinks
  module Types
    extend ::Support::Typespace

    Permalink = ModelInstance("Permalink")

    Permalinkable = Instance(::Permalinkable)
  end
end
