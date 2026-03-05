# frozen_string_literal: true

module Types
  # @see Submittable
  module SubmittableType
    include Types::BaseInterface

    description <<~TEXT
    Entities can optionally be submitted to.
    TEXT

    field :submission_status, Types::EntitySubmissionStatusType, null: false do
      description <<~TEXT
      THe current submission status of this entity. Is it a draft, published, or unrelated?
      TEXT
    end

    field :submission_target, "::Types::SubmissionTargetType", null: true do
      description <<~TEXT
      The submission target that this entity can be submitted to, if any.
      TEXT
    end

    expose_authorization_rule :deposit?, <<~TEXT
    Whether the current user has permission to deposit a new entity into this one.
    TEXT

    expose_authorization_rule :review?, <<~TEXT
    Whether the current user has permission to review deposits to this entity.
    TEXT

    load_association! :submission_target
  end
end
