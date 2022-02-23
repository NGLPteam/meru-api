# frozen_string_literal: true

module Access
  class Grant
    include Dry::Monads[:result, :do]
    include WDPAPI::Deps[
      assign_global_permissions: "access.assign_global_permissions"
    ]

    # @param [Role] role
    # @param [Accessible] on
    # @param [AccessGrantSubject] to
    # @return [Dry::Monads::Result]
    def call(role, on:, to:)
      return Success(nil) if AccessGrant.has_granted?(role, on: on, to: to)

      grant = AccessGrant.fetch(on, to)

      grant.role = role

      grant.save!

      yield assign_global_permissions.call to

      Success nil
    end
  end
end
