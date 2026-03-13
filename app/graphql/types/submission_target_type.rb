# frozen_string_literal: true

module Types
  # @see SubmissionTarget
  # @see ::Types::SubmissionTargetConnectionType
  # @see ::Types::SubmissionTargetEdgeType
  class SubmissionTargetType < Types::AbstractModel
    description <<~TEXT
    A submission target is a subject of an `Entity`, specifying information about whether
    or not it can have new entities deposited to it.
    TEXT

    use_direct_connection_and_edge!

    field :state, Types::SubmissionTargetStateType, null: false do
      description <<~TEXT
      The current state of this submission target, which determines whether or not it can accept deposits.
      TEXT
    end

    field :depositor_agreement, "Types::DepositorAgreementType", null: true do
      description <<~TEXT
      The depositor agreement for this submission target and the current user, if one exists.
      TEXT
    end

    field :deposit_mode, Types::SubmissionDepositModeType, null: false do
      description <<~TEXT
      The deposit mode of this submission target, which determines how deposits to it are handled.
      TEXT
    end

    field :deposit_targets, ["::Types::SubmissionDepositTargetType", { null: false }], null: false do
      description <<~TEXT
      The deposit targets of this submission target, which are the entities that deposits to this submission target are deposited to.
      TEXT
    end

    field :entity, "::Types::EntityType", null: false do
      description <<~TEXT
      The entity that this submission target belongs to.
      TEXT
    end

    field :schema_versions, [Types::SchemaVersionType, { null: false }], null: false do
      description <<~TEXT
      The schema versions that deposits to this submission target must conform to.
      TEXT
    end

    field :agreement_content, String, null: true do
      description <<~TEXT
      The content of the agreement that must be agreed to before depositing to this submission target, if `agreementRequired` is `true`.
      TEXT
    end

    field :agreement_required, Boolean, null: false do
      description <<~TEXT
      Whether or not this submission target requires agreement to an agreement before depositing.
      TEXT
    end

    field :allowed_child_kinds, [Types::ChildEntityKindType, { null: false }], null: false do
      description <<~TEXT
      The kinds of child entities that can be deposited to this submission target.
      TEXT
    end

    field :description, ::Types::SubmissionTargetDescriptionType, null: false do
      description <<~TEXT
      A description of this submission target, which may include a human-readable title and/or a machine-readable schema.org description.
      TEXT
    end

    field :transitions, resolver: ::Resolvers::SubmissionTargetTransitionResolver, null: false do
      description <<~TEXT
      The state transitions that this submission target has undergone.
      TEXT
    end

    expose_authorization_rule :deposit?, <<~TEXT
    Whether or not the current user can deposit to this submission target.
    TEXT

    expose_authorization_rule :manage_reviewers?, <<~TEXT
    Whether or not the current user can manage reviewers for this submission target.
    TEXT

    expose_authorization_rule :publish?, <<~TEXT
    Whether or not the current user can publish submissions to this submission target.
    TEXT

    expose_authorization_rule :request_deposit_access?, <<~TEXT
    Whether or not the current user can request access to deposit to this submission target.
    TEXT

    expose_authorization_rule :reset_all_agreements?, <<~TEXT
    Whether or not the current user can reset all agreements for this submission target.
    TEXT

    expose_authorization_rule :review?, <<~TEXT
    Whether or not the current user can review this submission target.
    TEXT

    load_association! :entity

    load_association! :schema_versions

    load_association! :submission_deposit_targets, as: :deposit_targets

    # @return [DepositorAgreement, nil]
    def depositor_agreement
      load_record_with(::DepositorAgreement, object.id, find_by: :submission_target_id, where: { user: context[:current_user].authenticated })
    end
  end
end
