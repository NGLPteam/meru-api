# frozen_string_literal: true

module Types
  class ContributorMergeSourceStatusType < Types::BaseEnum
    description <<~TEXT
    The merge status of a `Contributor` in the context of being a merge source.

    Merging contributors happens in the background, so this
    is useful to display when a contributor is in the process of being merged,
    or if a merge has been completed but the source contributor has not yet been
    deleted.
    TEXT

    value "UNMERGED", value: "unmerged" do
      description <<~TEXT
      The contributor is not currently being merged to another.
      TEXT
    end

    value "MERGING", value: "merging" do
      description <<~TEXT
      The contributor is in the process of being merged to another.
      TEXT
    end

    value "MERGED", value: "merged" do
      description <<~TEXT
      The contributor has been merged and is awaiting deletion.
      TEXT
    end
  end
end
