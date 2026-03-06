# frozen_string_literal: true

module Submissions
  # @see Submissions::ConstructDraftEntity
  class DraftEntityFactory < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :submission, Submissions::Types::Submission
    end

    standard_execution!

    delegate :kind, :parent_entity, :schema_version, :title, to: :submission

    delegate :entity, to: :submission, prefix: :current

    # @return [ActiveRecord::Relation<HierarchicalEntity>]
    attr_reader :entity_scope

    # @return [HierarchicalEntity]
    attr_reader :draft

    # @return [Dry::Monads::Success(HierarchicalEntity)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield persist!
      end

      Success draft
    end

    wrapped_hook! def prepare
      @entity_scope = parent_entity.try(:child_scope_for, kind) || Collection.none

      @draft = entity_scope.build(
        title:,
        schema_version:,
        submission_status: "submission_draft",
      )

      super
    end

    wrapped_hook! def persist
      # :nocov:
      return super if current_entity.present? || parent_entity.blank?
      # :nocov:

      draft.save!

      submission.entity = draft

      submission.save!

      super
    end
  end
end
