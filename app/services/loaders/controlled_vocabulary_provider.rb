# frozen_string_literal: true

module Loaders
  # Load the {ControlledVocabulary} for a given wants / provides value.
  #
  # @see ControlledVocabularySource
  class ControlledVocabularyProvider < GraphQL::Batch::Loader
    # @param [String] provides
    def load(provides)
      super(provides.to_s)
    end

    # @param [<String>] keys
    # @return [void]
    def perform(keys)
      query(keys).each do |source|
        key = source.provides

        # simplecov:disable
        next if fulfilled? key
        # simplecov:enable

        fulfill key, source.controlled_vocabulary
      end
    end

    def query(provides)
      ControlledVocabularySource.where(provides:).preload(:controlled_vocabulary)
    end
  end
end
