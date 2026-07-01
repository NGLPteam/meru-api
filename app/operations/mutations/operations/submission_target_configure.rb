# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionTargetConfigure
    class SubmissionTargetConfigure
      include MutationOperations::Base

      use_contract! :submission_target_configure

      authorizes! :configurable, with: :update?

      # @param [SubmissionTarget, HierarchicalEntity] configurable
      # @param [{ Symbol => Object }] attrs
      # @return [void]
      def call(configurable:, **attrs)
        result = configurable.configure_submission_target(**attrs)

        with_attached_result!(:submission_target, result)
      end

      before_prepare def extract_configurable_parts
        args[:entity], args[:submission_target] =
          case args[:configurable]
          in SubmissionTarget => submission_target
            [submission_target.entity, submission_target]
          in HierarchicalEntity => entity
            [entity, entity.fetch_submission_target!]
          else
            # simplecov:disable
            raise "Unexpected configurable type: #{inputs[:configurable].class}"
            # simplecov:enable
          end
      end
    end
  end
end
