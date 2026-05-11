# frozen_string_literal: true

module Types
  class ContributorMergeTargetStatusType < Types::BaseEnum
    description <<~TEXT
    The merge status of a `Contributor` in the context of being a merge target.
    TEXT

    value "INACTIVE", value: "inactive" do
      description <<~TEXT
      The contributor is not currently the target of a merge.
      TEXT
    end

    value "ACTIVE", value: "active" do
      description <<~TEXT
      The contributor is currently the target of one or more merge(s).
      TEXT
    end
  end
end
