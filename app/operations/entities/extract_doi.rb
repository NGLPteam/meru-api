# frozen_string_literal: true

module Entities
  # Given variable input, try to extract a DOI from it and return
  # a more useful {Entities::DOIReference}.
  class ExtractDOI
    include Dry::Monads[:do, :result]

    QUACKS_DOI = Entities::Types.Interface(:doi)

    # @param [ChildEntity, String, #doi] input
    # @return [Dry::Monads::Success(Entities::DOIReference)]
    # @return [Dry::Monads::Failure(:invalid_doi, Object)]
    def call(input)
      return Success(input) if input.kind_of?(Entities::DOIReference)

      doi, host = yield extract input

      reference = Entities::DOIReference.new(doi:, host:)

      Success reference
    end

    private

    # @param [ChildEntity, String, #doi] input
    # @return [Dry::Monads::Success(Entities::Types::DOI, String)]
    # @return [Dry::Monads::Failure(:invalid_doi, Object)]
    def extract(input, host: nil)
      case input
      when Entities::Types::DOI
        Success([input, host])
      when Entities::Types::DOI_URL_PATTERN
        extract(Regexp.last_match[:doi])
      when Entities::Types::URL
        extract_from_other_url(input)
      when ChildEntity
        extract(input.raw_doi)
      when QUACKS_DOI
        extract(input.doi)
      else
        Failure()
      end.or do
        # Ensure that the _original_ value is what we return.
        Failure[:invalid_doi, input]
      end
    end

    def extract_from_other_url(input)
      uri = URI(input)

      host = uri.host

      extract(uri.path&.delete_prefix(?/), host:)
    rescue URI::Error
      # simplecov:disable
      extract(nil)
      # simplecov:enable
    end
  end
end
