# frozen_string_literal: true

module Contributors
  # @see Contributors::LinkUser
  class UserLinker < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :contributor, Types::Contributor

      param :user, Types::User

      option :linkage, Types::UserLinkage, default: proc { "primary" }
    end

    standard_execution!

    # @return [ContributorUserLink]
    attr_reader :link

    # @return [Dry::Monads::Success(ContributorUserLink)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield persist!
      end

      Success link
    end

    wrapped_hook! def prepare
      @link = ContributorUserLink.where(contributor:).first_or_initialize

      super
    end

    wrapped_hook! def persist
      @link.assign_attributes(user:, linkage:)

      @link.save!

      super
    end
  end
end
