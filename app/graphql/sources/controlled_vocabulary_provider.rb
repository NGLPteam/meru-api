# frozen_string_literal: true

module Sources
  class ControlledVocabularyProvider < GraphQL::Dataloader::Source
    # @param [Array<String>] wants
    def fetch(wants)
      wants.map { ControlledVocabularySource.providing(_1) }
    end
  end
end
