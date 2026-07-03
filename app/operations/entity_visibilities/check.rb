# frozen_string_literal: true

module EntityVisibilities
  # An operation to check and update the `active` status of all {EntityVisibility} records.
  # It compares the current `active` status with the calculated value based on visibility and visibility range,
  # updating any records where there is a discrepancy.
  class Check
    include Dry::Monads[:result]

    # @return [Dry::Monads::Success(Integer)]
    def call
      updated = 0

      EntityVisibility.mismatched.find_each do |visibility|
        visibility.save!

        updated += 1
      end

      Success updated
    end
  end
end
