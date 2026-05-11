# frozen_string_literal: true

module Users
  # @see Users::AuthorFetcher
  class FetchAuthor < Support::SimpleServiceOperation
    service_klass Users::AuthorFetcher
  end
end
