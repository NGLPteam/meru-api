# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::ControlledVocabularyUpsert
    class ControlledVocabularyUpsert
      include MutationOperations::Base

      use_contract! :controlled_vocabulary_upsert

      # @param [ControlledVocabulary] controlled_vocabulary
      # @param [{ Symbol => Object }] attrs
      # @return [void]
      def call(definition:, select_provider: false, **)
        authorize ControlledVocabulary.new, :update?

        with_called_operation!("controlled_vocabularies.upsert", definition) do |m|
          m.success do |controlled_vocabulary|
            attach! :controlled_vocabulary, controlled_vocabulary

            controlled_vocabulary.select_provider! if select_provider
          end

          m.failure do
            # simplecov:disable
            add_global_error! "Something went wrong"
            # simplecov:enable
          end
        end
      end
    end
  end
end
