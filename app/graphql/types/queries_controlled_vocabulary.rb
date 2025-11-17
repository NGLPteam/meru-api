# frozen_string_literal: true

module Types
  # An interface for querying {ControlledVocabulary}.
  module QueriesControlledVocabulary
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `ControlledVocabulary` records.
    TEXT

    field :controlled_vocabulary, ::Types::ControlledVocabularyType, null: true do
      description <<~TEXT
      Retrieve a single `ControlledVocabulary` by slug.
      TEXT

      argument :slug, Types::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    field :controlled_vocabularies, resolver: ::Resolvers::ControlledVocabularyResolver

    # @param [String] slug
    # @return [ControlledVocabulary, nil]
    def controlled_vocabulary(slug:)
      load_record_with(::ControlledVocabulary, slug)
    end
  end
end
