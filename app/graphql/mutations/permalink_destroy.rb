# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::PermalinkDestroy
  class PermalinkDestroy < Mutations::BaseMutation
    description <<~TEXT
    Destroy a single `Permalink` record.
    TEXT

    argument :permalink_id, ID, loads: Types::PermalinkType, required: true do
      description <<~TEXT
      The permalink to destroy.
      TEXT
    end

    performs_operation! "mutations.operations.permalink_destroy", destroy: true
  end
end
