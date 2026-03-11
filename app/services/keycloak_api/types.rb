# frozen_string_literal: true

module KeycloakAPI
  module Types
    extend ::Support::Typespace

    ClientID = String

    # A selection of required actions we may eventually use. As of now, just update password.
    #
    # @see https://www.keycloak.org/docs-api/latest/javadocs/org/keycloak/authentication/requiredactions/package-summary.html
    EmailAction = Coercible::String.enum(
      "CONFIGURE_TOTP",
      "TERMS_AND_CONDITIONS",
      "UPDATE_PASSWORD",
      "UPDATE_PROFILE",
      "VERIFY_EMAIL"
    )

    # @see EmailAction
    EmailActions = Coercible::Array.of(EmailAction)

    KeycloakID = String.constrained(uuid_v4: true)

    Lifespan = Integer | Instance(::ActiveSupport::Duration) | Interface(:seconds)

    REDIRECT_PATH_FORMAT = %r,\A/(?:[a-z0-9_-]+/?)*?(?:(?<!/)/)?\z,i

    RedirectPath = String.constrained(format: REDIRECT_PATH_FORMAT)

    RedirectURI = String.constrained(http_uri: true)
  end
end
