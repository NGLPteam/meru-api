# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionTargetConfigure
  class SubmissionTargetConfigure < Mutations::BaseMutation
    description <<~TEXT
    Update a single `SubmissionTarget` record.
    TEXT

    field :submission_target, Types::SubmissionTargetType, null: true do
      description <<~TEXT
      The newly-modified submission target, if successful.
      TEXT
    end

    argument :configurable_id, ID, loads: ::Types::AnyConfigurableSubmissionTargetType, required: true do
      description <<~TEXT
      The ID of the entity or submission target to configure.

      This may be the ID of a `SubmissionTarget` or of an entity that can
      be configured with a `SubmissionTarget` (i.e. a `Community`, `Collection`, or `Item`).
      TEXT
    end

    argument :deposit_mode, Types::SubmissionDepositModeType, required: false, default_value: "direct", replace_null_with_default: true do
      description <<~TEXT
      The deposit mode for this submission target, which determines how submissions to this target are deposited.
      TEXT
    end

    argument :deposit_target_ids, [ID, { null: false }], loads: Types::EntityType, required: false, default_value: Dry::Core::Constants::EMPTY_ARRAY, replace_null_with_default: true do
      description <<~TEXT
      A list of deposit targets for this submission target.

      It should be left empty when `depositMode` is `DIRECT`,
      and must have at least one descendant when `depositMode` is `DESCENDANTS`.
      TEXT
    end

    argument :schema_version_ids, [ID, { null: false }], loads: Types::SchemaVersionType, required: false, default_value: Dry::Core::Constants::EMPTY_ARRAY, replace_null_with_default: true do
      description <<~TEXT
      A list of schema versions that submissions to this submission target must conform to.

      Must be at least one.
      TEXT
    end

    argument :agreement_content, String, required: false do
      description <<~TEXT
      The content of the agreement that submitters must accept when making a submission to this submission target.
      TEXT
    end

    argument :agreement_required, Boolean, required: false, default_value: false, replace_null_with_default: true do
      description <<~TEXT
      Whether submitters must accept an agreement when making a submission to this submission target.

      If true, `agreementContent` must be non-empty.
      TEXT
    end

    argument :description, Types::SubmissionTargetDescriptionInputType, required: true do
      description <<~TEXT
      A description of this submission target, which may be displayed to submitters when making a submission to this target.
      TEXT
    end

    performs_operation! "mutations.operations.submission_target_configure"
  end
end
