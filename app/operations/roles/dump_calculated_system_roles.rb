# frozen_string_literal: true

module Roles
  # Generate a file at `lib/frozen_record/system_roles.yml` with the results of
  # {Roles::CalculateSystemRoles calculating the system roles}. This file is
  # consumed by {SystemRole} and further used in {Roles::Sync} to ensure that
  # the WDP-API's default roles are pristine.
  class DumpCalculatedSystemRoles
    include Dry::Monads[:result]
    include MeruAPI::Deps[
      calculate: "roles.calculate_system_roles",
    ]

    DUMP_PATH = Rails.root.join("lib", "frozen_record", "system_roles.yml")

    # @return [Dry::Monads::Result]
    def call
      # :nocov:
      roles = calculate.call

      dump = roles.map(&:stringify_keys).to_yaml

      File.write DUMP_PATH.to_s, dump

      Success(dump)
      # :nocov:
    end
  end
end
