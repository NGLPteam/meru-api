# frozen_string_literal: true

module Mutations
  module Operations
    class UpsertContribution
      include MutationOperations::Base

      use_contract! :upsert_contribution

      authorizes! :contributable, with: :update?

      def call(contributable:, contributor:, **inputs)
        result = contributable.attach_contribution(contributor, **inputs)

        with_attached_result! :contribution, result
      end
    end
  end
end
