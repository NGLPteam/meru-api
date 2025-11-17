# frozen_string_literal: true

module Types
  # An interface for querying {ControlledVocabularySource}.
  module QueriesControlledVocabularySource
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `ControlledVocabularySource` records.
    TEXT

    field :controlled_vocabulary_source, ::Types::ControlledVocabularySourceType, null: true do
      description <<~TEXT
      Retrieve a single `ControlledVocabularySource` by slug.
      TEXT

      argument :slug, Types::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    field :controlled_vocabulary_sources, resolver: ::Resolvers::ControlledVocabularySourceResolver

    # @param [String] slug
    # @return [ControlledVocabularySource, nil]
    def controlled_vocabulary_source(slug:)
      load_record_with(::ControlledVocabularySource, slug)
    end
  end
end
