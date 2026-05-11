# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::ContributorMerge
    class ContributorMerge
      include MutationOperations::Base

      use_contract! :contributor_merge

      authorizes! :source, with: :merge_source?
      authorizes! :target, with: :merge_target?

      # @param [Contributor] source
      # @param [Contributor] target
      # @return [void]
      def call(source:, target:, **)
        check_result!(source.merge_to(target, enqueue_merge_job: true))

        attach! :source, source.reload
        attach! :target, target.reload
      end
    end
  end
end
