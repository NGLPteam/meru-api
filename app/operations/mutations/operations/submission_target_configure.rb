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
    end
  end
end
