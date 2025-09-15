# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::PermalinkCreate
    class PermalinkCreate
      include MutationOperations::Base

      authorizes! :permalink, with: :create?

      use_contract! :permalink_create
      use_contract! :mutate_permalink

      # @param [Permalink] permalink
      # @param [Permalinkable] permalinkable
      # @param [String] uri
      # @param [Boolean] canonical
      # @return [void]
      def call(permalink:, permalinkable:, uri:, canonical:, **)
        assign_attributes!(permalink, permalinkable:, uri:, canonical:)

        persist_model! permalink, attach_to: :permalink
      end

      # @return [void]
      before_prepare def initialize_permalink!
        args => { permalinkable:, uri: }

        args[:permalink] = Permalink.new(permalinkable:, uri:)
      end
    end
  end
end
