# frozen_string_literal: true

module Protocols
  module Pressbooks
    module Books
      class Response < AbstractResponse
        include Enumerable
        include Protocols::Pressbooks::PaginatedResponse

        before_initialize :prepare_books!

        after_initialize :enrich_books!

        # @return [<Metadata::Pressbooks::Books::Record>]
        attr_reader :books

        # @return [Enumerator<Metadata::Pressbooks::Books::Record>]
        def each
          # simplecov:disable
          return enum_for(__method__) unless block_given?
          # simplecov:enable

          books.each do |book|
            yield book
          end
        end

        private

        # @param [Hash] book
        # @return [Metadata::Pressbooks::Books::Record]
        def enrich(book)
          book = ::Metadata::Pressbooks::Entries::Book.from_json(book.to_json)

          id = book.id

          metadata = wrap_into ::Metadata::Pressbooks::Books::FullMetadata, book.full_metadata_url

          toc = wrap_into ::Metadata::Pressbooks::Books::TOC, book.toc_url

          Metadata::Pressbooks::Books::Record.from_hash(id:, book:, metadata:, toc:)
        end

        # @param [Class(Metadata::Pressbooks::Common::AbstractMapper)] klass
        # @param [String, nil] url
        # @return [Metadata::Pressbooks::Common::AbstractMapper, nil]
        def wrap_into(klass, url)
          # simplecov:disable
          return if url.blank?
          # simplecov:enable

          response = client.http.get(url)

          klass.from_json(response.body.to_json)
        end

        # @return [void]
        def enrich_books!
          parsed_body.each do |book|
            @books << enrich(book)
          end
        end

        # @return [void]
        def prepare_books!
          @books = []
        end
      end
    end
  end
end
