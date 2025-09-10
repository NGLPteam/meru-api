# frozen_string_literal: true

# A log of a revalidation request made to the frontend cache.
#
# @see Frontend::Cache::AbstractRevalidator
# @see Frontend::Cache::EntityRevalidator
# @see Frontend::Cache::InstanceRevalidator
class FrontendRevalidation < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes

  pg_enum! :kind, as: "frontend_revalidation_kind", allow_blank: false

  belongs_to :entity, polymorphic: true, optional: true

  scope :manual, -> { where(manual: true) }

  scope :prunable, -> { where(created_at: ...30.days.ago) }
end
