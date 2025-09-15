# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::PermalinkCreate
  class PermalinkCreate < Mutations::MutatePermalink
    description <<~TEXT
    Create a single `Permalink` record.
    TEXT

    performs_operation! "mutations.operations.permalink_create"
  end
end
