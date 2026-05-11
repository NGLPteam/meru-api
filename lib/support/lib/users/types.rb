# frozen_string_literal: true

module Support
  module Users
    # Types related to users, whether authenticated or anonymous.
    #
    # @see ::AnonymousUser
    # @see ::User
    module Types
      extend Support::Typespace

      # A proc that returns a default {AnonymousUser}
      DEFAULT = proc { AnonymousUser.new }

      # A proc that returns the current user from the request context,
      # or falls back to an {AnonymousUser} if none is present.
      # @see DEFAULT
      DEFAULT_FROM_REQUEST = proc do
        ::Support::Requests::Current.current_user || DEFAULT.()
      end

      # A type matching a {User}
      Authenticated = ModelInstance("User")

      Anonymous = Any.constrained(anonymous_user: true)

      # This is a type that will ensure a {User} is populated, and if not provided,
      # nil, or otherwise invalid, it will fall back to an {AnonymousUser}.
      Current = (Authenticated | Anonymous).fallback do
        ::AnonymousUser.new
      end.default(&DEFAULT_FROM_REQUEST)

      # A schema representing a Keycloak user profile.
      KeycloakProfile = Hash.schema(
        given_name?: Types::String,
        family_name?: Types::String,
        email?: Types::String,
        username?: Types::String
      )

      # An enum switching on the state of a user's authentication.
      State = Symbol.enum(:anonymous, :authenticated).constructor do |value|
        case value
        when Authenticated then :authenticated
        else
          :anonymous
        end
      end

      # A type matching an authenticated {User} (@see Authenticated).
      User = Authenticated
    end
  end
end
