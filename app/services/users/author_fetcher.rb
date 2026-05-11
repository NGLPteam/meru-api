# frozen_string_literal: true

module Users
  # @see Users::FetchAuthor
  class AuthorFetcher < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :user, Users::Types::User
    end

    standard_execution!

    # @return [Contributor]
    attr_reader :author

    # @return [Dry::Monads::Success(Contributor)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield maybe_create_default_author!
      end

      Success(author)
    end

    wrapped_hook! def prepare
      @author = user.primary_contributor

      super
    end

    wrapped_hook! def maybe_create_default_author
      return super if author.present?

      @author = yield user.create_default_author

      super
    end
  end
end
