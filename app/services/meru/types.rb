# frozen_string_literal: true

module Meru
  module Types
    include Dry.Types

    extend Support::EnhancedTypes

    ClientLocation = ::Types::ClientLocationType.dry_type

    # Client ids used on the admin and frontend applications.
    KeycloakClientID = Coercible::String.default("meru-public").enum("meru-public", "meru-confidential")
  end
end
