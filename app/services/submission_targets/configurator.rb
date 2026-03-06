# frozen_string_literal: true

module SubmissionTargets
  # @see SubmissionTargets::Configure
  class Configurator < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :configurable, SubmissionTargets::Types::Configurable

      option :deposit_mode, SubmissionTargets::Types::DepositMode, default: -> { "direct" }

      option :deposit_targets, SubmissionTargets::Types::DepositTargets, default: -> { [] }

      option :schema_versions, SubmissionTargets::Types::SchemaVersions, default: -> { [] }

      option :agreement_content, Types::String, optional: true

      option :agreement_required, Types::Params::Bool, default: -> { false }

      option :description, Types::Hash, default: -> { {} }
    end

    standard_execution!

    # @return [HierarchicalEntity]
    attr_reader :entity

    # @return [SubmissionTarget]
    attr_reader :submission_target

    # @return [Dry::Monads::Success(SubmissionTarget)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield persist!
      end

      Success submission_target
    end

    wrapped_hook! def prepare
      @entity, @submission_target = extract_configurable

      @attrs = {
        deposit_mode:,
        agreement_content:,
        agreement_required:,
        description:,
      }

      super
    end

    wrapped_hook! def persist
      submission_target.save!

      deposit_targets.each do |entity|
        submission_target.submission_deposit_targets.where(entity).first_or_create!
      end

      submission_target.submission_deposit_targets.where.not(entity: deposit_targets).destroy_all

      submission_target.schema_versions = schema_versions

      submission_target.save!

      super
    end

    private

    # @return [(HierarchicalEntity, SubmissionTarget)]
    def extract_configurable
      case configurable
      in SubmissionTarget => submission_target
        [submission_target.entity, submission_target]
      else
        [configurable, configurable.fetch_submission_target!]
      end
    end
  end
end
