# frozen_string_literal: true

module Filtering
  # A container for all Meru-specific filtering types.
  class TypeContainer < Support::Filtering::TypeContainer
    add_models!(
      "Collection",
      "Community",
      "Contributor",
      "ControlledVocabulary",
      "DepositorRequest",
      "HarvestSource",
      "Item",
      "Permalink",
      "Role",
      "SchemaDefinition",
      "SchemaVersion",
      "Submission",
      "SubmissionComment",
      "SubmissionReview",
      "SubmissionTarget",
      "SubmissionTargetReviewer"
    )

    add_enum_types!(
      ::Types::DepositorRequestStateType,
      ::Types::HarvestMessageLevelType,
      ::Types::SubmissionCommentRoleType,
      ::Types::SubmissionDepositModeType,
      ::Types::SubmissionReviewStateType,
      ::Types::SubmissionStateType,
      ::Types::SubmissionTargetStateType
    )

    # @return [void]
    compile! def add_interfaces!
      add! :any_entity, ::Entities::Types::Entity.gql_loads("::Types::EntityType")

      add! :any_entities, ::Entities::Types::Entities.gql_loads("::Types::EntityType")

      add! :child_entity, ::Entities::Types::Entity.gql_loads("::Types::ChildEntityType")
    end
  end
end
