# frozen_string_literal: true

module Users
  # @see Users::CreateDefaultAuthor
  class DefaultAuthorCreator < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :user, Users::Types::User
    end

    standard_execution!

    # @return [Contributor]
    attr_reader :contributor

    # @return [String]
    attr_reader :identifier

    # @return [ContributorUserLink]
    attr_reader :user_link

    # @return [Dry::Monads::Success(Contributor)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield persist!
      end

      Success user.reload_primary_contributor
    end

    wrapped_hook! def prepare
      @identifier = user.keycloak_id

      @contributor = Contributor.where(identifier:).first_or_initialize

      @contributor.kind = :person

      @contributor.identifier = user.keycloak_id

      @contributor.properties = build_properties

      @user_link = nil

      super
    end

    wrapped_hook! def persist
      contributor.save!

      @user_link = yield contributor.link_user(user)

      super
    end

    private

    # @return [Contributors::Properties]
    def build_properties
      person = build_person_properties

      Contributors::Properties.new(person:)
    end

    # @return [Contributors::PersonProperties]
    def build_person_properties
      Contributors::PersonProperties.new(
        given_name: user.given_name,
        family_name: user.family_name,
      )
    end
  end
end
