# frozen_string_literal: true

module Mutations
  # @abstract
  # @see Mutations::CreatePermalink
  # @see Mutations::UpdatePermalink
  class MutatePermalink < Mutations::BaseMutation
    description <<~TEXT
    A base mutation that is used to share fields between `createPermalink` and `updatePermalink`.
    TEXT

    field :permalink, Types::PermalinkType, null: true do
      description <<~TEXT
      The newly-modified permalink, if successful.
      TEXT
    end

    argument :permalinkable_id, ID, loads: ::Types::PermalinkableType, required: true do
      description <<~TEXT
      The ID of the resource to which this permalink will belong.

      It can be changed.
      TEXT
    end

    argument :uri, String, required: true do
      description <<~TEXT
      The URI for the permalink.

      It is case-insensitive and must be unique system-wide.

      It may only contain letters, numbers, and hyphens.
      It may not begin nor end with a hyphen, nor contain consecutive hyphens.
      TEXT
    end

    argument :canonical, Boolean, required: false, default_value: false, replace_null_with_default: true do
      description <<~TEXT
      Whether this permalink should be the canonical permalink for its resource.

      If true, any existing canonical permalink for the resource will be demoted to a non-canonical permalink.
      TEXT
    end
  end
end
