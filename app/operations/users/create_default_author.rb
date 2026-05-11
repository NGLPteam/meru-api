# frozen_string_literal: true

module Users
  # @see Users::DefaultAuthorCreator
  class CreateDefaultAuthor < Support::SimpleServiceOperation
    service_klass Users::DefaultAuthorCreator
  end
end
