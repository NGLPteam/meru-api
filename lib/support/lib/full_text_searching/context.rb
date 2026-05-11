# frozen_string_literal: true

module Support
  module FullTextSearching
    # Configuration for a full-text searching context.
    #
    # @api private
    # @see ::HasFullTextSearching
    class Context
      include Support::Typing
      include Dry::Core::Equalizer.new(:name)
      include Dry::Initializer[undefined: false].define -> do
        param :name, Types::ContextName

        option :columns, Types::ColumnNames

        option :default_strategy, Types::Strategy, default: -> { "fuzzy" }

        option :base_scope, Types::ScopeName, default: -> { :"search_#{name}" }

        option :exact_scope, Types::ScopeName, default: -> { :"search_#{name}_via_exact" }

        option :fuzzy_scope, Types::ScopeName, default: -> { :"search_#{name}_via_fuzzy" }

        option :prefix_scope, Types::ScopeName, default: -> { :"search_#{name}_via_prefix" }

        option :fuzzy_dictionary, Types::String, default: -> { "english" }

        option :prefix_dictionary, Types::String, default: -> { "simple" }
      end

      map_type! key: Support::FullTextSearching::Types::ContextName

      COMMON_OPTIONS = {
        ignoring: :accents,
      }.freeze

      # @see https://www.postgresql.org/docs/current/textsearch-controls.html#TEXTSEARCH-RANKING
      DEFAULT_NORMALIZATION = 1 | 8 | 32

      def initialize(...)
        super

        @against = columns.map(&:to_sym)

        @fuzzy_options = build_fuzzy_options
        @prefix_options = build_prefix_options

        @scope_module = ::Support::FullTextSearching::ScopeModule.new(self)
      end

      # @return [<Symbol>]
      attr_reader :against

      # @return [Hash]
      attr_reader :fuzzy_options

      # @return [Hash]
      attr_reader :prefix_options

      # @return [Searching::ScopeModule]
      attr_reader :scope_module

      private

      # @return [Hash]
      def build_common_options = COMMON_OPTIONS.deep_dup.merge(against:)

      # @return [Hash]
      def build_fuzzy_options
        trigram = build_trigram_options
        tsearch = build_tsearch_options(websearch: true, dictionary: fuzzy_dictionary)

        using = {
          trigram:,
          tsearch:,
        }

        build_common_options.merge(
          using:,
        )
      end

      # @return [Hash]
      def build_prefix_options
        trigram = build_trigram_options
        tsearch = build_tsearch_options(prefix: true, dictionary: prefix_dictionary)

        using = {
          trigram:,
          tsearch:,
        }

        build_common_options.merge(
          using:,
        )
      end

      # @return [Hash]
      def build_trigram_options(word_similarity: true, **extra)
        {
          word_similarity:,
          **extra
        }
      end

      # @return [Hash]
      def build_tsearch_options(dictionary: "simple", normalization: DEFAULT_NORMALIZATION, **extra)
        {
          dictionary:,
          normalization:,
          **extra
        }
      end
    end
  end
end
