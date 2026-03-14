# frozen_string_literal: true

module Users
  # @api private
  # @see Access::EnforceAssignments
  class SynchronizeAllAccessInfo
    include Dry::Monads[:result]
    include QueryOperation

    QUERY = <<~SQL
    UPDATE users u
      SET access_management = uai.access_management,
          can_manage_access_globally = uai.can_manage_access_globally,
          can_manage_access_contextually = uai.can_manage_access_contextually
      FROM user_access_infos uai
      WHERE uai.user_id = u.id
    SQL

    # @return [Dry::Monads::Success(Integer)]
    def call
      result = sql_update! QUERY

      Success result
    end
  end
end
