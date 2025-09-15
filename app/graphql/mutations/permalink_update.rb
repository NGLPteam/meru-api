# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::PermalinkUpdate
  class PermalinkUpdate < Mutations::MutatePermalink
    description <<~TEXT
    Update a single `Permalink` record.
    TEXT

    argument :permalink_id, ID, loads: Types::PermalinkType, required: true do
      description <<~TEXT
      The permalink to update.
      TEXT
    end

    performs_operation! "mutations.operations.permalink_update"
  end
end
