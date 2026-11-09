# frozen_string_literal: true

module HasHarvestModificationStatus
  extend ActiveSupport::Concern

  include ModifiedByAdmin

  included do
    pg_enum! :harvest_modification_status, as: :harvest_modification_status, allow_blank: false, default: "unharvested", suffix: :for_harvest

    before_validation :track_harvesting_modification_status!
  end

  # @return [Boolean]
  attr_accessor :maintain_pristine_status

  alias maintain_pristine_status? maintain_pristine_status

  def harvested_for_harvest? = !unharvested_for_harvest?

  # A hook called when the record is found by a harvesting action.
  #
  # Specifically, it will transform existing `unharvested` records to `modified`
  # in order to preserve and migrate existing records without clobbering
  # their data by the harvesting action.
  #
  # @return [void]
  def found_by_harvesting_action!
    return unless unharvested_for_harvest?

    if persisted?
      update_column :harvest_modification_status, "modified"

      return
    else
      self.harvest_modification_status = "pristine"
    end
  end

  private

  # @return [void]
  def track_harvesting_modification_status!
    return unless persisted? && modified_by_admin? && harvested_for_harvest?

    self.harvest_modification_status = maintain_pristine_status? ? "pristine" : "modified"
  end
end
