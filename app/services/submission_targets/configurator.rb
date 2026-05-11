# frozen_string_literal: true

module SubmissionTargets
  # @see SubmissionTargets::Configure
  class Configurator < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :configurable, SubmissionTargets::Types::Configurable

      option :entity, SubmissionTargets::Types::Entity, default: -> do
        case configurable
        in HierarchicalEntity then configurable
        in SubmissionTarget then configurable.entity
        else
          # :nocov:
          raise "Unexpected configurable type: #{configurable.class}"
          # :nocov:
        end
      end

      option :submission_target, SubmissionTargets::Types::SubmissionTarget, default: -> do
        case configurable
        in SubmissionTarget
          configurable
        in HierarchicalEntity
          configurable.fetch_submission_target!
        else
          # :nocov:
          raise "Unexpected configurable type: #{configurable.class}"
          # :nocov:
        end
      end

      option :deposit_mode, SubmissionTargets::Types::DepositMode, default: -> { submission_target.deposit_mode }

      option :deposit_targets, SubmissionTargets::Types::DepositTargets, default: -> { submission_target.deposit_targets }

      option :schema_versions, SubmissionTargets::Types::SchemaVersions, default: -> { submission_target.schema_versions }

      option :agreement_content, Types::String, default: proc { submission_target.agreement_content }

      option :agreement_required, Types::Params::Bool, default: -> { submission_target.agreement_required }

      option :auto_approve_depositors, Types::Params::Bool, default: -> { submission_target.auto_approve_depositors }

      option :description, Types::Hash, default: -> { submission_target.description.as_json || Dry::Core::Constants::EMPTY_HASH }
    end

    standard_execution!

    # @return [Dry::Monads::Success(SubmissionTarget)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield persist!
      end

      Success submission_target
    end

    wrapped_hook! def prepare
      attrs = {
        deposit_mode:,
        agreement_content:,
        agreement_required:,
        auto_approve_depositors:,
        description:,
      }

      submission_target.assign_attributes(attrs)

      super
    end

    wrapped_hook! def persist
      submission_target.save!

      deposit_targets.each do |entity|
        submission_target.submission_deposit_targets.where(entity:).first_or_create!
      end

      submission_target.submission_deposit_targets.where.not(entity: deposit_targets).destroy_all

      submission_target.schema_versions = schema_versions

      submission_target.save!

      super
    end
  end
end
