# frozen_string_literal: true

module Access
  # Asynchronously calculate {GrantedPermission} for the entire system.
  #
  # Rather than run the recalculation query in one go (which can take a few minutes,
  # depending), it will instead iterate through all {AccessGrant}s  and enqueue a job
  # for each one, reducing the stress on the table and keeping access calculations
  # performant.
  #
  # @see Access::CalculateGrantedPermissions
  class CalculateAllGrantedPermissionsJob < ApplicationJob
    include JobIteration::Iteration

    unique_job! by: :job

    queue_as :default

    # @param [String] cursor
    # @return [void]
    def build_enumerator(cursor:)
      enumerator_builder.active_record_on_records(
        AccessGrant.all,
        cursor:,
      )
    end

    # @param [AccessGrant] access_grant
    # @return [void]
    def each_iteration(access_grant)
      Access::CalculateGrantedPermissionsJob.perform_later access_grant
    end
  end
end
