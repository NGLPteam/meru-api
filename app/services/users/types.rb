# frozen_string_literal: true

module Users
  # Types related to users, whether authenticated or anonymous.
  #
  # @see ::AnonymousUser
  # @see ::User
  # @see ::Support::Users::Types
  module Types
    extend Support::Typespace

    include Support::Users::Types

    # A type representing an access management enum.
    AccessManagement = ApplicationRecord.dry_pg_enum("access_management", default: "forbidden").fallback("forbidden")
  end
end
