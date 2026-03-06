# frozen_string_literal: true

module Shared
  # The shared type registry used by {ApplicationContract}.
  TypeRegistry = Support::Schemas::TypeContainer.new.configure do |tc|
    tc.add! :any_entity, Entities::Types::Entity
    tc.add! :contributable, Contributions::Types::Contributable
    tc.add! :current_user, ::Users::Types::Current
    tc.add! :harvest_target, ::Harvesting::Types::Target
    tc.add! :permalinkable, ::Permalinks::Types::Permalinkable
    tc.add! :provisional_access_grant, ::Access::Provisional::Type

    tc.add! :keycloak_client_id, ::Meru::Types::KeycloakClientID

    tc.add! :redirect_path, ::KeycloakAPI::Types::RedirectPath

    tc.add_model! "Collection"
    tc.add_model! "Community"
    tc.add_model! "Contributor"
    tc.add_model! "ControlledVocabulary"
    tc.add_model! "ControlledVocabularyItem"
    tc.add_model! "ControlledVocabularySource"
    tc.add_model! "DepositorRequest"
    tc.add_model! "HarvestAttempt"
    tc.add_model! "HarvestEntity"
    tc.add_model! "HarvestError"
    tc.add_model! "HarvestMapping"
    tc.add_model! "HarvestMetadataMapping"
    tc.add_model! "HarvestRecord"
    tc.add_model! "HarvestSet"
    tc.add_model! "HarvestSource"
    tc.add_model! "Item"
    tc.add_model! "Permalink"
    tc.add_model! "Role"
    tc.add_model! "SchemaDefinition"
    tc.add_model! "SchemaVersion"
    tc.add_model! "Submission"
    tc.add_model! "SubmissionComment"
    tc.add_model! "SubmissionReview"
    tc.add_model! "SubmissionTarget"
    tc.add_model! "SubmissionTargetReviewer"

    tc.add_enum! ::Types::ClientLocationType
    tc.add_enum! ::Types::DepositorRequestStateType
    tc.add_enum! ::Types::EntitySubmissionStatusType
    tc.add_enum! ::Types::HarvestMetadataFormatType
    tc.add_enum! ::Types::HarvestMetadataMappingFieldType
    tc.add_enum! ::Types::HarvestProtocolType
    tc.add_enum! ::Types::SubmissionCommentRoleType
    tc.add_enum! ::Types::SubmissionDepositModeType
    tc.add_enum! ::Types::SubmissionReviewStateType
    tc.add_enum! ::Types::SubmissionStateType
    tc.add_enum! ::Types::SubmissionTargetStateType
    tc.add_enum! ::Types::TemplateSlotKindType, single_key: "slot_kind", plural_key: "slot_kinds"
  end
end
