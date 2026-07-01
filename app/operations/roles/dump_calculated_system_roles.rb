# frozen_string_literal: true

module Roles
  # Generate a file at `lib/frozen_record/system_roles.yml` with the results of
  # {Roles::CalculateSystemRoles calculating the system roles}. This file is
  # consumed by {SystemRole} and further used in {Roles::Sync} to ensure that
  # the Meru-API's default roles are pristine.
  class DumpCalculatedSystemRoles
    include Dry::Monads[:result, :do]
    include MeruAPI::Deps[
      calculate: "roles.calculate_system",
    ]

    DUMP_PATH = Rails.root.join("lib", "frozen_record", "system_roles.yml")

    # @return [Dry::Monads::Result]
    def call
      # simplecov:disable
      roles = yield calculate.call

      dump = roles.map(&:stringify_keys).to_yaml

      File.write DUMP_PATH.to_s, dump

      Success(dump)
      # simplecov:enable
    end
  end
end
