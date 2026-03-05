# frozen_string_literal: true

module Types
  # @see SubmissionDepositTarget
  # @see ::Types::SubmissionDepositTargetConnectionType
  # @see ::Types::SubmissionDepositTargetEdgeType
  class SubmissionDepositTargetType < Types::AbstractModel
    description <<~TEXT
    A submission deposit target defines an actual target
    entity for submissions. For instance, a `SubmissionTarget`
    might be defined on an `nglp:journal`, but it defines a
    `SubmissionDepositTarget` that points to an `nglp:journal_issue`.
    TEXT

    use_direct_connection_and_edge!

    field :deposit_mode, ::Types::SubmissionDepositModeType, null: false do
      description <<~TEXT
      The deposit mode of this submission deposit target. This indicates the relationship
      of the associated `entity` to this record's parent `SubmissionTarget`.
      TEXT
    end

    field :entity, "::Types::EntityType", null: false do
      description <<~TEXT
      The entity that this submission deposit target points to.
      TEXT
    end

    load_association! :entity
  end
end
