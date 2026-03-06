# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionTargetConfigure
    # @see Mutations::Operations::SubmissionTargetConfigure
    class SubmissionTargetConfigure < MutationOperations::Contract
      json do
        required(:configurable).value(::SubmissionTargets::Types::Configurable)
        required(:deposit_mode).value(:submission_deposit_mode)
        required(:deposit_targets).array(:any_entity)
        required(:schema_versions).array(:schema_version) { filled? }
        optional(:agreement_content).maybe(:string)
        required(:agreement_required).value(:bool)
        required(:description).hash do
          optional(:internal).maybe(:string)
          optional(:instructions).maybe(:string)
          required(:sections).array(:hash) do
            required(:name).filled(:string)
            required(:content).filled(:string)
          end
        end
      end

      rule(:agreement_content) do
        key.failure(:filled?) if values[:agreement_required] && value.blank?
      end

      rule(:deposit_targets) do
        case values[:deposit_mode]
        when "direct"
          key.failure(:must_be_empty) if value.present?
        when "descendant"
          key.failure(:filled?) if value.empty?
        end
      end

      rule(:deposit_targets).each do
        parent_entity =
          case values[:configurable]
          in HierarchicalEntity => entity
            entity
          in SubmissionTarget => submission_target
            submission_target.entity
          else
            # :nocov:
            raise "Unexpected configurable type: #{values[:configurable].class}"
            # :nocov:
          end

        key.failure(:must_be_descendant) unless value.hierarchical_descendant_of?(parent_entity)
      end

      rule(:schema_versions).each do
        key.failure(:must_be_child_entity_schema) if value.community?
      end
    end
  end
end
