# frozen_string_literal: true

module Types
  # @see ::HasHarvestModificationStatus
  # @see Types::HasHarvestModificationStatusType
  class HarvestModificationStatusType < Types::BaseEnum
    description <<~TEXT
    An enum which describes how harvesting actions will affect
    a given record.
    TEXT

    value "UNHARVESTED", value: "unharvested" do
      description <<~TEXT
      This record was not created through harvesting actions.

      Should harvesting actions end up matching an unharvested record,
      it will change this value to `MODIFIED` and treat it as such.
      TEXT
    end

    value "PRISTINE", value: "pristine" do
      description <<~TEXT
      This record was created through harvesting actions and **has not**
      been modified in the admin section.

      Harvesting actions will overwrite any data if they encounter this record again.
      TEXT
    end

    value "MODIFIED", value: "modified" do
      description <<~TEXT
      This record was created through harvesting actions and **has**
      been modified in the admin section.

      Harvesting actions will leave this record alone.
      TEXT
    end
  end
end
