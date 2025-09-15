# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::PermalinkDestroy
    class PermalinkDestroy
      include MutationOperations::Base

      authorizes! :permalink, with: :destroy?

      use_contract! :permalink_destroy

      # @param [Permalink] permalink
      # @return [void]
      def call(permalink:)
        destroy_model! permalink, auth: true
      end
    end
  end
end
