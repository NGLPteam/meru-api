# frozen_string_literal: true

module Users
  # Types related to users, whether authenticated or anonymous.
  #
  # @see ::AnonymousUser
  # @see ::User
  module Types
    include Dry.Types

    AccessManagement = ApplicationRecord.dry_pg_enum("access_management", default: "forbidden").fallback("forbidden")

    # A type matching a {User}
    Authenticated = Instance(::User)

    # A type matching an {AnonymousUser}
    Anonymous = Instance(::AnonymousUser)

    # A proc that returns a default {AnonymousUser}
    DEFAULT = proc { AnonymousUser.new }

    # This is a type that will ensure a {User} is populated, and if not provided,
    # nil, or otherwise invalid, it will fall back to an {AnonymousUser}.
    Current = (Authenticated | Anonymous).fallback do
      ::AnonymousUser.new
    end.default(&DEFAULT)

    # An enum switching on the state of a user's authentication.
    State = Symbol.enum(:anonymous, :authenticated).constructor do |value|
      case value
      when Authenticated then :authenticated
      else
        :anonymous
      end
    end
  end
end
