# frozen_string_literal: true

module ControlledVocabularies
  # @see ControlledVocabularies::Lookup
  class Finder < Support::HookBased::Actor
    include Dry::Monads[:maybe]

    include Dry::Initializer[undefined: false].define -> do
      option :namespace, Types::String.optional, optional: true
      option :identifier, Types::String.optional, optional: true
      option :term, Types::String.optional, optional: true
      option :fallback, Types::String.optional, optional: true
      option :wants, Types::String.optional, optional: true
    end

    standard_execution!

    # @return [ControlledVocabulary, nil]
    attr_reader :vocabulary

    # @return [String]
    attr_reader :vocabulary_query

    # @return [ControlledVocabularyItem, nil]
    attr_reader :item

    # @return [Dry::Monads::Success(ControlledVocabularyItem)]
    # @return [Dry::Monads::Failure(:no_vocabulary)]
    # @return [Dry::Monads::Failure(:no_match)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield perform_lookup!
      end

      Success item
    end

    wrapped_hook! def prepare
      @vocabulary_query = find_vocabulary_query

      @vocabulary = find_vocabulary

      @item = nil

      super
    end

    wrapped_hook! def perform_lookup
      @item = yield find_item

      super
    end

    private

    # @return [Dry::Monads::Success(ControlledVocabularyItem)]
    # @return [Dry::Monads::Failure(:no_vocabulary)]
    # @return [Dry::Monads::Failure(:no_match)]
    def find_item
      return Failure(:no_vocabulary, vocabulary_query) if vocabulary.nil?

      find_item_by(term).or do
        # :nocov:
        find_item_by(fallback)
        # :nocov:
      end
    end

    def find_item_by(value)
      find_by_term_with(value).or do
        find_by_url_with(value).or do
          find_by_tag_with(value)
        end
      end.to_result.or do
        Failure(:no_match, term, fallback)
      end
    end

    # @param [String, nil] value
    def find_by_term_with(value)
      # :nocov:
      if ControlledVocabularies::Types::Identifier.valid?(value)
        Maybe(vocabulary.item_for(value))
      else
        None()
      end
      # :nocov:
    end

    # @param [String, nil] value
    def find_by_url_with(value)
      # :nocov:
      if ControlledVocabularies::Types::URL.valid?(value)
        Maybe(vocabulary.for_url(value))
      else
        None()
      end
      # :nocov:
    end

    # @param [String, nil] value
    def find_by_tag_with(value)
      # :nocov:
      if ControlledVocabularies::Types::Tag.valid?(value)
        Maybe(vocabulary.first_tagged_with(value))
      else
        None()
      end
      # :nocov:
    end

    def find_vocabulary
      if wants.present?
        ControlledVocabularySource.providing(wants)
      elsif namespace.present? && identifier.present?
        ControlledVocabulary.find_by(namespace:, identifier:)
      end
    end

    def find_vocabulary_query
      if wants.present?
        "wants=#{wants}"
      elsif namespace.present? && identifier.present?
        "namespace=#{namespace}, identifier=#{identifier}"
      else
        # :nocov:
        "missing vocabulary query"
        # :nocov:
      end
    end
  end
end
