# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::PermalinkUpdate
    class PermalinkUpdate
      include MutationOperations::Base

      authorizes! :permalink, with: :update?

      use_contract! :permalink_update
      use_contract! :mutate_permalink

      # @param [Permalink] permalink
      # @param [{ Symbol => Object }] attrs
      # @return [void]
      def call(permalink:, **attrs)
        assign_attributes!(permalink, **attrs)

        persist_model! permalink, attach_to: :permalink
      end
    end
  end
end
