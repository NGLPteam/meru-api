# frozen_string_literal: true

# A concern for records that implement full-text search.
module FullTextSearchable
  extend ActiveSupport::Concern

  include PgSearch::Model

  included do
    extend Dry::Core::ClassAttributes

    defines :search_contexts, type: ::Support::FullTextSearching::Context::Map

    search_contexts Dry::Core::Constants::EMPTY_HASH
  end

  module ClassMethods
    # @param [Symbol] context_name the name of the search context to define
    # @param [<Symbol>] columns the columns to include in the search context
    # @return [void]
    def full_text_searchable_with!(*columns, name: nil, **options)
      name = name.presence || columns.to_sentence.parameterize(separator: ?_)

      context = ::Support::FullTextSearching::Context.new(name, **options, columns:)

      extend context.scope_module

      add_search_context!(context)
    end

    private

    # @param [::Support::FullTextSearching::Context] context the search context to add to this model's search contexts
    # @return [void]
    def add_search_context!(context)
      contexts = search_contexts.merge(context.name => context)

      search_contexts contexts.freeze
    end
  end
end
