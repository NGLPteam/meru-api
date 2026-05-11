# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::ContributorMerge
  class ContributorMerge < Mutations::BaseMutation
    description <<~TEXT
    Merge two contributors.

    The actual merging will occur in the background after a delay, but the source
    contributor will be marked as `MERGING` immediately.
    TEXT

    field :source, Types::ContributorType, null: true do
      description <<~TEXT
      The contributor being merged, if successful.
      TEXT
    end

    field :target, Types::ContributorType, null: true do
      description <<~TEXT
      The contributor being merged into, if successful.
      TEXT
    end

    argument :source_id, ID, loads: Types::ContributorType, required: true do
      description <<~TEXT
      The ID of the contributor to merge.
      TEXT
    end

    argument :target_id, ID, loads: Types::ContributorType, required: true do
      description <<~TEXT
      The ID of the contributor to merge into.
      TEXT
    end

    performs_operation! "mutations.operations.contributor_merge"
  end
end
